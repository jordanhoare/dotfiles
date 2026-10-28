#!/bin/sh
#MISE description="pull, update every pin and tool, then apply"
#MISE raw=true
set -eu
export PATH="/nix/var/nix/profiles/default/bin:${PATH}"

dirty=$(git status --porcelain)
if [ -n "${dirty}" ]; then
  echo "error: the tree is dirty; commit or stash before upgrading" >&2
  exit 1
fi
git pull --ff-only

mise self-update -y
nix flake update --flake ./nix
mise run apply
if command -v sheldon >/dev/null; then sheldon lock --update; fi
mise upgrade
if command -v uv >/dev/null; then uv tool upgrade --all; fi
