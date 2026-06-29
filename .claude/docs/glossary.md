# Glossary

## Arkenfox

The hardening preset applied to all Firefox browser profiles via `user.js`. The upstream [arkenfox/user.js](https://github.com/arkenfox/user.js) is committed verbatim at `config/firefox/arkenfox.js` and concatenated with `config/firefox/user-overrides.js` (personal adjustments) via `programs.firefox.profiles.<name>.extraConfig`. `privacy.resistFingerprinting` is intentionally left off - it would make the browser fingerprint uniquely identifiable outside a large anonymity set. See ADR 0008.

## Bootstrap

The process of provisioning a new machine. Linux, WSL, and macOS run `make switch` to install tools and link dotfiles, then `make secrets` to restore SSH keys, log `gh` in to each account from the PATs in Bitwarden, and decrypt the private git identity. A single `make switch` suffices - the private identity is decrypted outside the repo to `~/.config/git/private` and picked up at runtime via `[includeIf]`. Windows runs `winutil` interactively for one-time debloat, then `.\win\bootstrap.ps1` from elevated PowerShell to import apps via `winget` and link the Windows-side editor configs (see [Windows bootstrap](#windows-bootstrap)).

## Browser Profile

A fully isolated Firefox instance with its own process, cookie store, history, credentials, and extensions. Distinct from a git Profile. Two browser profiles are declared: **personal** (default, daily driver) and **private** (anonymised, separate identity). Managed declaratively via `programs.firefox` in Home Manager. See ADR 0008.

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

Each Profile's identity lives in a single file at `~/.config/git/<profile>`, a git-config fragment with `[user]` and `[github]` sections. `config/git/config` loads the personal identity by default via `[include]`, and overrides to private inside the private-repos path via `[includeIf]`. The `git personal` and `git private` aliases switch the active identity by reading from these files and switching the active `gh` account; the `gh` step warns rather than fails if `gh` is not yet authenticated. The personal Profile is committed plaintext and linked by Nix (`nix/modules/profiles.nix`); it is not sensitive. The private Profile is sops-encrypted at `config/git/private.enc` and decrypted by `make secrets` directly to `~/.config/git/private`, outside the repo and outside the world-readable Nix store - so the private username never lands anywhere tracked or shared.

## Symlink

A filesystem pointer from a target path (e.g. `~/.zshrc`) to the corresponding file in the dotfiles repo. On Linux/WSL/macOS, managed by Home Manager `home.file`. On Windows, managed by `win/bootstrap.ps1` using per-file repo-rooted symlinks (e.g. `%APPDATA%\Zed\settings.json -> D:\repositories\dotfiles\config\zed\settings.json`). In both cases, editing the repo file is immediately reflected in the live application. See also [Windows bootstrap](#windows-bootstrap).

## Windows bootstrap

The Windows-side activation script at `win/bootstrap.ps1`. Counterpart to `make switch` on Linux/WSL/macOS, but intentionally nix-agnostic - it runs without Nix, WSL, or any of the Linux toolchain installed. Does two things: (1) imports declared apps via `winget import --import-file win/winget.json`, (2) creates per-file repo-rooted symlinks for the four managed Zed files (`settings.json`, `keymap.json`, `tasks.json`, `snippets/`). Idempotent: re-running is safe; pre-existing real files at a target path are moved to `<name>.bak.<timestamp>` rather than clobbered. Requires elevated PowerShell or Windows Developer Mode for symlink creation; the script checks this precondition and exits cleanly with a hint if neither is set. See ADR 0011.
