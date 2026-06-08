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

Use **Firefox** managed entirely via Home Manager's `programs.firefox` module on all platforms.

On macOS, Firefox is installed from nixpkgs via `programs.firefox` (not as a Homebrew cask). Home Manager wraps the package to bake `policies.json` directly into the app bundle's `distribution/` directory - the only path the Nix-packaged Firefox reads for enterprise policies. The wrapped `.app` is copied to `~/Applications/` via a `home.activation` script so Spotlight and Launchpad can find it.

On Linux, Firefox is installed from nixpkgs directly. On WSL, Firefox is a Windows application outside nix scope.

Enterprise policies are declared in `nix/modules/security.nix` under `programs.firefox.policies` and cover: telemetry suppression, first-run UI suppression, and force-installation of extensions.

## Consequences

- Browser profiles, extensions, and `user.js` hardening are all declared in `nix/modules/security.nix`
- Reproducing the full browser environment on a new machine requires only `make switch`
- Firefox auto-updates are disabled via policy (`DisableAppUpdate`) - nix owns the binary version
- The Nix-packaged Firefox sets `MOZ_SYSTEM_DIR` to a read-only nix store path, so `/Library/Application Support/Mozilla/` is not read on macOS - policies must be baked into the app bundle
- Extensions are force-installed silently on first launch via enterprise policy; no user interaction required
