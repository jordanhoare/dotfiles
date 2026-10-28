#!/bin/sh
#MISE description="update mise and flake.lock, switch, then upgrade every tool"
#MISE raw=true
set -eu
export PATH="/nix/var/nix/profiles/default/bin:${PATH}"

mise self-update -y
nix flake update --flake ./nix
mise run switch
if command -v sheldon >/dev/null; then sheldon lock --update; fi
mise upgrade
if command -v uv >/dev/null; then uv tool upgrade --all; fi
