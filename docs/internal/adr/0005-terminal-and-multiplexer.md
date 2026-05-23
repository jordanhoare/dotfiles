# ADR 0005 — Terminal emulator and multiplexer

## Context
WezTerm is effectively unmaintained (last release Feb 2024). A modern replacement is needed that works across Windows/WSL, native Linux, and macOS. SSH sessions are used almost every development session, making session persistence important.

## Decision
- Ghostty as the terminal emulator — actively maintained, GPU-accelerated, native on Windows/Mac/Linux, clean config format
- tmux as the multiplexer — session persistence over SSH, splits/windows, battle-tested, works headless on Linux VMs

## Consequences
- WezTerm config and Iosevka font bundle removed from dotfiles
- Ghostty config managed by stow
- tmux config managed by stow
- tmux adds a learning curve — start with minimal config and expand gradually
- On SSH sessions: tmux provides session resilience if connection drops
