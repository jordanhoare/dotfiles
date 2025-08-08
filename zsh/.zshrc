# ============================================================================ #
#                           DOTFILES & ENV DETECTION                           #
# ============================================================================ #
if [ -d "/mnt/d" ]; then
  export DOTFILES="/mnt/d/repositories/dotfiles"
  export REPOS="/mnt/d/repositories"
  export MSBuild="D:\msvsc\product\MSBuild\Current\Bin\MSBuild.exe"
  alias home='cd /mnt/d/'
elif [[ "$OSTYPE" == msys* ]] || [[ "$OSTYPE" == cygwin* ]]; then
  export DOTFILES="/d/repositories/dotfiles"
  export REPOS="/d/repositories"
  alias home='cd /d/'
else
  export DOTFILES="$HOME/repositories/dotfiles"
  export REPOS="$HOME/repositories"
  alias home='cd ~'
fi

# ============================================================================ #
#                              CORE ENVIRONMENT                                #
# ============================================================================ #
export LANG="en_US.UTF-8"
export BROWSER="firefox"
export GIT_USERNAME="jordanhoare"
export GIT_EMAILADDRESS="jordan.hoare@outlook.com"
export GIT_GAME_USERNAME="jordanhoare"
export GIT_GAME_EMAILADDRESS="jordan.hoare@outlook.com"

# ============================================================================ #
#                              PATH CONFIGURATION                              #
# ============================================================================ #
# Local & user bins first
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

# Go toolchain
export GOPATH="$HOME/go"
export GOROOT="/usr/local/go"
export GOBIN="$GOPATH/bin"
export PATH="$PATH:$GOPATH:$GOROOT/bin"

# Developer tools
[ -d "$HOME/.poetry/bin" ] && export PATH="$PATH:$HOME/.poetry/bin"
[ -d "$HOME/.cargo/bin" ]  && export PATH="$PATH:$HOME/.cargo/bin"

# ============================================================================ #
#                                     NVM                                      #
# ============================================================================ #
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  . "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
fi

# ============================================================================ #
#                                    PYENV                                     #
# ============================================================================ #
export PYENV_ROOT="$HOME/.pyenv"
if [ -d "$PYENV_ROOT" ]; then
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
  command -v pyenv-virtualenv >/dev/null 2>&1 && eval "$(pyenv virtualenv-init -)"
fi

# ============================================================================ #
#                           DEFAULT EDITOR SELECTION                           #
# ============================================================================ #
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR="nano"
else
  export EDITOR="code"
fi

# ============================================================================ #
#                           ZSH + OH-MY-ZSH SETUP                              #
# ============================================================================ #
export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_CUSTOM="$DOTFILES/zsh/themes"
ZSH_THEME="passion/passion"
HYPHEN_INSENSITIVE="true"
plugins=(git)

[ -f "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

# ============================================================================ #
#                               VS CODE Wrapper                                #
# ============================================================================ #
# VS Code (portable) — use the Windows shim if present
if [ -d "/mnt/d/vscode/bin" ]; then
  case ":$PATH:" in
    *":/mnt/d/vscode/bin:"*) : ;;  # already in PATH
    *) export PATH="$PATH:/mnt/d/vscode/bin" ;;
  esac
fi

# ============================================================================ #
#                                 GIT ALIASES                                  #
# ============================================================================ #
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

# ============================================================================ #
#                                 USER ALIASES                                 #
# ============================================================================ #
export SECONDBRAIN="$REPOS/second-brain"
alias repos='cd $REPOS'
alias tibia='cd $REPOS/tibia-oce'
alias dotfiles='cd $DOTFILES'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias vdot='cd $DOTFILES && code .'
alias vsb='cd $SECONDBRAIN && code .'
alias c='clear'
alias reload='source ~/.zshrc'
