export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_CUSTOM="$DOTFILES/zsh/themes"
ZSH_THEME="w00fz-bureau-fast"
HYPHEN_INSENSITIVE="true"
plugins=(git)
[ -f "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

_git_identity_rprompt() {
  local name
  name=$(git config user.name 2>/dev/null) || return
  RPROMPT="%F{240}[${name}]%f"
}
add-zsh-hook precmd _git_identity_rprompt
