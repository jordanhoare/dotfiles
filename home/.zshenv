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
export GIT_USERNAME="jordanhoare"
export BROWSER="firefox"
