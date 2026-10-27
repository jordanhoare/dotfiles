#!/bin/sh
#MISE hide=true
#MISE raw=true
set -eu
export PATH="/nix/var/nix/profiles/default/bin:$PATH"

# darwin-rebuild comes from the flake-pinned nix-darwin, not the registry, and
# the build also covers fresh machines where it is not yet on PATH.
nix build ./nix#darwinConfigurations.macos.system --out-link nix/result
sudo nix/result/sw/bin/darwin-rebuild switch --flake ./nix#macos
