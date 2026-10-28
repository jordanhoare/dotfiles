# Context

## What this project is

Personal dotfiles for Jordan Hoare. The repository captures shell, terminal, git, and tooling configuration and provisions it onto a machine via Nix and Home Manager. The domain is **machine provisioning and environment configuration** - there is no runtime product, no end users beyond the maintainer.

## Domain

The repository solves one problem: bring a fresh machine to a known, fully-configured state, and keep that state consistent across every machine the maintainer uses. Configuration is the artifact; reproducibility and idempotence are the goals. `mise run apply` converges any supported OS to the configured state, and a fresh machine starts from one entry script that installs mise, clones, and runs `mise run bootstrap`. Editing a file in the repo takes effect immediately via Home Manager symlinks.

## Users

The maintainer, on WSL, native Linux, macOS, and native Windows.

The username is one constant in `nix/flake.nix`, passed to every module as an argument. A fork edits that constant. A machine without the maintainer's SSH keys never gets the private git identity, and nothing else changes.

On WSL every repository lives on the Windows drive so Windows toolchains can reach it (ADR 0006); worktrees stay on the Linux filesystem for speed (ADR 0013).

## In scope

- Shell, prompt, terminal, multiplexer, and plugin configuration
- Git identity separation (personal vs private profiles) and secret handling
- Machine provisioning and cross-platform consistency
- Declarative package management via Nix

## Out of scope

- Application or library code
- Machine-specific config that cannot be made reproducible across the three platforms
- Secrets in plaintext - encrypted or restored from Bitwarden, never committed

ADR 0004 says where each kind of document lives.
