# Linux

## 1. Install

Installs git, curl, mise, and Nix, clones the repo to `~/repositories/dotfiles`, and activates Home Manager. Expect sudo prompts.

```bash
curl -fsSL https://raw.githubusercontent.com/jordanhoare/dotfiles/main/install.sh | sh
```

Open a new shell afterwards.

## 2. Restore secrets

Logs in to Bitwarden, restores both SSH keys, and decrypts every `*.sops` file to its target.

```bash
mise run secrets
```

## 3. Swap remote to SSH

```bash
git remote set-url origin git@personal:jordanhoare/dotfiles.git
```

Done. See [Home](Home) for updating, identity switching, and other daily ops.
