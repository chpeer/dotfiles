# macOS-specific environment configuration

# Homebrew setup
if [[ -d "/opt/homebrew/bin" ]]; then
  export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
  export HOMEBREW_PREFIX="/opt/homebrew"
elif [[ -d "/usr/local/bin" ]]; then
  export HOMEBREW_PREFIX="/usr/local"
fi

if [[ -n "$HOMEBREW_PREFIX" ]]; then
  export PATH="${HOMEBREW_PREFIX}/opt/openssl/bin:$PATH"
fi

export HOMEBREW_CASK_OPTS="--appdir=$HOME/Applications"

# Local user binaries
export PATH="$HOME/.local/bin:$PATH"
