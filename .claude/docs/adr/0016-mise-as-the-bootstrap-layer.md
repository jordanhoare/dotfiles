# ADR 0016 - mise as the bootstrap layer

## Context

A fresh machine should need one hand-installed program, after which the repo brings itself up on macOS, Linux, WSL and native Windows. The Makefile could not be that program: `make` came from Nix, so Nix had to be installed by hand first, and Windows has no `make` at all.

mise was also installed twice on Unix machines: once by Home Manager, once by whatever put a second binary on PATH. The two drifted. On Unix every shim is a symlink to whichever `mise` last ran `reshim`, so deleting either binary broke every shim, and the nixpkgs build disables `mise self-update` on purpose.

## Decision

- **mise tasks replace the Makefile and `bin/up`.** `.mise/config.toml` holds the Tasks and may hold a `[tools]` table for the tools the repo's own checks need, the same repo pin ADR 0002 sets for every repo. A tool that the baseline in `config/mise/config.toml` also declares takes the baseline's version, so `mise run bootstrap` and `mise run upgrade` from the repo root still cover the baseline. The file never holds `[env]`, which would reach every task; a task that needs a variable sets its own `env`. A task in the TOML is one line; anything longer is a script in `.mise/tasks/`, a `.sh` file paired with a `.ps1` file where Windows needs a body. `mise run bootstrap` is the one command on every platform.
- **mise installs itself.** `https://mise.run` on macOS, Linux and WSL, `winget install jdx.mise` on Windows. Home Manager does not install mise. This is the one named exception to ADR 0005: the mise version floats and `mise run upgrade` runs `mise self-update`.
- **Entry scripts do only pre-clone work.** `install.sh` installs the Xcode Command Line Tools on macOS or `git` and `curl` on Debian-family Linux, installs mise, clones the repo to the Dotfiles root, and runs `mise run bootstrap`. `install.ps1` does the same with winget, and also installs PowerShell 7, because mise runs every `.ps1` task through `pwsh` and a task cannot install the shell that runs tasks. Neither holds logic a task could hold.
- **Nix stays the package and symlink layer.** The `nix` task installs it with the Determinate installer and `--no-confirm`, and skips when `/nix` already holds a profile. On WSL the task installs the repo's `etc/wsl.conf` when systemd is not running and exits asking for `wsl --shutdown`; the second run installs Nix.
- **Windows `apply` runs `win/apply.ps1`** through `run_windows`, the former Make-era bootstrap script under its new name.
- **Four visible Tasks: `bootstrap`, `apply`, `upgrade`, `secrets`.** Every other Task (`nix`, `tools`, `hooks`, `decrypt`, the per-OS `apply:*` bodies, the checks) is hidden, because it exists to be called by another Task or by CI. `apply` installs the git hooks after activation, and `upgrade` pulls the current branch before it updates anything, refusing a tree with uncommitted changes.

## Considered options

- **Nix keeps owning mise, with a throwaway bootstrap binary deleted after `apply`.** Keeps the `flake.lock` pin. Rejected: it leaves a window with two binaries and a cleanup step that reshims from the survivor, and one failed cleanup recreates the fault this ADR removes.
- **`mise bootstrap` with `[bootstrap.packages]` and `[dotfiles]` in place of Home Manager.** Matches the stated goal literally. Rejected: it duplicates Home Manager and nix-darwin, drops the `flake.lock` pin, and the feature changes monthly. Revisit if Nix is dropped on a platform.
- **Keep Make.** Rejected: absent on Windows and dependent on Nix being installed first.

## Consequences

- `gnumake`, `just`, `mise` and `sops` leave `nix/modules/base.nix`. `sops` is installed by mise alone.
- An existing machine migrates by installing mise from `mise.run`, running `mise run apply` so Home Manager drops its mise, then `mise reshim` so the shims point at the surviving binary.
- Nix on every Unix machine is Determinate Nix. macOS already set `nix.enable = false` in nix-darwin for that reason.
- The headless Xcode Command Line Tools install uses the `softwareupdate` route from Homebrew's installer, which Apple does not document. `install.sh` falls back to `xcode-select --install` when it fails.
- `mise run` installs every missing tool in the repo's `[tools]` before the first task runs, and on a fresh machine the baseline is not linked yet. A repo tool that needs another tool to install, such as a pip-backed linter that needs `uv`, fails `mise run bootstrap` before Nix is installed. Repo tools must not block bootstrap.
- Research behind this decision: `.claude/docs/research/2026-10-27-mise-bootstrap.md` and `.claude/docs/research/2026-10-27-mise-repo-tool-pins.md`.
