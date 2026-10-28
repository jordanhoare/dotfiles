#!/bin/sh
#MISE hide=true
#MISE description="install nix with the determinate installer (skipped once /nix holds a profile)"
#MISE raw=true
set -eu

if [ -x /nix/var/nix/profiles/default/bin/nix ]; then
  echo "nix already installed"
  exit 0
fi

# The Determinate installer refuses WSL without systemd. etc/wsl.conf turns it
# on; the distro must restart before the setting is live. Later edits to
# etc/wsl.conf are applied by hand.
if [ -n "${WSL_DISTRO_NAME:-}" ] && [ ! -d /run/systemd/system ]; then
  sudo install -m 644 etc/wsl.conf /etc/wsl.conf
  echo "systemd enabled in /etc/wsl.conf. Run 'wsl --shutdown' from Windows, reopen the distro, then: mise run bootstrap"
  exit 1
fi

curl -fsSL https://install.determinate.systems/nix | sh -s -- install --no-confirm
