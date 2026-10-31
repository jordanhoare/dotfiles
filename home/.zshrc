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
export DIRENV_LOG_FORMAT=""
eval "$(direnv hook zsh)"

_update_git_identity() {
  export STARSHIP_GIT_USER=$(git config github.user 2>/dev/null)
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _update_git_identity

# uv is a mise runtime, so it is absent until `mise run bootstrap` has run.
command -v uv &>/dev/null && eval "$(uv generate-shell-completion zsh)"

[[ -n "$WSL_DISTRO_NAME" ]] && source ~/.zsh/wsl.zsh

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

# nixpkgs names the Zed cli `zeditor`. Under WSL, `zed` is the Windows install's
# script, which opens a WSL remote session. Paths go absolute because zed.exe
# resolves a relative one against its Windows cwd and opens it locally.
zed() {
  local cli=zed arg
  local -a args
  (( $+commands[zed] )) || cli=zeditor
  for arg in "${@:-.}"; do
    [[ $arg == -* ]] && args+=("$arg") || args+=("${arg:a}")
  done
  command $cli "${args[@]}"
}

# Keep the active gh account on the identity git would commit with here.
# Outside a repo, git's [includeIf] cannot fire, so the private paths are
# matched by hand to cover `gh repo clone` and `gh repo create`.
gh() {
  local target lower="${(L)PWD}"
  case "$lower" in
    /mnt/d/repositories/private/*)
      target=$(command git config --file ~/.config/git/private github.user 2>/dev/null) ;;
    *) target=$(command git config github.user 2>/dev/null) ;;
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
