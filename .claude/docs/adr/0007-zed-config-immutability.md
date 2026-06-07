# ADR 0007 - Zed config immutability

## Context

Zed's `settings.json`, `keymap.json`, `tasks.json`, and `snippets/` are managed by Home Manager via `home.file.<...>.source` in `nix/modules/zed.nix`. The targets resolve to paths inside `/nix/store`, which is read-only.

Zed occasionally writes back to `settings.json` from the UI - when a setting is changed via the settings UI, when an extension is auto-installed and recorded in `auto_install_extensions`, or when the user clicks a "save preference" prompt. Against a read-only target these writes fail silently and any UI-driven change is lost on the next Zed launch.

Two alternatives were considered:

1. **Copy-on-activation** via `home.activation` - copy the repo file to the target as a writable regular file. UI changes persist between switches.
2. **Hybrid** - copy `settings.json`, symlink the others.

## Decision

Keep all Zed config files as read-only symlinks. The repo at `config/zed/` is the single source of truth. UI-driven changes are intentionally ephemeral.

## Consequences

- Editing config requires editing files in `config/zed/` directly, not the Zed UI
- Every machine has byte-identical Zed config after `make switch` - no drift
- `make verify` can assert symlink targets exactly, not content equality
- `ls -la ~/.config/zed/` reveals the source path, making the wiring discoverable
- UI tweaks made during a session vanish on next Zed launch - accepted
- Extensions added by clicking "install" in Zed's UI do not persist; they must be added to `auto_install_extensions` in `config/zed/settings.json`
- If a future workflow requires UI-first config (e.g. accepting a Zed-managed setting that has no JSON equivalent), revisit and adopt copy-on-activation with a `bin/zed-sync` diff guard
