# dotfiles

Personal dotfiles for macOS, Linux, and WSL managed with [Nix](https://nixos.org) and [Home Manager](https://github.com/nix-community/home-manager).

Fresh machine? Bootstrap from [macOS](MacOS), [Linux](Linux), or [Windows](Windows).

## Updating

```bash
up # updates flake.lock, switches, and upgrades all other tools
```

## Adding tools

Edit `nix/modules/base.nix` (or the relevant platform module) and run `make switch`. Never install tools manually.

## Secrets

SSH keys live in Bitwarden as SSH Key items. The private git profile is sops-encrypted at `config/git/private.enc` against `~/.ssh/personal`.

```bash
make secrets      # restore SSH keys + decrypt private profile to ~/.config/git/private
make encrypt      # re-encrypt after editing ~/.config/git/private
make decrypt      # decrypt without the full Bitwarden flow
```

The decrypted private profile lives at `~/.config/git/private` (outside the repo). `config/git/config` picks it up via `[includeIf]` and silently no-ops when missing.
