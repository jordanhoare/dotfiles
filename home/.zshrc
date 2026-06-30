autoload -Uz compinit && compinit

# Prefix any one-off secret-bearing command with a leading space to skip history.
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_DUPS
setopt HIST_REDUCE_BLANKS
HISTORY_IGNORE='(bw *|sops *|age *|export *TOKEN*|export *SECRET*|export *KEY*|*PASSWORD*)'

eval "$(starship init zsh)"
eval "$(sheldon source)"
eval "$(mise activate zsh)"
eval "$(zoxide init zsh)"
command -v direnv &>/dev/null && { export DIRENV_LOG_FORMAT=""; eval "$(direnv hook zsh)"; }

_update_git_identity() {
  export STARSHIP_GIT_USER=$(git config github.user 2>/dev/null)
}
add-zsh-hook precmd _update_git_identity

command -v uv &>/dev/null && eval "$(uv generate-shell-completion zsh)"
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

if [[ -n "$WSL_DISTRO_NAME" ]]; then
  source ~/.zsh/platform/wsl.zsh
elif [[ "$OSTYPE" == darwin* ]]; then
  source ~/.zsh/platform/macos.zsh
else
  source ~/.zsh/platform/linux.zsh
fi

alias repos='cd $REPOS'
alias dot='cd $DOTFILES'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias zdot='cd $DOTFILES && zed .'
alias zsb='cd $GARDEN && zed .'
alias zmise='cd $DOTFILES && zed . $DOTFILES/config/mise/config.toml'
alias c='clear'
alias ls='eza --group-directories-first'
alias ll='eza -la --group-directories-first --git'
alias lt='eza --tree --level=2 --group-directories-first'
alias cat='bat --paging=never'
alias less='bat'
alias reload='source ~/.zshrc'

gclone() { gh repo clone "$1"; }

# Mirror git's identity includeIf rules for gh: switch the active gh account
# based on cwd so authenticated gh operations match the git identity that
# would commit in this path. Reads the expected gh user from the same git
# config files the includeIf already references; never names a handle inline.
gh() {
  local target lower="${(L)PWD}"
  case "$lower" in
    /mnt/d/repositories/private/*|/mnt/e/poe/*)
      target=$(command git config --file ~/.config/git/private github.user 2>/dev/null)
      ;;
    *)
      target=$(command git config --file ~/.config/git/personal github.user 2>/dev/null)
      ;;
  esac
  [ -n "$target" ] && command gh auth switch --user "$target" >/dev/null 2>&1
  command gh "$@"
}

alias gst='git status'
alias gcm='git commit -m'
alias gcam='git commit -am'
alias gaa='git add .'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gpl='git pull'
alias gps='git push'
alias gpf='git push --force-with-lease'
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gcount='git shortlog -sn'
alias gl='git log --oneline --graph --decorate'
alias glp='git log --pretty=format:"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --graph --date=relative'
alias gsta='git stash'
alias gstp='git stash pop'
alias gstl='git stash list'
alias gtag='git tag'
alias gtags='git tag --sort=-creatordate'
alias gclean='git clean -fd'
alias gprune='git remote prune origin'
