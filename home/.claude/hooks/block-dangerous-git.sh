#!/usr/bin/env bash
# PreToolUse hook: refuse destructive git commands before Claude Code runs them.
# Exit 2 tells the harness the call is blocked and feeds stderr back to the model.

set -uo pipefail

command=$(jq -r '.tool_input.command // empty')
[[ -z $command ]] && exit 0

# Anchored at a word boundary so `git pushd` or a path containing "git clean"
# does not trip the pattern.
dangerous_patterns=(
  'git +push'
  'git +reset +--hard'
  'git +clean +-[a-zA-Z]*f'
  'git +branch +-D'
  'git +checkout +\.'
  'git +restore +\.'
  'git +filter-branch'
  'push +--force'
  'reset +--hard'
)

for pattern in "${dangerous_patterns[@]}"; do
  if grep -qE "$pattern" <<<"$command"; then
    echo "BLOCKED: '$command' matches '$pattern'. The user has withheld this command; ask them to run it themselves with the '! ' prefix." >&2
    exit 2
  fi
done

exit 0
