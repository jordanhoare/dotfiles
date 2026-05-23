if [ -s "$NVM_DIR/nvm.sh" ]; then
  . "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
fi

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
alias vdot='cd $DOTFILES && code .'
alias vsb='cd $SECONDBRAIN && code .'
alias c='clear'
alias reload='source ~/.zshrc'

gclone() { gh repo clone "$1" }

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
