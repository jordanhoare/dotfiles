# Glossary

## Bootstrap

The process of provisioning a new machine. Run `make switch` twice - once to install tools, once after `make secrets` to link the decrypted git identity. On Windows: run winutil, import `windows/winget.json`, install WSL, then bootstrap inside WSL.

## Dotfile

A configuration file managed by this repository. Tracked dotfiles are symlinked into their target directory via Home Manager `home.file` - editing the file in the repo is immediately live.

## Dotfiles root

The canonical location of the dotfiles repository. Platform-specific: `~/repositories/dotfiles` on macOS and native Linux; `/mnt/d/repositories/dotfiles` on WSL. See ADR 0006.

## Flake

A self-contained Nix project with a `flake.nix` entry point and a committed `flake.lock` pinning all dependency versions. Lives at `nix/flake.nix` and defines one named Home Manager configuration per platform.

## Home Manager

The Nix tool that manages the user environment declaratively. Owns package installs (via nixpkgs) and dotfile symlinks (via `home.file`). Activated with `make switch`.

## Mise

The global runtime version manager. Manages Go, Python, dotnet, bun, opentofu, and other runtimes across all platforms. Switched on demand via `mise use --global <tool>@<version>`. Global config only at `~/.config/mise/config.toml`. See ADR 0002.

## Package

A top-level directory in the dotfiles repo whose files are linked into place by Home Manager `home.file`: `home/` (target: `~`), `config/` (target: `~/.config`), `bin/` (target: `~/bin`), `etc/` (target: `/etc`, Linux/WSL only, applied manually).

## Platform

The OS context in which the shell runs. Three supported platforms: **WSL** (primary), **Linux** (native, e.g. VMs), **macOS**. Each has a named configuration in `nix/flake.nix`.

## Profile

A git identity context - either **personal** (`jordanhoare`) or **private** (anon). Controls `user.name`, `user.email`, and the active `gh` CLI account.

Each Profile's identity lives in a single file at `~/.config/git/<profile>`, a git-config fragment with `[user]` and `[github]` sections. `config/git/config` loads the personal identity by default via `[include]`, and overrides to private inside the private-repos path via `[includeIf]`. The `git personal` and `git private` aliases switch the active identity by reading from these files. The Nix wiring lives in `nix/modules/profiles.nix`: the personal Profile is always linked (committed plaintext, not sensitive); the private Profile is linked only after `make secrets` has decrypted `config/git/private.enc`. Adding or replacing a Profile is one file change.

## Symlink

A filesystem pointer from a target path (e.g. `~/.zshrc`) to the corresponding file in the dotfiles repo. Managed by Home Manager `home.file`. Editing the repo file is immediately reflected in the live shell.
