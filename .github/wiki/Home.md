# dotfiles

Personal dotfiles for macOS, Linux, and WSL managed with [Nix](https://nixos.org) and [Home Manager](https://github.com/nix-community/home-manager).

Fresh machine? Bootstrap from [macOS](MacOS), [Linux](Linux), or [Windows](Windows).

## Updating

```bash
up # updates flake.lock, switches, and upgrades all other tools
```

## Coding agents

`make switch` links the personal agent layer for Claude Code, Cursor and Codex: `~/.claude/AGENTS.md` and `~/.codex/AGENTS.md`, skills in `~/.claude/skills` and `~/.agents/skills`, and the git guard hook. Two steps stay manual on each machine:

1. **Cursor:** paste the contents of `~/.claude/AGENTS.md` into Cursor Settings → Rules → User Rules. Cursor keeps User Rules in its settings, not in a file, so re-paste after `AGENTS.md` changes. Leave "Include Third-Party Plugins, Skills, and Other Configs" on, so Cursor imports the git guard from `~/.claude/settings.json`.
2. **Codex:** run `/hooks` and trust the `block-dangerous-git.sh` hook. Codex skips a new or changed hook until it is trusted.

See [ADR 0012](https://github.com/jordanhoare/dotfiles/blob/main/.claude/docs/adr/0012-agent-layer-for-claude-cursor-codex.md).

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
