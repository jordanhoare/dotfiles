# Login shells (SSH, Zed remote server) get the shims; .zshrc activates the
# full hook for interactive shells (ADR 0002).
command -v mise &>/dev/null && eval "$(mise activate zsh --shims)"

_git_identity_rprompt() {
  local name
  name=$(git config user.name 2>/dev/null) || return
  RPROMPT="%F{240}[${name}]%f"
}
autoload -U add-zsh-hook
add-zsh-hook precmd _git_identity_rprompt
