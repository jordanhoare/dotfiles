# ADR 0009 - Betterfox Securefox as the Firefox hardening baseline

## Status

Accepted

## Context

Firefox's default settings leak telemetry, enable speculative connections, and offer weak tracker resistance. A `user.js` hardening preset is needed for both browser profiles.

Two presets were evaluated:

**Arkenfox** - maximum hardening

- Enables `privacy.resistFingerprinting` (RFP), which normalises canvas, fonts, timezone, and screen resolution
- Breaks sites regularly; requires maintaining a `user-overrides.js` to restore needed APIs
- Paradox: RFP makes the browser fingerprint _more_ unique because very few users run it, defeating its purpose outside a large anonymity set (e.g. Tor Browser)

**Betterfox Securefox** - pragmatic hardening

- Disables all telemetry, crash reporting, studies, and speculative connections
- Hardens SSL/TLS, disables unsafe APIs, enforces strict content blocking
- Does not enable RFP - fingerprint stays within the common Firefox + uBlock Origin population
- Rarely breaks sites; no override maintenance required

## Decision

Use **Betterfox Securefox** as the `user.js` baseline for both browser profiles.

RFP is intentionally omitted. The goal is 80:20 privacy improvement - strong telemetry and tracking resistance - not resistance against active fingerprinting adversaries, which would require Tor Browser to be effective.

## Consequences

- Both profiles share the same `user.js` base; per-profile overrides are minimal
- No ongoing maintenance burden from broken sites
- Fingerprint is indistinguishable from a typical hardened Firefox user, which is a large population
