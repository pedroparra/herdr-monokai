#!/bin/zsh
# The demo's shell pane: a few commands with colored output, then a plain shell.
sleep 3   # let the pane settle at its final size
export GIT_PAGER=cat PAGER=cat
r=$'\e[0m' b=$'\e[1m' dim=$'\e[90m' red=$'\e[31m' grn=$'\e[32m' yel=$'\e[33m' blu=$'\e[34m' mag=$'\e[35m'
prompt() { print -n -- "${blu}~/web-app${r} ${mag}main${r} ${grn}❯${r} "; print -r -- "$1"; }
printf '\e[2J\e[H'
# The file the demo agent wrote, highlighted the Monokai way with the terminal's own
# colors: keywords pink, functions green, strings yellow, numbers purple, types cyan,
# comments grey.
kw=$red fn=$grn st=$yel nu=$mag ty=$blu cm=$dim
prompt "bat -p src/middleware/rate-limit.ts"
print "${cm}// 5 tries a minute per IP, then a 429${r}"
print "${kw}import${r} ${ty}type${r} { ${ty}Request${r}, ${ty}Response${r} } ${kw}from${r} ${st}\"express\"${r}"
print
print "${ty}const${r} WINDOW ${kw}=${r} ${nu}60_000${r}"
print "${ty}const${r} hits ${kw}=${r} ${kw}new${r} ${ty}Map${r}<${ty}string${r}, ${ty}number${r}[]>()"
print
print "${kw}export${r} ${ty}function${r} ${fn}rateLimit${r}({ max ${kw}=${r} ${nu}5${r} } ${kw}=${r} {}) {"
print "  ${kw}return${r} (req: ${ty}Request${r}, res: ${ty}Response${r}, next) ${ty}=>${r} {"
print "    ${ty}const${r} now ${kw}=${r} ${ty}Date${r}.${fn}now${r}()"
print "    ${ty}const${r} seen ${kw}=${r} (hits.${fn}get${r}(req.ip) ${kw}??${r} [])"
print "      .${fn}filter${r}((t) ${ty}=>${r} now ${kw}-${r} t ${kw}<${r} WINDOW)"
print "    ${kw}if${r} (seen.length ${kw}>=${r} max) {"
print "      ${kw}return${r} res.${fn}status${r}(${nu}429${r}).${fn}send${r}(${st}\"Slow down\"${r})"
print "    }"
print "    hits.${fn}set${r}(req.ip, [${kw}...${r}seen, now])"
print "    ${fn}next${r}()"
print "  }"
print "}"
prompt "npm test"
print " ${grn}${b}PASS${r} tests/health.test.ts"
print " ${grn}${b}PASS${r} tests/session.test.ts"
print " ${red}${b}FAIL${r} tests/checkout.test.ts"
print "   ${red}✕${r} applies the discount once ${dim}(31 ms)${r}"
print "${b}Tests:${r} ${red}${b}1 failed${r}, ${grn}${b}11 passed${r}, 12 total"
prompt "ansi-colors"
for i in {0..7}; do printf '\e[38;5;%dm██ ' $i; done; print "$r"
for i in {8..15}; do printf '\e[38;5;%dm██ ' $i; done; print "$r"
exec /bin/zsh -i
