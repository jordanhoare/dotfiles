# ADR 0020 - Claude hooks find Git Bash through one variable

## Context

The Claude Code hooks in `home/.claude/hooks/` are bash scripts, linked to `~/.claude/hooks` on every platform (ADR 0014). On Windows, Claude Code runs them through Git Bash, which it locates at the default install path under `Program Files`. On a machine where Git is installed elsewhere that lookup fails, and the harness falls back to launching the `.sh` file through its Windows file association. VS Code registers itself for `.sh`, so every tool call that fires a PreToolUse hook opened the hook in VS Code, and the hook never ran.

## Decision

`win/apply.ps1` sets the user environment variable `CLAUDE_CODE_GIT_BASH_PATH` to `<Git install>\bin\bash.exe`, resolved from the Git for Windows registry key it already reads for the Zed terminal. The hooks stay bash.

## Considered Options

- **Rewrite the hooks in PowerShell with `"shell": "powershell"`.** Rejected: one hook body per platform, and the WSL, Linux and macOS hosts would carry a Windows duplicate they never run.
- **Install Git to the default path.** Rejected: the install location is a machine fact, and the script already resolves it for Zed rather than assuming it.
- **Reassign the `.sh` file association.** Rejected: it hides the failure instead of running the hook.

## Consequences

- The variable is a machine fact `apply` derives on each run, never a committed value. A changed Git install path is picked up by the next `mise run apply`.
- Like the mise shims on `Path`, it takes effect in a new shell, so `apply` says so when it writes it.
- `jq` remains a hard dependency of the hooks (ADR 0014); winget installs it.
