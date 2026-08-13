# ZSH Theme
local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"

function k8s_prompt_info() {
  if command -v kubectl &>/dev/null; then
    local ctx=$(kubectl config current-context 2>/dev/null)
    if [[ -n "$ctx" ]]; then
      echo " $ctx"
    fi
  fi
}

PROMPT='%{$fg[green]%}%m|%{$fg[cyan]%}$(k8s_prompt_info) %{$reset_color%}%6~ %{$fg[yellow]%}$(git_prompt_info)%{$reset_color%}%B»%b '
RPS1="${return_code}"

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[yellow]%}‹"
ZSH_THEME_GIT_PROMPT_SUFFIX="› %{$reset_color%}"
