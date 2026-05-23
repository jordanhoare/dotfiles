# SOPS Encryption

The private git config is encrypted with [SOPS](https://github.com/getsops/sops) using the personal SSH key as the age recipient.

## Decrypt

```bash
sops --decrypt --output $DOTFILES/config/git/private $DOTFILES/config/git/private.enc
```

## Re-encrypt after editing

```bash
sops --encrypt --output $DOTFILES/config/git/private.enc $DOTFILES/config/git/private
```

## Requirements

- `sops` installed
- `SOPS_AGE_SSH_PRIVATE_KEY_FILE=~/.ssh/personal` set in environment (configured in `.zshenv`)
