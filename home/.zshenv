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
if command -v zed >/dev/null 2>&1; then
  export EDITOR="zed --wait"
  export VISUAL="zed --wait"
else
  export EDITOR="nano"
  export VISUAL="nano"
fi
export BROWSER="firefox"
export GIT_USERNAME="jordanhoare"
export SOPS_AGE_KEY_FILE=~/.aincrad/.sops.age.key
export SOPS_AGE_SSH_PRIVATE_KEY_FILE=~/.ssh/personal

export HOMEBREW_NO_ENV_HINTS=1

# GH_TOKEN/GITHUB_TOKEN in the environment make gh ignore stored credentials,
# breaking `gh auth login` / `gh auth switch`. Unset any inherited value, then
# give mise its own var (MISE_GITHUB_TOKEN) sourced from gh's stored creds.
unset GH_TOKEN GITHUB_TOKEN
MISE_GITHUB_TOKEN="$(gh auth token 2>/dev/null)"
export MISE_GITHUB_TOKEN

export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"
export PATH="$HOME/.aftman/bin:$HOME/.cargo/bin:$HOME/.dotnet/tools:$PATH"

# mise shims so non-interactive shells (Zed remote server over SSH, scripted
# SSH, direnv hooks) see installed runtimes without needing `mise activate`,
# which only runs from .zshrc on interactive shells.
export PATH="$HOME/.local/share/mise/shims:$PATH"
