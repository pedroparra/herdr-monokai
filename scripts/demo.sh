#!/bin/zsh
# Opens a second Herdr window with Monokai for Herdr and demo content: three spaces,
# agents in every state, a terminal full of colors. It has its own Herdr home, its own
# herdr-core session and its own HOME, so it can't see or change your spaces,
# terminals or settings. The agents are scripts that print text and report a status;
# no real agent runs. (Same approach as shellscape/herdr-whitby's demo.)
#
#   scripts/demo.sh          start it (DEMO_SIZE=1280x800 sets the window size)
#   scripts/demo.sh shot     save preview.png from it (1600x1000)
#   scripts/demo.sh stop     quit it and stop its core
#
# DEMO_DIR picks where it lives (default: $TMPDIR/hmd). Keep it short: Herdr and
# herdr-core talk over unix sockets inside it.
set -euo pipefail

repo=${0:A:h:h}
dir=${DEMO_DIR:-${${TMPDIR:-/tmp}%/}/hmd}
mkdir -p "$dir"
dir=${dir:A}   # the real path (/var is /private/var on macOS), so ~ matches what Herdr shows
size=${DEMO_SIZE:-1280x800}
hc_bin=$(command -v hc)
demo_env=(
  HOME="$dir/home" HERDR_APP_HOME="$dir/app" XDG_CONFIG_HOME="$dir/cfg" XDG_STATE_HOME="$dir/st"
  XDG_RUNTIME_DIR="$dir/rt" HC_SESSION=mk ZDOTDIR="$dir/zdot"   # short: socket paths max out at 103 bytes
  # No update downloads or usage reports from a throwaway window.
  HERDR_RELEASES_URL=http://127.0.0.1:9 HERDR_TELEMETRY=0 DO_NOT_TRACK=1
)
in_demo() { env "${demo_env[@]}" "$@"; }
core_pid() { "$@" hc server status --json 2>/dev/null | sed -n 's/.*"pid":\([0-9]*\).*/\1/p' | tail -1; }

case ${1:-start} in
  stop)
    in_demo herdr-app do app.quit >/dev/null 2>&1 || true
    in_demo hc server stop >/dev/null 2>&1 || true
    print "Stopped the demo in $dir."
    exit 0 ;;
  shot)
    out=$repo/preview.png
    in_demo herdr-app shot "$dir/shot.png" >/dev/null
    sips -z 1000 1600 "$dir/shot.png" --out "$out" >/dev/null
    print "Saved $out"
    exit 0 ;;
esac

# The demo's home: the layout and theme, past the welcome and the update notice.
mkdir -p "$dir"/{app/layouts,app/themes,cfg,st,rt,zdot,home}
chmod 700 "$dir/rt"
cp "$repo"/layouts/monokai-for-herdr.{json,svg} "$dir/app/layouts/"
cp "$repo"/themes/monokai.json "$dir/app/themes/"
print '{"layout":"monokai-for-herdr","frame.welcomed":"finished"}' > "$dir/app/shared.json"
print "{\"last_run\":\"$(herdr-app --version | awk '{print $NF}')\",\"presented\":[]}" > "$dir/app/update-notes.json"
print "{\"zoom\":1.0,\"telemetry\":false,\"sounds\":{\"enabled\":false},\"core\":\"$hc_bin\"}" > "$dir/app/settings.json"
print "{\"state\":\"windowed\",\"bounds\":[120.0,80.0,${size%x*}.0,${size#*x}.0]}" > "$dir/app/window.json"
# A plain prompt for the demo shells, not yours.
print 'PS1="%F{4}%~%f %F{5}main%f %F{2}❯%f "; HISTFILE=/dev/null' > "$dir/zdot/.zshrc"

# Three small projects with some git history, so the sidebar has branches to show.
project() {
  local p=$dir/home/$1; shift
  [[ -d $p/.git ]] && return
  mkdir -p "$p" && cd "$p" && git init -q -b main
  local msg
  for msg in "$@"; do
    print "$msg" >> CHANGELOG.md
    git add -A && git -c user.name=Demo -c user.email=demo@example.com commit -q -m "$msg"
  done
  cd "$repo"
}
# web-app: login.ts is in the history, then changed and joined by a new file, as the
# demo agent says it did.
mkdir -p "$dir/home/web-app"/{src/routes,tests}
print 'router.post("/login", login)' > "$dir/home/web-app/src/routes/login.ts"
project web-app "Initial commit" "Add health check endpoint" "Move session store to Redis" "Fix flaky checkout test" "Add login rate limit config"
mkdir -p "$dir/home/web-app/src/middleware"
print 'router.post("/login", limit, login)' > "$dir/home/web-app/src/routes/login.ts"
print 'export const rateLimit = () => {}' > "$dir/home/web-app/src/middleware/rate-limit.ts"
project api "Initial commit" "Add users table"
project docs "Initial commit"

in_demo nohup herdr-app >"$dir/app.log" 2>&1 &
for _ in {1..40}; do in_demo herdr-app status >/dev/null 2>&1 && break; sleep 0.5; done

# Never put demo terminals in your own core.
mine=$(core_pid env)
theirs=$(core_pid in_demo)
if [[ -z $theirs || $theirs == "$mine" ]]; then
  print -u2 "The demo's herdr-core isn't separate from yours; stopping."
  exit 1
fi

agent=$repo/scripts/demo-agent.sh
shell=$repo/scripts/demo-shell.sh
w=$dir/home/web-app
do_() {
  local out; out=$(in_demo herdr-app do "$@" 2>&1)
  if [[ $out == *'"error"'* ]]; then print -u2 "herdr-app do $1: $out"; exit 1; fi
}

do_ space.new "{\"name\":\"web-app\",\"folder\":\"$w\",\"tab\":\"rate limit\",\"argv\":[\"$agent\",\"working\",\"claude-code\",\"Rate limit on /login\",\"\",\"transcript\"]}"
sleep 1
# The new space's only pane (the first one `ls` lists).
pane=$(in_demo herdr-app ls | sed -n 's/.*"pane": *"\([^"]*\)".*/\1/p' | head -1)
[[ -n $pane ]] || { print -u2 "Couldn't find the first pane; stopping."; exit 1; }
do_ pane.split "{\"direction\":\"right\",\"pane\":\"$pane\",\"argv\":[\"$shell\"]}"
do_ tab.new "{\"name\":\"checkout test\",\"folder\":\"$w\",\"argv\":[\"$agent\",\"blocked\",\"codex\",\"Fix flaky checkout test\",\"permission\"]}"
do_ tab.new "{\"name\":\"release notes\",\"folder\":\"$w\",\"argv\":[\"$agent\",\"done\",\"claude-code\",\"Write release notes\"]}"
do_ space.new "{\"name\":\"api\",\"folder\":\"$dir/home/api\",\"argv\":[\"$agent\",\"working\",\"codex\",\"Migrate users table\"]}"
do_ space.new "{\"name\":\"docs\",\"folder\":\"$dir/home/docs\",\"argv\":[\"$agent\",\"idle\",\"claude-code\",\"Update the README\"]}"
do_ space.select '{"index":1}'
do_ tab.select '{"index":1}'
do_ pane.focus "{\"pane\":\"$pane\"}"

print "Demo running from $dir. Save the picture with: scripts/demo.sh shot. Stop it with: scripts/demo.sh stop"
