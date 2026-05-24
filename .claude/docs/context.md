# Context

## What this project is

Personal dotfiles for Jordan Hoare. The repository captures shell, terminal, git, and tooling configuration and provisions it onto a machine via GNU stow symlinks. The domain is **machine provisioning and environment configuration**, not application software - there is no runtime product, no end users beyond the maintainer.

## Domain

The repository solves one problem: bring a fresh machine to a known, fully-configured state, and keep that state consistent across every machine the maintainer uses. Configuration is the artifact; reproducibility and idempotence are the goals. Bootstrap converges a bare OS to the configured state; stow keeps individual config files live by symlink so edits in the repo take effect immediately.

## Users

A single user - the maintainer - operating across three platforms: WSL (primary), native Linux (VMs), and macOS. Anything written here should assume that audience. There is no multi-tenant, no external consumer, no support surface.

On WSL all repositories including dotfiles live at `/mnt/d/repositories/`. Large project repos are cross-compiled or Windows-targeted, requiring native Windows filesystem access. The git performance cost of the 9P layer is an accepted tradeoff. See ADR 0010.

## In scope

- Shell, prompt, terminal, multiplexer, and plugin configuration
- Git identity separation (personal vs private profiles) and its secret handling
- Bootstrap and provisioning of a new machine
- Cross-platform consistency of the above

## Out of scope

- Application or library code (this is configuration, not a program)
- Anything machine-specific that cannot be made reproducible across the three platforms
- Secrets in plaintext - these are encrypted or restored from a password manager, never committed

## Where to look next

- **Vocabulary:** `docs/internal/glossary.md` - the canonical term list. Use these words; do not drift to synonyms it marks as avoid.
- **Decisions:** `docs/internal/adr/` - architectural decision records explaining why the tooling and layout are the way they are.
- **Operational instructions:** the root `CLAUDE.md` - how to actually work in the repo (commands, file layout, gotchas).
