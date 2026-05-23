# git config

`private` is gitignored plaintext — symlinked to `~/.config/git/private` via stow.
`private.enc` is the SOPS-encrypted version committed to the repo.

## Refresh

```bash
sops --encrypt --output $DOTFILES/config/git/private.enc $DOTFILES/config/git/private
```

## Decrypt

```bash
sops --decrypt --output $DOTFILES/config/git/private $DOTFILES/config/git/private.enc
```
