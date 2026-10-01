# dotfiles

Personal dotfiles for macOS, Linux, and WSL managed with [Nix](https://nixos.org) and [Home Manager](https://github.com/nix-community/home-manager).

Fresh machine? Bootstrap from [macOS](MacOS), [Linux](Linux), or [Windows](Windows).

## Updating

```bash
up # updates flake.lock, switches, and upgrades all other tools
```

## Coding agents

`make switch` links the agent layer for Claude Code, Cursor and Codex ([ADR 0012](https://github.com/jordanhoare/dotfiles/blob/main/.claude/docs/adr/0012-agent-layer-for-claude-cursor-codex.md)). Two steps stay manual on each machine:

1. **Cursor:** paste `~/.claude/AGENTS.md` into Settings → Rules → User Rules, and again after it changes. Keep the third-party toggle on so Cursor imports the git guard.
2. **Codex:** trust `block-dangerous-git.sh` in `/hooks`.

## Adding tools

Edit `nix/modules/base.nix` (or the relevant platform module) and run `make switch`. Never install tools manually.

## Secrets

Each account's SSH Key item in Bitwarden carries two things: the SSH private key, and a hidden custom field named `pat` holding a classic GitHub PAT (scopes `repo`, `read:org`, `gist`, `workflow`). `make secrets` restores the keys, logs `gh` in to both accounts from those PATs (no browser), and decrypts the private git profile.

```bash
make secrets      # restore SSH keys + gh PATs + decrypt private profile
make encrypt      # re-encrypt after editing ~/.config/git/private
make decrypt      # decrypt the private profile without the full Bitwarden flow
```

The private git profile is sops-encrypted at `config/git/private.enc` against `~/.ssh/personal` and decrypts to `~/.config/git/private` (outside the repo). `config/git/config` picks it up via `[includeIf]` and silently no-ops when missing.
