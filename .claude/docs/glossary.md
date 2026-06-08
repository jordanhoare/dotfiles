# Glossary

## Betterfox Securefox

The hardening preset applied to all Firefox browser profiles via `user.js`. Drawn from the [Betterfox](https://github.com/yokoffing/Betterfox) project's `Securefox` section. Disables telemetry, speculative connections, and unsafe defaults without enabling `privacy.resistFingerprinting` (which would make the browser fingerprint uniquely identifiable). See ADR 0009.

## Bootstrap

The process of provisioning a new machine. Run `make switch` twice - once to install tools, once after `make secrets` to link the decrypted git identity. On Windows: run winutil, import `win/winget.json`, install WSL, then bootstrap inside WSL.

## Browser Profile

A fully isolated Firefox instance with its own process, cookie store, history, credentials, and extensions. Distinct from a git Profile. Two browser profiles are declared: **personal** (default, daily driver) and **private** (anonymised, separate identity). Managed declaratively via `programs.firefox` in Home Manager. See ADR 0008.

## Container

A tab-level isolation context within a single Firefox browser profile. Each container has its own cookie store and login state but shares the same process and extension set as the parent browser profile. Used within the personal browser profile for contextual separation (Personal, Work, Banking, Shopping). Not a substitute for a browser profile - containers isolate sites, profiles isolate identities.

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

## ProtonVPN

The VPN client installed on all platforms. Runs as an OS-level daemon covering all machine traffic. Configured with a standard kill switch (blocks internet if the tunnel drops, but permits LAN traffic). Installed declaratively via nix. See ADR 0010.

## Profile

A git identity context - either **personal** (`jordanhoare`) or **private** (anon). Controls `user.name`, `user.email`, and the active `gh` CLI account.

Each Profile's identity lives in a single file at `~/.config/git/<profile>`, a git-config fragment with `[user]` and `[github]` sections. `config/git/config` loads the personal identity by default via `[include]`, and overrides to private inside the private-repos path via `[includeIf]`. The `git personal` and `git private` aliases switch the active identity by reading from these files. The Nix wiring lives in `nix/modules/profiles.nix`: the personal Profile is always linked (committed plaintext, not sensitive); the private Profile is linked only after `make secrets` has decrypted `config/git/private.enc`. Adding or replacing a Profile is one file change.

## Symlink

A filesystem pointer from a target path (e.g. `~/.zshrc`) to the corresponding file in the dotfiles repo. Managed by Home Manager `home.file`. Editing the repo file is immediately reflected in the live shell.
