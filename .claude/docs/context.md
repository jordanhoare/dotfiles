# Context

## What this project is

Personal dotfiles for Jordan Hoare. The repository captures shell, terminal, git, and tooling configuration and provisions it onto a machine via Nix and Home Manager. The domain is **machine provisioning and environment configuration** - there is no runtime product, no end users beyond the maintainer.

## Domain

The repository solves one problem: bring a fresh machine to a known, fully-configured state, and keep that state consistent across every machine the maintainer uses. Configuration is the artifact; reproducibility and idempotence are the goals. `make switch` converges any supported OS to the configured state. Editing a file in the repo takes effect immediately via Home Manager symlinks.

## Users

The primary user is the maintainer, operating across three platforms: WSL (primary), native Linux (VMs), and macOS. The configuration is **user-agnostic**: identity (`home.username`, `home.homeDirectory`) is derived from the environment at activation time rather than hardcoded, so anyone can clone and run it unedited - including on a work laptop where the username and home directory are not controlled by the maintainer. A user without the maintainer's SSH keys simply does not get the private git identity linked (gated by `builtins.pathExists` on the decrypted secret); nothing else is affected. Identity derivation requires `--impure`; the impurity is quarantined to a single point in `nix/flake.nix` and the modules receive identity as explicit parameters via `extraSpecialArgs`. Committed fallbacks keep pure `nix flake check` working.

On WSL all repositories including dotfiles live at `/mnt/d/repositories/`. Project repos are cross-compiled or Windows-targeted, requiring native Windows filesystem access. The git performance cost of the 9P layer is an accepted tradeoff. See ADR 0006.

## In scope

- Shell, prompt, terminal, multiplexer, and plugin configuration
- Git identity separation (personal vs private profiles) and secret handling
- Machine provisioning and cross-platform consistency
- Declarative package management via Nix

## Out of scope

- Application or library code
- Machine-specific config that cannot be made reproducible across the three platforms
- Secrets in plaintext - encrypted or restored from Bitwarden, never committed

## Where to look

- **Vocabulary:** `.claude/docs/glossary.md` - canonical terms; do not drift to synonyms
- **Decisions:** `.claude/docs/adr/` - why the tooling and layout are the way they are
- **Operations:** `CLAUDE.md` - commands, file layout, rules for working in this repo
