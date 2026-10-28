#!/usr/bin/env bash
#MISE description="restore keys and gh logins from bitwarden, decrypt secrets"
#MISE raw=true
# The decrypt needs ~/.ssh/personal, which this restore writes.
#MISE depends_post=["decrypt"]
set -euo pipefail

# gh ignores stored credentials whenever GH_TOKEN/GITHUB_TOKEN is set, so every
# gh call here runs with both stripped to force file-based credential storage.
gh() { command env -u GH_TOKEN -u GITHUB_TOKEN gh "$@"; }

if ! bw login --check >/dev/null 2>&1; then
  bw login
fi

export BW_SESSION
BW_SESSION=$(bw unlock --raw)
bw sync

mkdir -p ~/.ssh

# Restore one account: its SSH key plus the GitHub PAT held in a hidden custom
# field named "pat" on the same SSH Key item. gh logs in from the PAT, no browser.
restore_account() {
  local name="$1" id item key pat
  id=$(bw list items --search "${name}" | jq -r '.[] | select(.type == 5) | .id')
  if [[ -z "${id}" ]]; then
    echo "error: no SSH Key item named '${name}' in Bitwarden" >&2
    exit 1
  fi
  item=$(bw get item "${id}")
  key=$(echo "${item}" | jq -r '.sshKey.privateKey')
  pat=$(echo "${item}" | jq -r '.fields[]? | select(.name == "pat") | .value')
  if [[ -z "${pat}" ]]; then
    echo "error: no 'pat' field on Bitwarden item '${name}'" >&2
    exit 1
  fi

  printf '%s\n' "${key}" >~/.ssh/"${name}"
  chmod 600 ~/.ssh/"${name}"
  printf '%s\n' "${pat}" | gh auth login --hostname github.com --git-protocol ssh --with-token
}

restore_account personal
restore_account private

personal_user=$(git config --file ~/.config/git/personal github.user)
gh auth switch --hostname github.com --user "${personal_user}"

bw lock
