# ADR 0009 — Package management and dotfile linking via Nix and Home Manager

## Context

The previous bootstrap design (ADR 0006) was never implemented. The existing setup requires three separate mechanisms to reach a configured state: stow for dotfile symlinks, Homebrew for macOS packages, and manual installs for Linux and WSL. This produces version drift between machines, hours of debugging on each new machine, and no reliable path for Linux or WSL provisioning.

Three specific problems drove this decision:

1. No declarative package list for Linux or WSL - only macOS had a Brewfile.
2. Tool versions differ between machines because nothing pins them.
3. GUI applications on Linux and macOS had no unified install path.

## Decision

Replace stow and Homebrew with Nix and Home Manager using Flakes. nix-darwin is added for macOS to manage system-level config and the one remaining Homebrew cask (Docker Desktop).

**Package management:** All CLI tools are declared in nixpkgs. `flake.lock` is committed, pinning every package version across all machines.

**Dotfile linking:** `home.file` replaces stow. Config files stay as raw files in the repo (`home/`, `config/`, `bin/`); Home Manager links them to their target paths. The edit-in-repo-see-it-live behaviour is preserved.

**Named configurations** in `flake.nix`:

- `jordan@macos` - imports `common.nix` + `macos.nix`
- `jordan@linux` - imports `common.nix` + `linux-base.nix` + `linux.nix`
- `jordan@wsl` - imports `common.nix` + `linux-base.nix` + `wsl.nix`

**macOS GUI apps:** nix-darwin manages Homebrew declaratively. `cleanup = "zap"` means any cask not declared in `macos.nix` is removed on the next rebuild. Docker Desktop is the sole cask - the only reason Homebrew remains on the machine. All other macOS GUI apps are in nixpkgs.

**Windows:** winget with a committed `windows/winget.json` covers Windows-native apps. winutil is a manual prerequisite for Windows tweaks before winget runs.

**`programs.*` modules are not used.** Config files are maintained as raw files, not generated from Nix expressions. This preserves the existing workflow - edit the file in the repo, the change is immediately live.

## Consequences

- `flake.lock` must be committed and updated deliberately (`nix flake update`)
- stow is removed as a dependency
- Homebrew is reduced to a nix-darwin-managed shim for Docker Desktop only - never run `brew install` directly
- Adding a new tool means editing the appropriate module and running `home-manager switch --flake ~/repositories/dotfiles#jordan@<platform>` (or `darwin-rebuild switch --flake ~/repositories/dotfiles` on macOS)
- ADR 0001 (stow) and ADR 0006 (staged bootstrap) are superseded by this ADR
