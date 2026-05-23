# SOPS Runbook

SOPS encrypts individual values inside structured files (INI, YAML, JSON) so ciphertext is safe to commit. Only the holder of the recipient private key can decrypt.

Official docs: https://github.com/getsops/sops — SSH/age key support: https://github.com/getsops/sops?tab=readme-ov-file#encrypting-using-age

## Encrypted files

| File | Recipient key | Plaintext (gitignored, decrypts into repo) |
|---|---|---|
| `config/git/private.enc` | `~/.ssh/personal` | `config/git/private` |

`config/git/private` is gitignored plaintext that lives only in the repo. Stow symlinks `config/git/` → `~/.config/git/`, so `~/.config/git/private` resolves through that link — nothing is ever written directly to `~/.config/`.

## Environment variables

| Variable | Purpose |
|---|---|
| `SOPS_AGE_SSH_PRIVATE_KEY_FILE` | SSH private key to use for decrypt/encrypt |
| `SOPS_CONFIG` | Set to `/dev/null` to skip `.sops.yaml` auto-discovery |

## Decrypt

Handled automatically by bootstrap. Manual fallback:

```bash
SOPS_AGE_SSH_PRIVATE_KEY_FILE=~/.ssh/personal SOPS_CONFIG=/dev/null sops --decrypt --input-type ini --output-type ini ~/repositories/dotfiles/config/git/private.enc > ~/repositories/dotfiles/config/git/private
```

## Edit in-place

SOPS decrypts to a temp file, opens `$EDITOR`, re-encrypts on save:

```bash
SOPS_AGE_SSH_PRIVATE_KEY_FILE=~/.ssh/personal SOPS_CONFIG=/dev/null sops --input-type ini --output-type ini ~/repositories/dotfiles/config/git/private.enc
```

## Re-encrypt from plaintext

Use after editing `config/git/private` directly:

```bash
SOPS_AGE_SSH_PRIVATE_KEY_FILE=~/.ssh/personal SOPS_CONFIG=/dev/null sops --encrypt --input-type ini --output-type ini --age "$(cat ~/.ssh/personal.pub)" ~/repositories/dotfiles/config/git/private > ~/repositories/dotfiles/config/git/private.enc
```

## Verify

```bash
SOPS_AGE_SSH_PRIVATE_KEY_FILE=~/.ssh/personal SOPS_CONFIG=/dev/null sops --decrypt --input-type ini --output-type ini ~/repositories/dotfiles/config/git/private.enc
```

Output should show plaintext `[user]` and `[github]` fields.
