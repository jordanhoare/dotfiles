#!/bin/sh
#MISE description="pull the merged pin bumps, apply, then upgrade the unpinned tools"
#MISE raw=true
set -eu
export PATH="/nix/var/nix/profiles/default/bin:${PATH}"

# Pins live in the repo and move only through renovate's pull requests, so this
# task never writes a tracked file: it pulls what merged and installs it.
dirty=$(git status --porcelain --untracked-files=no)
if [ -n "${dirty}" ]; then
  echo "error: the tree is dirty; commit or stash before upgrading" >&2
  exit 1
fi
git pull --ff-only

mise run apply
mise install

mise self-update -y
if command -v sheldon >/dev/null; then sheldon lock --update; fi
if command -v uv >/dev/null; then uv tool upgrade --all; fi
