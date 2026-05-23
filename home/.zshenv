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

export GARDEN="$REPOS/garden"
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"

export LANG="en_US.UTF-8"
export EDITOR="nano"
export BROWSER="firefox"
export GIT_USERNAME="jordanhoare"
export SOPS_AGE_KEY_FILE=~/.aincrad/.sops.age.key
export SOPS_AGE_SSH_PRIVATE_KEY_FILE=~/.ssh/personal

export HOMEBREW_NO_ENV_HINTS=1

# allow mise to fetch tool versions without hitting github rate limits
export GITHUB_TOKEN="$(gh auth token 2>/dev/null)"

export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"
export PATH="$HOME/.aftman/bin:$HOME/.cargo/bin:$PATH"
