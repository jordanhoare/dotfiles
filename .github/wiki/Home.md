# dotfiles

Personal dotfiles for macOS, Linux, and WSL managed with [Nix](https://nixos.org) and [Home Manager](https://github.com/nix-community/home-manager).

Fresh machine? Bootstrap from [macOS](MacOS), [Linux](Linux), or [Windows](Windows).

## Updating

```bash
mise run up   # self-updates mise, updates flake.lock, switches, and upgrades all other tools
mise tasks    # lists every repo task (`.mise/` replaced the Makefile, ADR 0016)
```

## Coding agents

`mise run switch` links the agent layer for Claude Code, Cursor and Codex ([ADR 0012](https://github.com/jordanhoare/dotfiles/blob/main/.claude/docs/adr/0012-agent-layer-for-claude-cursor-codex.md)). Two steps stay manual on each machine:

1. **Cursor:** paste `~/.claude/AGENTS.md` into Settings → Rules → User Rules, and again after it changes. Keep the third-party toggle on so Cursor imports the git guard.
2. **Codex:** trust `block-dangerous-git.sh` in `/hooks`.

## Adding tools

One installer per tool (ADR 0002). mise owns anything a project could pin: add it to `config/mise/config.toml` or the project's own `mise.toml`. Nix owns the rest: edit `nix/modules/base.nix` (or the platform module) and run `mise run switch`. Never install tools manually, and never declare one tool in both.

## Secrets

Each account's SSH Key item in Bitwarden carries two things: the SSH private key, and a hidden custom field named `pat` holding a classic GitHub PAT (scopes `repo`, `read:org`, `gist`, `workflow`). `mise run secrets` restores the keys, logs `gh` in to both accounts from those PATs (no browser), and decrypts the private git profile.

```bash
mise run secrets  # restore SSH keys + gh PATs + decrypt private profile
mise run encrypt  # re-encrypt after editing ~/.config/git/private
mise run decrypt  # decrypt the private profile without the full Bitwarden flow
```

The private git profile is sops-encrypted at `config/git/private.enc` against `~/.ssh/personal` and decrypts to `~/.config/git/private` (outside the repo). `config/git/config` picks it up via `[includeIf]` and silently no-ops when missing.
