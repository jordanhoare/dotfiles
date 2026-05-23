# Glossary

## Bootstrap

The process of setting up a new machine from scratch. On macOS and Linux/WSL: install Nix, then run `home-manager switch --flake ~/repositories/dotfiles#jordan@<platform>`. On Windows: run winutil, import `windows/winget.json`, install WSL, then bootstrap inside WSL.

## Dotfile

A configuration file managed by this repository. Tracked dotfiles are symlinked into their target directory via Home Manager `home.file` — editing the file in the repo is immediately live.

## Dotfiles root

The canonical location of the dotfiles repository on any machine: `~/repositories/dotfiles`. Consistent across WSL, native Linux, and macOS.

## Flake

A self-contained Nix project with a `flake.nix` entry point and a committed `flake.lock` that pins all dependency versions. The dotfiles flake lives at `nix/flake.nix` and defines one named Home Manager configuration per platform.

## Home Manager

The Nix tool that manages the user environment declaratively. Owns package installs (via nixpkgs) and dotfile symlinks (via `home.file`). Activated per platform with `home-manager switch --flake ~/repositories/dotfiles#jordan@<platform>`.

## Mise

The global runtime version manager (`mise-en-place`). Manages installed versions of Go, Python, dotnet, bun, opentofu, and other runtimes across all platforms. Active version is switched on demand via `mise use --global <tool>@<version>`. No per-repo `.mise.toml` files — global config only at `~/.config/mise/config.toml`. See ADR 0004.

## Package

A top-level directory in the dotfiles repo whose files are linked into place by Home Manager `home.file`. Four packages: `home/` (target: `~`), `config/` (target: `~/.config`), `bin/` (target: `~/bin`), `etc/` (target: `/etc`, Linux/WSL only, manual). Files are never moved — Home Manager links them from their current location.

## Platform

The OS context in which the shell runs. Three supported platforms: **WSL** (Windows Subsystem for Linux, primary), **Linux** (native, e.g. VMs), **macOS**. Each has a named Home Manager configuration in `nix/flake.nix`.

## Profile

A git identity context — either **personal** (`jordanhoare`) or **private** (anon). Profiles control `user.name`, `user.email`, and the active `gh` CLI account.

## Symlink

A filesystem pointer from a target path (e.g. `~/.zshrc`) to the corresponding file in the dotfiles repo. Managed by Home Manager `home.file`. Editing the repo file is immediately reflected in the live shell.
