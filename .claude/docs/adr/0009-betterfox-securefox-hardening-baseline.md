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
- `arkenfox.js` should be periodically refreshed from upstream to track new Firefox releases
- Some sites may require per-site exceptions added to `user-overrides.js`

### Locked override decisions

The following deviations from arkenfox defaults are deliberate and live in `config/firefox/user-overrides.js`:

- **AI/ML off** - on-device inference, chatbot, link preview, smart tab groups, translations, and genai summarise/chat are all disabled
- **Sanitize on shutdown** - cookies and history persist across restarts; only cache, form data, and open windows are wiped. Trackers are handled by ETP strict + uBlock Origin rather than a full nuke
- **DNS-over-HTTPS disabled** (`network.trr.mode=5`) - DNS resolution flows through the OS resolver into the ProtonVPN tunnel (ADR 0010). Avoids splitting trust across a second DoH provider and prevents Firefox bypassing the VPN before the kill-switch engages on network change
- **Built-in password manager disabled** - Bitwarden is the sole credential store (force-installed via policy in ADR 0008). Eliminates double-storage and "save password?" prompts
- **HTTPS-only on, OCSP soft-fail** - hard-fail OCSP breaks captive portals on travel; CRLite covers revocation for major CAs. Loopback is exempt from HTTPS upgrades, so localhost dev is unaffected
- **Search suggestions off** - no live keystroke stream to the default search engine. Quicksuggest, trending, weather, recent searches, and topsites are explicitly killed in case Mozilla flips defaults
- **Fresh launch each time** (`browser.startup.page=1`) - tabs do not restore; home and new tab are `about:blank`. Cookies and history still persist (see shutdown decision above)
- **WebRTC left enabled** - arkenfox's `ice.default_address_only=true` plus the VPN exit IP bound the leak. Disabling outright would break browser video calls and get flipped back the first time it bit
- **ETP pinned to strict** (`browser.contentblocking.category="strict"`) - arkenfox sets `cookieBehavior=5` but not the category; this pins the UI state
- **Cookie banners auto-rejected** in normal and private windows
- **Pocket and Firefox form autofill (addresses, credit cards) disabled**
- **DRM (`media.eme.enabled`) left at Firefox default** - streaming services would otherwise break
