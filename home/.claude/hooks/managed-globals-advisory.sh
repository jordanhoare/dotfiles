#!/usr/bin/env bash
# PreToolUse hook: name the managed toolchain when a command installs machine-wide.
# Always exits 0 - it advises, never blocks, because a project-local install is
# usually right and only the global ones need redirecting.

set -uo pipefail

command=$(jq -r '.tool_input.command // empty')
[[ -z $command ]] && exit 0

# `uv pip install` targets the project venv, not the machine. Neutralise it so the
# bare `pip install` pattern below cannot claim it.
scan=${command//uv pip/uv-pip}

global_patterns=(
  '(^|[;&|[:space:]])pip3? +install'
  'pipx +install'
  'uv +tool +install'
  'npm +(install|i|add)[^;&|]*(-g|--global)'
  'yarn +global +add'
  'pnpm +(add|install)[^;&|]*(-g|--global)'
  'brew +(install|tap)'
  'cargo +install'
  'go +install'
  'gem +install'
  '(apt|apt-get) +install'
  'nix +profile +install'
)

for pattern in "${global_patterns[@]}"; do
  grep -qE "$pattern" <<<"$scan" || continue

  advisory=$(cat <<'EOF'
Globals on this machine are managed by ~/repositories/dotfiles (Nix + Home Manager):
  runtimes and tools -> mise
  js packages        -> bun / bunx
  system packages    -> declare in nix/modules/base.nix, then `make switch`
If this dependency is project-local, use the project's own manager instead.
EOF
)
  jq -nc --arg ctx "$advisory" \
    '{hookSpecificOutput:{hookEventName:"PreToolUse",additionalContext:$ctx}}'
  exit 0
done

exit 0
