# Dotfiles Base Directory
export DOTFILES="$HOME/dev/dotfiles"

# Set default Editor
export EDITOR='nvim'

# 1. Load Active Profile
# Checks in order:
# - $HOME/.dotfiles.profile (contains: source $DOTFILES/profiles/<profile>.zsh)
# - $DOTFILES/profiles/$(hostname -s).zsh
# - Default fallback based on OS
if [[ -f "$HOME/.dotfiles.profile" ]]; then
  source "$HOME/.dotfiles.profile"
elif [[ -f "$DOTFILES/profiles/$(hostname -s).zsh" ]]; then
  source "$DOTFILES/profiles/$(hostname -s).zsh"
else
  case "$(uname -s)" in
    Darwin) DOTFILES_OS="macos" ;;
    Linux)  DOTFILES_OS="ubuntu" ;;
  esac
  DOTFILES_MODULES=(python)
fi

# 2. Source OS Configuration
if [[ -n "$DOTFILES_OS" && -f "$DOTFILES/os/$DOTFILES_OS.zsh" ]]; then
  source "$DOTFILES/os/$DOTFILES_OS.zsh"
fi

# 3. Base Oh-My-Zsh Plugins
plugins=(vi-mode git)

# 4. Source Enabled Modules
for module in "${DOTFILES_MODULES[@]}"; do
  if [[ -f "$DOTFILES/modules/$module.zsh" ]]; then
    source "$DOTFILES/modules/$module.zsh"
  fi
done

# 5. Oh-My-Zsh Bootstrap
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="gallifrey"
ZSH_CUSTOM="$DOTFILES/oh-my-zsh-custom"

source $ZSH/oh-my-zsh.sh

# 6. Zsh Shell Options & Settings
setopt RM_STAR_WAIT
setopt interactivecomments
setopt CORRECT

HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
bindkey -v

TIMER_PRECISION=1
TIMER_FORMAT='[%d]'

if [[ -f "$HOME/.fzf.zsh" ]]; then
  source "$HOME/.fzf.zsh"
fi

# 7. Local Device Override (Optional git-ignored file for temporary tweaks/secrets)
if [[ -f "$HOME/.zshrc.local" ]]; then
  source "$HOME/.zshrc.local"
fi

