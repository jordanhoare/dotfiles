# Login shells (SSH, Zed remote server) get the shims; .zshrc activates the
# full hook for interactive shells.
command -v mise &>/dev/null && eval "$(mise activate zsh --shims)"
