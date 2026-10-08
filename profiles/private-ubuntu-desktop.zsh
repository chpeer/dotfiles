# Profile: Private Ubuntu Desktop
DOTFILES_OS="ubuntu"
DOTFILES_MODULES=(
  k8s
  tmux
  python
  docker
)

# add go installation to path
export PATH=$PATH:/usr/local/go/bin
export PATH="$PATH:$(go env GOPATH)/bin"
