#!/usr/bin/env bash

set -euo pipefail

# osx
# Returns if we're running on osx
osx() {
  [ "$(uname)" = "Darwin" ]
}

# linux
# Returns if we're running on linux
linux() {
  [ "$(uname)" = "Linux" ]
}

# clone_or_pull <repository> <directory>
# Clones a repository into a directory if it doesn't exist, otherwise pulls in the latest changes.
clone_or_pull() {
  if [ ! -d "$2" ]; then
    git clone --depth 1 "$1" "$2"
  else
    git -C "$2" pull
  fi
}

# cecho <message>
# Displays a line of text in a different colour each time its called.
cecho() {
  echo "$(tput setaf "${ci:-1}")$1$(tput sgr0)" && ci=$(( (${ci:-1} % 6) + 1 ))
}

if osx; then
  cecho "Installing homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  cecho "Updating list of available packages"
  brew update

  pkgs="zsh git tmux fzf fd bat stow git-delta curl make cmake gcc"
  cecho "Installing $pkgs"
  brew install $pkgs
fi

if linux; then
  cecho "Updating list of available packages"
  sudo apt update

  pkgs="zsh git fd tmux bat stow curl make cmake g++"
  cecho "Installing $pkgs"
  sudo apt install -y $pkgs

  cecho "Installing rust"
  curl https://sh.rustup.rs -sSf | sh -s -- -y

  cecho "Sourcing ~/.cargo/env"
  source ~/.cargo/env

  cargo_pkgs="git-delta"
  for pkg in $cargo_pkgs; do
      cecho "Installing $pkg"
      cargo install "$pkg"
  done
fi

if linux; then
  cecho "Linking fd to fdfind"
  sudo ln -sfv "$(which fdfind)" /usr/local/bin/fd

  cecho "Linking bat to batcat"
  sudo ln -sfv "$(which batcat)" /usr/local/bin/bat
fi

if linux; then
  cecho "Installing fzf"
  clone_or_pull https://github.com/junegunn/fzf.git ~/.fzf
  fzf_install=~/.fzf/install
else
  fzf_install="$(brew --prefix)/opt/fzf/install"
fi

cecho "Setting up fzf"
$fzf_install --key-bindings --no-completion --no-update-rc

cecho "Installing Oh My Zsh"
if [ ! -d ~/.oh-my-zsh ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended
else
  ZSH=~/.oh-my-zsh ~/.oh-my-zsh/tools/upgrade.sh
fi

cecho "Installing tmux plugin manager"
clone_or_pull https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

if osx; then
  cecho "Installing tmux-256color terminfo"
  "$(brew --prefix ncurses)"/bin/infocmp tmux-256color > /tmp/tmux-256color.info
  tic -xve tmux-256color /tmp/tmux-256color.info
  rm /tmp/tmux-256color.info
fi

cecho "Installing pyenv"
if [ ! -d ~/.pyenv ]; then
  curl https://pyenv.run | bash
else
  ~/.pyenv/bin/pyenv update
fi

cecho "Installing nvim"
if osx; then
  brew install nvim
else
  snap install nvim
fi

cecho "Moving .zshrc -> .zshrc.old"
mv -iv ~/.zshrc ~/.zshrc.old

cecho "Restowing config files"
~/dev/dotfiles/restow.sh

cecho "Updating bat theme cache"
bat cache --build

cecho "Installation complete. Starting zsh"
exec zsh
