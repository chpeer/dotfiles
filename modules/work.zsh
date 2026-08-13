# Work specific tools & aliases
plugins+=(please mettle)

alias pb='plz build'
alias pt='plz test'
alias pw='plz watch'
alias aws-login='$(aws ecr get-login)'

alias core3='cd ~/dev/core3/src'
alias alt='cd ~/dev/core3_alt/src'
alias alt1='cd ~/dev/core3_alt_1/src'
alias merge='gco master && git pull && gco - && git merge'

function arc() {
  if [ "$1" = "diff" ]; then
    /usr/local/bin/arc diff "${@:2}" && plz --repo_root $HOME/dev/core3/src run //experimental/mcaisey/phabricator/set_parent_revision
  else
    /usr/local/bin/arc "$@"
  fi
}

function earliest-version() {
  git tag --contains $1 | rg '^vault-\d\.\d+\.\d+$' | sort -n | head -1
}
