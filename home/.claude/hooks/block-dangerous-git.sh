#!/usr/bin/env bash
# PreToolUse hook: refuse destructive git commands and pushes to main before Claude
# Code runs them. Exit 2 tells the harness the call is blocked and feeds stderr back
# to the model.

set -uo pipefail

payload=$(cat)
command=$(jq -r '.tool_input.command // empty' <<<"$payload")
[[ -z $command ]] && exit 0
cwd=$(jq -r '.cwd // empty' <<<"$payload")

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
    echo "BLOCKED: '$command' matches '$pattern'. The user has withheld this command; ask them to run it themselves with the '! ' prefix." >&2
    exit 2
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

echo "BLOCKED: '$command' pushes $target. Commit only, then tell the user to push with '! git push'." >&2
exit 2
