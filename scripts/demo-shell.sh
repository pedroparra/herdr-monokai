#!/bin/zsh
# The demo's shell pane: a few commands with colored output, then a plain shell.
sleep 3   # let the pane settle at its final size
export GIT_PAGER=cat PAGER=cat
r=$'\e[0m' b=$'\e[1m' dim=$'\e[90m' red=$'\e[31m' grn=$'\e[32m' blu=$'\e[34m' mag=$'\e[35m'
prompt() { print -n -- "${blu}~/web-app${r} ${mag}main${r} ${grn}❯${r} "; print -r -- "$1"; }
printf '\e[2J\e[H'
prompt "git log --oneline --graph -5"
git -c color.ui=always log --oneline --graph --decorate -5
prompt "git status -s"
git -c color.ui=always status -s
prompt "ls"
print "${blu}${b}src${r}  ${blu}${b}tests${r}  CHANGELOG.md  package.json  ${grn}${b}deploy.sh${r}"
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
