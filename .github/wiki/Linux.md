# Linux

## 1. Install

One command. It installs git and curl, installs mise, clones the repo to `~/repositories/dotfiles`, then runs `mise run bootstrap`: Nix via the Determinate installer, the Home Manager activation, and the baseline runtimes. Expect sudo prompts.

```bash
curl -fsSL https://raw.githubusercontent.com/jordanhoare/dotfiles/main/install.sh | sh
```

Open a new shell afterwards.

## 2. Restore secrets

Logs in to Bitwarden, restores both SSH keys, and decrypts the private git profile to `~/.config/git/private`.

```bash
mise run secrets
```

## 3. Swap remote to SSH

```bash
git remote set-url origin git@personal:jordanhoare/dotfiles.git
```

Done. See [Home](Home) for updating, identity switching, and other daily ops. ADR 0016 covers why mise is the only hand-installed program.
