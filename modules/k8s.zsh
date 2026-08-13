# Kubernetes module
plugins+=(kubectl microk8s)

alias k=kubectl
alias kcontext='kubectl config use-context'
alias minikube-start='minikube start; ~/dev/core/vault/k8s/minkube-ecr-login.sh;'

# Crown package functions
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

function deployed-version() {
  kubectl get deployment "$@" -o jsonpath="{.metadata.labels.app\.kubernetes\.io\/version}"
}
