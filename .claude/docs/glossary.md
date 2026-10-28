# Glossary

## Arkenfox

The upstream [arkenfox/user.js](https://github.com/arkenfox/user.js) hardening preset, committed verbatim at `config/firefox/arkenfox.js` and applied under `config/firefox/user-overrides.js`. `privacy.resistFingerprinting` stays off: it marks the browser as unique outside a large anonymity set.

## Bootstrap

Provisioning a fresh machine: the Entry script installs git and Mise, clones to the Dotfiles root, and runs the `bootstrap` Task, which installs Nix, runs `apply`, and installs the baseline runtimes. `mise run secrets` follows by hand and decrypts every [Sops file](#sops-file). On Windows, `apply` runs the Windows bootstrap.

## Browser Profile

An isolated Firefox instance with its own history, credentials, and extensions, declared under `programs.firefox.profiles`. Distinct from a git Profile.

## Dotfile

A configuration file this repository owns. Home Manager symlinks it into place, so an edit in the repo is live at once.

## Dotfiles root

Where the repository is cloned: `~/repositories/dotfiles` on macOS and native Linux, `/mnt/d/repositories/dotfiles` on WSL, `D:\repositories\dotfiles` on Windows.

## Entry script

`install.sh` or `install.ps1`, fetched with `curl | sh` or `irm | iex` on a fresh machine. It does only what must happen before the clone exists and then hands off to the `bootstrap` Task. Distinct from a Task, which runs inside the clone.

## Flake

The Nix project at `nix/flake.nix`, with `flake.lock` pinning every input. It defines one configuration per Platform.

## Home Manager

The Nix tool that installs user packages and links Dotfiles. Activated by `mise run apply`. It never installs Mise.

## Mise

The runtime manager and Task runner, and the one program installed by hand. `config/mise/config.toml` (`win/mise.toml` on Windows) is the baseline of runtimes wanted in every shell; a project's own `mise.toml` outranks it for the tools that project pins.

## Package

A top-level repo directory whose files are linked into place: `home/` to `~`, `config/` to `~/.config`, `bin/` to `~/bin`, `etc/` to `/etc`, written once by the `nix` Task on WSL and by hand elsewhere.

## Platform

The OS a shell runs on: WSL, native Linux, macOS, or Windows. The first three have a configuration in the Flake; Windows has the Windows bootstrap.

## ProtonVPN

The VPN client on WSL, Linux, and macOS, run as a system daemon with the standard kill switch: internet is blocked when the tunnel drops, LAN traffic is not.

## Profile

A git identity, either **personal** (`jordanhoare`) or **private** (anonymous), held as a config fragment at `~/.config/git/<profile>` with `[user]` and `[github]` sections. `config/git/config` includes personal by default and private inside the private paths, as both WSL and native Windows see them. `git personal` and `git private` copy a Profile into the current repo and switch the `gh` account to match. The personal fragment is committed plaintext; the private one is the [Sops file](#sops-file) `config/git/private.sops`, decrypted by `mise run secrets` straight to `~/.config/git/private`, so the private username never enters the repo or the Nix store.

## Task

A repo operation under `.mise/`, run with `mise run <name>` and listed by `mise tasks`. Four are visible: `bootstrap`, `apply`, `upgrade`, `secrets`; a Task that only another Task or CI calls is hidden. One-liners live in `.mise/config.toml`; longer ones are scripts in `.mise/tasks/` with a `.ps1` pair when Windows needs one. `.mise/config.toml` never holds `[env]`.

## Sops file

A committed `*.sops` file, encrypted whole to the personal SSH key, that `mise run decrypt` writes to the target its Package gives: `home/<path>.sops` to `~/<path>`, `config/<path>.sops` to `~/.config/<path>`. Unlike a Dotfile, it is never linked by Home Manager; a committed config includes the decrypted copy instead. See ADR 0017.

## Symlink

A pointer from a live path to a file in the repo. Home Manager creates them on Linux, WSL, and macOS; `win/apply.ps1` creates them on Windows.

## Windows bootstrap

`win/apply.ps1`, the Windows body of the `apply` Task. It needs no Nix or WSL: it runs `winget import` against `win/winget.json`, then links or copies the managed configs into `%APPDATA%` and `%USERPROFILE%`. A real file at a link target is moved to `<name>.bak.<timestamp>`. Symlinks need an elevated shell or Developer Mode; the script checks and exits with a hint otherwise.
