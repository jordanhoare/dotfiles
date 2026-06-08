# ADR 0009 - Arkenfox as the Firefox hardening baseline

## Status

Accepted (supersedes Betterfox Securefox decision)

## Context

Firefox's default settings leak telemetry, enable speculative connections, and offer weak tracker resistance. A `user.js` hardening preset is needed for all browser profiles.

Two presets were evaluated:

**Betterfox Securefox** - pragmatic hardening (previously used)

- Disables telemetry, crash reporting, studies, and speculative connections
- Does not cover newer Firefox features (AI/ML, on-device inference, genai)
- Rarely breaks sites; low maintenance
- Less comprehensive than arkenfox on network and fingerprinting hardening

**Arkenfox** - maximum hardening

- Comprehensive coverage: telemetry, network hardening, fingerprinting resistance, unsafe API removal
- Actively maintained against new Firefox releases
- Requires a `user-overrides.js` for personal adjustments and re-enabling needed APIs
- `privacy.resistFingerprinting` (RFP) is available but intentionally not enabled - RFP makes the fingerprint more unique outside a large anonymity set (e.g. Tor Browser), defeating its purpose for a personal browser

## Decision

Use **arkenfox `user.js`** as the hardening baseline for all browser profiles, with personal adjustments in `user-overrides.js`.

`config/firefox/arkenfox.js` is the upstream arkenfox `user.js` fetched verbatim. `config/firefox/user-overrides.js` contains personal overrides applied on top, following the standard arkenfox override pattern. Both files are concatenated via `programs.firefox.profiles.<name>.extraConfig` in `nix/modules/security.nix`.

`privacy.resistFingerprinting` is intentionally omitted from the overrides. The goal is strong telemetry and tracking resistance within the common hardened-Firefox population, not resistance against active fingerprinting adversaries.

## Consequences

- All browser profiles share the arkenfox base; per-profile differences live in `user-overrides.js`
- AI/ML features (on-device inference, chatbot, link preview, tab suggestions, translations) are explicitly disabled in `user-overrides.js`
- `arkenfox.js` should be periodically refreshed from upstream to track new Firefox releases
- Some sites may require per-site exceptions added to `user-overrides.js`
