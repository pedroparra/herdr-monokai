#!/bin/zsh
# A stand-in agent for the demo: it prints some text and reports one status to Herdr
# (OSC 7501). Nothing else runs.
#   demo-agent.sh <state> <app> <title> [kind] [transcript]
#   state: working, blocked, done or idle    kind: for blocked, permission or question
# "done" works for a few seconds first: Herdr's done means it finished while you
# weren't looking.
state=$1 app=$2 title=$3 kind=${4:-} show=${5:-}
printf '\e]2;%s\a' "$title"

if [[ $show == transcript ]]; then
  sleep 3   # let the pane settle at its final size
  r=$'\e[0m' b=$'\e[1m' dim=$'\e[90m' red=$'\e[31m' grn=$'\e[32m' yel=$'\e[33m'
  printf '\e[2J\e[H'
  print "${dim}>${r} Add rate limiting to POST /login"
  print
  print "⏺ I'll put a token-bucket limiter in front of"
  print "  the login handler: 5 attempts a minute per IP."
  print
  print "${grn}⏺${r} ${b}Read${r}(src/routes/login.ts)"
  print "${dim}  ⎿  Read 48 lines${r}"
  print
  print "${grn}⏺${r} ${b}Write${r}(src/middleware/rate-limit.ts)"
  print "${dim}  ⎿  Wrote 18 lines${r}"
  print
  print "${grn}⏺${r} ${b}Update${r}(src/routes/login.ts)"
  print "${dim}  ⎿  2 additions, 1 removal${r}"
  print "${dim}     12${r} ${red}- router.post(\"/login\", login)${r}"
  print "${dim}     12${r} ${grn}+ const limit = rateLimit({ max: 5 })${r}"
  print "${dim}     13${r} ${grn}+ router.post(\"/login\", limit, login)${r}"
  print
  print "${grn}⏺${r} ${b}Bash${r}(npm test -- login)"
  print "${dim}  ⎿  ${r}${grn}${b}PASS${r} tests/login.test.ts ${dim}(6 tests)${r}"
  print
  print "${yel}✻ Testing the sixth attempt…${r} ${dim}(21s · esc to interrupt)${r}"
  rows=$(tput lines) cols=$(tput cols)
  line=${(l:$((cols - 1))::─:)}
  printf '\e[%d;1H%s%s%s\n%s>%s \n%s%s%s\n%s  ? for shortcuts%s' $((rows - 3)) "$dim" "$line" "$r" "$dim" "$r" "$dim" "$line" "$r" "$dim" "$r"
  printf '\e[%d;3H' $((rows - 2))
else
  print "Demo agent: it reports \"$state\" to Herdr and nothing else runs here."
fi

if [[ $state == done ]]; then printf '\e]7501;state=working:app=%s\a' "$app"; sleep 4; fi
# `demo.sh gif` moves an agent through states by writing "<state> [kind]" into this
# file; without it the agent keeps the state it started with.
ctl=$HOME/.demo/${title// /-}
sent= last=0
while true; do
  [[ -r $ctl ]] && read -r state kind < "$ctl"
  if [[ $state:$kind != "$sent" ]] || (( SECONDS - last >= 5 )); then
    printf '\e]7501;state=%s:app=%s%s\a' "$state" "$app" "${kind:+:kind=$kind}"
    sent=$state:$kind last=$SECONDS
  fi
  sleep 0.2
done
