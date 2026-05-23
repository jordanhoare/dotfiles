if [[ -n "$WSL_DISTRO_NAME" ]]; then
  export DOTFILES="/mnt/d/repositories/dotfiles"
  export REPOS="/mnt/d/repositories"
elif [[ "$OSTYPE" == msys* ]] || [[ "$OSTYPE" == cygwin* ]]; then
  export DOTFILES="/d/repositories/dotfiles"
  export REPOS="/d/repositories"
else
  export DOTFILES="$HOME/repositories/dotfiles"
  export REPOS="$HOME/repositories"
fi

export LANG="en_US.UTF-8"
export EDITOR="nano"
export BROWSER="firefox"
export GIT_USERNAME="jordanhoare"
export SECONDBRAIN="$REPOS/second-brain"
export SOPS_AGE_KEY_FILE=~/.aincrad/.sops.age.key

export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"
export GOPATH="$HOME/go"
export GOROOT="/usr/local/go"
export GOBIN="$GOPATH/bin"
export PATH="$PATH:$GOPATH:$GOROOT/bin"
export PATH="$HOME/.aftman/bin:$HOME/.cargo/bin:$PATH"
[ -d "$HOME/.poetry/bin" ] && export PATH="$PATH:$HOME/.poetry/bin"

export NVM_DIR="$HOME/.nvm"
