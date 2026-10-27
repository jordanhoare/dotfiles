#!/bin/sh
#MISE hide=true
#MISE raw=true
set -eu
export PATH="/nix/var/nix/profiles/default/bin:$PATH"

platform="${PLATFORM:-}"
if [ -z "$platform" ]; then
  if [ -n "${WSL_DISTRO_NAME:-}" ]; then platform=wsl; else platform=linux; fi
fi

nix run ./nix#home-manager -- switch --flake "./nix#$platform"
