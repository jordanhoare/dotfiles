# ────────────────────────────────────────────────────────────────────────────
#                        ▸ DOTFILES & ENV DETECTION ◂
# ────────────────────────────────────────────────────────────────────────────
if [ -d "/mnt/d" ]; then
  export DOTFILES="/mnt/d/repositories/dotfiles"
  export REPOS="/mnt/d/repositories"
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

# ────────────────────────────────────────────────────────────────────────────
#                             ▸ CORE ENVIRONMENT ◂
# ────────────────────────────────────────────────────────────────────────────
export LANG="en_US.UTF-8"
export BROWSER="firefox"

export GIT_USERNAME="jordanhoare"
export GIT_EMAILADDRESS="jordan.hoare@outlook.com"
export GIT_GAME_USERNAME="jordanhoare"
export GIT_GAME_EMAILADDRESS="jordan.hoare@outlook.com"

# ────────────────────────────────────────────────────────────────────────────
#                          ▸ PATH CONFIGURATION ◂
# ────────────────────────────────────────────────────────────────────────────
## Local & user bins first
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

## Go toolchain
export GOPATH="$HOME/go"
export GOROOT="/usr/local/go"
export GOBIN="$GOPATH/bin"
export PATH="$PATH:$GOPATH:$GOROOT/bin"

## Developer tools
[ -d "$HOME/.poetry/bin" ]  && export PATH="$PATH:$HOME/.poetry/bin"
[ -d "$HOME/.cargo/bin" ]   && export PATH="$PATH:$HOME/.cargo/bin"

# ────────────────────────────────────────────────────────────────────────────
#                        ▸ PYENV INITIALIZATION ◂
# ────────────────────────────────────────────────────────────────────────────
if command -v pyenv &>/dev/null; then
  export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi

# ────────────────────────────────────────────────────────────────────────────
#                        ▸ DEFAULT EDITOR SELECTION ◂
# ────────────────────────────────────────────────────────────────────────────
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR="nano"
else
  export EDITOR="code"
fi

# ────────────────────────────────────────────────────────────────────────────
#                        ▸ ZSH + OH-MY-ZSH SETUP ◂
# ────────────────────────────────────────────────────────────────────────────
export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_CUSTOM="$DOTFILES/zsh/themes"    # override custom-dir to your repo
ZSH_THEME="passion/passion"
HYPHEN_INSENSITIVE="true"
plugins=(git)

# Only source if installed
[ -f "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

# ────────────────────────────────────────────────────────────────────────────
#                              ▸ USER ALIASES ◂
# ────────────────────────────────────────────────────────────────────────────
alias repos='cd $REPOS'
alias dotfiles='cd $DOTFILES'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias vdot='cd $DOTFILES && code .'
alias c='clear'
alias sz='source ~/.zshrc'
