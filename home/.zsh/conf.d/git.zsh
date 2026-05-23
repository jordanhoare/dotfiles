_git_identity_rprompt() {
  local name
  name=$(git config user.name 2>/dev/null) || return
  RPROMPT="%F{240}[${name}]%f"
}
add-zsh-hook precmd _git_identity_rprompt
