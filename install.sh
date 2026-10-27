#!/bin/sh
# Entry point for a fresh macOS, Linux or WSL machine:
#   curl -fsSL https://raw.githubusercontent.com/jordanhoare/dotfiles/main/install.sh | sh
# Does only what must happen before the clone: git, mise, the clone itself.
# Everything after that is a mise task in mise.toml.
set -eu

repo="https://github.com/jordanhoare/dotfiles.git"
if [ -n "${WSL_DISTRO_NAME:-}" ]; then
  # WSL keeps every repo on the Windows drive so Windows toolchains can reach it.
  dotfiles="/mnt/d/repositories/dotfiles"
else
  dotfiles="$HOME/repositories/dotfiles"
fi

install_clt() {
  xcode-select -p >/dev/null 2>&1 && return
  # Homebrew's headless route: the placeholder file makes softwareupdate list
  # the Command Line Tools. Apple does not document it, so fall back to the
  # dialog when no label comes back.
  sudo touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  label=$(softwareupdate -l 2>/dev/null | grep -B 1 -E 'Command Line Tools' | awk -F'*' '/^ *\*/ {print $2}' | sed -e 's/^ *Label: //' -e 's/^ *//' | head -n1)
  sudo rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  if [ -n "$label" ]; then
    sudo softwareupdate -i "$label" --verbose
    sudo xcode-select --switch /Library/Developer/CommandLineTools
  else
    xcode-select --install
    echo "finish the Command Line Tools dialog, then rerun this script" >&2
    exit 1
  fi
}

case "$(uname -s)" in
  Darwin) install_clt ;;
  Linux)
    if ! command -v git >/dev/null || ! command -v curl >/dev/null; then
      sudo apt-get update
      sudo apt-get install -y git curl
    fi
    ;;
esac

if ! [ -x "$HOME/.local/bin/mise" ]; then
  curl -fsSL https://mise.run | MISE_INSTALL_HELP=0 sh
fi

if ! [ -d "$dotfiles/.git" ]; then
  mkdir -p "$(dirname "$dotfiles")"
  git clone "$repo" "$dotfiles"
fi

cd "$dotfiles"
exec "$HOME/.local/bin/mise" run bootstrap
