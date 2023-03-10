alias minikube-start='minikube start; ~/dev/core/vault/k8s/minkube-ecr-login.sh;'
alias pb='plz build'
alias pt='plz test' 
alias pw='plz watch'
alias aws-login='$(aws ecr get-login)'
alias k=kubectl
alias kcontext='kubectl config use-context'
alias vim=nvim
alias core3='cd ~/dev/core3/src'
alias dotfiles='cd ~/dev/dotfiles'

# substitute for arc to set parent revision on diff 
function arc() {
  if [ "$1" = "diff" ]; then
    /usr/local/bin/arc diff "${@:2}" && plz --repo_root /home/christian/dev/core3/src run //experimental/mcaisey/phabricator/set_parent_revision
  else
    /usr/local/bin/arc "$@"
  fi
}

# deploy gives you a list of all crown packages available. Pick one and it will then deploy to local cluster
function update-crown-pkg-cache() {
    echo $(plz query alltargets --include crown_package | tee ~/.crown-pkg-cache | wc -l) crown packages written to ~/.crown-pkg-cache
}

function deploy() {
    if [ ! -f ~/.crown-pkg-cache ]; then
        echo "Crown package cache doesn't exist, running update-crown-pkg-cache"
        update-crown-pkg-cache
    fi
    local pkgs=($(cat ~/.crown-pkg-cache | fzf --multi))
    local result=""
    for pkg in $pkgs; do
        if plz deploy $pkg; then
            result="$result\n\033[32;1m$pkg deployed successfully\033[0m"
        else
            result="$result\n\033[31;1m$pkg failed to deploy\033[0m"
        fi
    done
    echo $result
}
