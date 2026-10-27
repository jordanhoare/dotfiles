#!/bin/sh
#MISE description="decrypt every committed *.sops file to its target under ~"
set -eu

export SOPS_AGE_SSH_PRIVATE_KEY_FILE="${HOME}/.ssh/personal"

# The package a file sits in gives its target: home/ maps to ~, config/ to ~/.config.
git ls-files '*.sops' | while read -r source; do
  case "${source}" in
    home/*) target="${HOME}/${source#home/}" ;;
    config/*) target="${HOME}/.config/${source#config/}" ;;
    *)
      echo "skip   ${source}: not under home/ or config/" >&2
      continue
      ;;
  esac
  target="${target%.sops}"
  mkdir -p "$(dirname "${target}")"
  (umask 077 && sops --decrypt --output "${target}" "${source}")
  echo "write  ${target}"
done
