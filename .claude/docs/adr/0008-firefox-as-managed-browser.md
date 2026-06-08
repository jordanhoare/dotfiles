# ADR 0008 - Firefox as the managed browser

## Status

Accepted

## Context

A privacy-focused browser is needed across macOS, Linux, and Windows that satisfies:

- Declarative management via nix and Home Manager
- Multiple isolated browser profiles (personal, private)
- Cross-platform extension parity
- Bitwarden and ProtonVPN extension support

Candidates evaluated:

| Browser | Eliminated because |
|---|---|
| LibreWolf | No `programs.librewolf` Home Manager module; no winget package for Windows; own updater conflicts with nix ownership |
| Mullvad Browser | Deliberately no profiles, no extensions - contradicts profile isolation requirement |
| Brave | Chromium base; no declarative profile management in nix; proprietary sync |

## Decision

Use **Firefox** managed via Home Manager's `programs.firefox` module.

On macOS, Firefox is installed as a Homebrew cask (`package = null` in the module) and Home Manager manages only the profile config at `~/Library/Application Support/Firefox/`. On Linux, Firefox is installed from nixpkgs. On WSL, Firefox is a Windows application outside nix scope.

## Consequences

- Browser profiles, extensions, containers, and `user.js` hardening are all declared in `nix/modules/firefox.nix`
- Reproducing the full browser environment on a new machine requires only `make switch`
- Firefox on macOS self-updates via its built-in updater - this is intentional. nixpkgs does not reliably package macOS GUI apps (code signing and notarization requirements); Homebrew is the correct owner of the binary on macOS, consistent with every other GUI app in the repo. nix owns the profile configuration layer only.
