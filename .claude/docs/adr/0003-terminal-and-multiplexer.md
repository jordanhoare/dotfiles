# ADR 0003 — Terminal emulator and multiplexer

## Context

The terminal emulator must work natively across Windows, macOS, and Linux. SSH session persistence is required - used in almost every development session.

## Decision

- **Ghostty** as the terminal emulator - actively maintained, GPU-accelerated, native on all three platforms, clean config format. On Windows, Ghostty launches the WSL zsh session directly - no separate Windows shell config needed.
- **tmux** as the multiplexer - session persistence over SSH, splits and windows, works headless on Linux VMs.

## Consequences

- Ghostty and tmux configs managed via Home Manager `home.file`
- tmux provides session resilience if an SSH connection drops
