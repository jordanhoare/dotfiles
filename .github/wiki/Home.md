# dotfiles

Personal dotfiles for macOS, Linux, Windows, and WSL. [Nix](https://nixos.org) and [Home Manager](https://github.com/nix-community/home-manager) own packages and symlinks, [mise](https://mise.jdx.dev) owns runtimes and repo tasks, and [winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/) owns Windows apps.

Fresh machine? Start at [macOS](MacOS), [Linux](Linux), or [Windows](Windows).

## Updating

```bash
mise run apply    # install packages, link dotfiles, install git hooks
mise run upgrade  # pull the merged renovate bumps, apply, then upgrade the unpinned tools
mise tasks        # list the four tasks; --hidden shows the steps they call
```

[Renovate](https://docs.renovatebot.com) owns every pin. It opens a pull request for `nix/flake.lock`, the mise tool tables and the GitHub Actions, CI builds it, and `mise run upgrade` pulls what merged. Nothing in the repo is bumped by hand.

## Tools

One installer per tool. mise owns anything a project could pin, declared in `config/mise/config.toml` or a project's own `mise.toml`. Nix owns the rest, declared under `nix/modules/` and activated by `mise run apply`. Never install by hand, and never declare one tool in both.

## Identity

Two git profiles: `personal` by default, and a private one that repos under `D:\repositories\private\` pick up on Windows and WSL.

```bash
git personal   # switch identity and gh account
git private    # switch to the private profile
```

## Secrets

Private keys never enter the repo. Bitwarden holds each account's SSH key and a GitHub PAT. `mise run secrets` restores the keys, logs `gh` in from the PATs, and decrypts every `*.sops` file. An encrypted file is a [sops](https://getsops.io) file in the package matching its target, so `config/git/private.sops` decrypts to `~/.config/git/private`, encrypted to the personal SSH key. A committed config includes each one and no-ops when it is missing.

```bash
mise run secrets        # restore keys and gh logins, then decrypt
mise run decrypt        # decrypt only, a hidden task for after `sops edit`
sops edit <path>.sops   # add or change an encrypted file, then decrypt
```
