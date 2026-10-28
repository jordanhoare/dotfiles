# dotfiles

Personal dotfiles for macOS, Linux, and WSL managed with [Nix](https://nixos.org) and [Home Manager](https://github.com/nix-community/home-manager).

Fresh machine? Bootstrap from [macOS](MacOS), [Linux](Linux), or [Windows](Windows).

## Updating

```bash
mise run up   # self-updates mise and flake.lock (winget apps on Windows), switches, and upgrades all other tools
mise tasks    # lists every repo task (`.mise/` replaced the Makefile, ADR 0016)
```

## Coding agents

`mise run switch` links the agent layer for Claude Code, Cursor and Codex ([ADR 0012](https://github.com/jordanhoare/dotfiles/blob/main/.claude/docs/adr/0012-agent-layer-for-claude-cursor-codex.md)). Two steps stay manual on each machine:

1. **Cursor:** paste `~/.claude/AGENTS.md` into Settings → Rules → User Rules, and again after it changes. Keep the third-party toggle on so Cursor imports the git guard.
2. **Codex:** trust `block-dangerous-git.sh` in `/hooks`.

## Adding tools

One installer per tool (ADR 0002). mise owns anything a project could pin: add it to `config/mise/config.toml` or the project's own `mise.toml`. Nix owns the rest: edit `nix/modules/base.nix` (or the platform module) and run `mise run switch`. Never install tools manually, and never declare one tool in both.

## Secrets

Each account's SSH Key item in Bitwarden carries two things: the SSH private key, and a hidden custom field named `pat` holding a classic GitHub PAT (scopes `repo`, `read:org`, `gist`, `workflow`). `mise run secrets` restores the keys, logs `gh` in to both accounts from those PATs (no browser), and decrypts every `*.sops` file.

```bash
mise run secrets               # restore SSH keys + gh PATs, then decrypt
mise run decrypt               # decrypt every *.sops file without the Bitwarden flow
sops edit <path>.sops          # add or change an encrypted file, then decrypt
```

Encrypted files are `*.sops` files in the package matching their target, encrypted to `~/.ssh/personal`: `config/git/private.sops` decrypts to `~/.config/git/private`, `home/.ssh/config.d/reliquia.sops` to `~/.ssh/config.d/reliquia`. A committed config includes each one and no-ops when it is missing.
