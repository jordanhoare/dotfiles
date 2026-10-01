#!/usr/bin/env bash
# PreToolUse hook: refuse destructive git commands and pushes to main before an agent
# runs them. Exit 2 blocks the call and feeds stderr back to the model.

set -uo pipefail

payload=$(cat)
command=$(jq -r '.tool_input.command // empty' <<<"$payload")
[[ -z $command ]] && exit 0
cwd=$(jq -r '.cwd // empty' <<<"$payload")

# Cursor documents the JSON reason, not stderr, as the message for a block.
block() {
  jq -cn --arg reason "$1" \
    '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $reason}}'
  echo "$1" >&2
  exit 2
}

# Heredoc bodies are data (commit messages, file contents), so prose mentioning a
# blocked command must not trip the patterns.
command=$(awk '
  delimiter != "" { if ($0 == delimiter) delimiter = ""; next }
  { print }
  match($0, /<<-?[ ]*["'"'"']?[A-Za-z_]+/) {
    delimiter = substr($0, RSTART, RLENGTH)
    gsub(/^<<-?[ ]*["'"'"']?/, "", delimiter)
  }
' <<<"$command")

# Anchored at a word boundary so a path containing "git clean" does not trip the pattern.
dangerous_patterns=(
  'git +reset +--hard'
  'git +clean +-[a-zA-Z]*f'
  'git +branch +-D'
  'git +checkout +\.'
  'git +restore +\.'
  'git +filter-branch'
  'push +[^;&|]*--force'
  'push +([^;&|]* )?-f( |$)'
  'reset +--hard'
)

for pattern in "${dangerous_patterns[@]}"; do
  if grep -qE "$pattern" <<<"$command"; then
    block "BLOCKED: '$command' matches '$pattern'. The user has withheld this command; ask them to run it themselves with the '! ' prefix."
  fi
done

# Agents push feature branches freely; main is the user's to push, so the agent
# commits there and hands over.
push_segments=$(grep -oE '(^|[;&|(][[:space:]]*)git +push[^;&|]*' <<<"$command") || exit 0

current_branch=$(git -C "${cwd:-.}" rev-parse --abbrev-ref HEAD 2>/dev/null)
if [[ $current_branch == main || $current_branch == master ]]; then
  target="the current branch ($current_branch)"
elif grep -qE '[ :+](main|master)( |$)' <<<"$push_segments"; then
  target="main"
else
  exit 0
fi

block "BLOCKED: '$command' pushes $target. Commit only, then tell the user to push with '! git push'."
