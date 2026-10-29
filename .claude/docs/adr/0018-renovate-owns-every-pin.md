# ADR 0018 - Renovate owns every pin

## Context

`mise run up` ran `nix flake update` and `mise upgrade` on whichever machine typed it. The new `flake.lock` and tool tables reached the other three Platforms through a commit nobody built, and a bad bump showed up as a dirty tree on one laptop and a broken `apply` on the next. Pins are shared repo state, so they should change where CI can build them and a person can review them.

## Decision

- **Renovate opens a pull request for every Pin.** Self-hosted from `.github/workflows/renovate.yml` on a daily cron, under the global config `.github/renovate-config.json5`, with a fine-grained token in the `production` environment so its pull requests run `ci` and auto-merge. The file is not named `renovate.json5`, which Renovate would read a second time as repository config.
- **Four managers, nothing else.** `nix` for `flake.lock` through weekly lock file maintenance alone, since the inputs track branches on purpose; `mise` for the three `[tools]` tables; `github-actions` with digest pins; `pre-commit` for the remote hook revisions. The `github-actions` manager also reads `renovate-version` as the tag of the image the action pulls, so no regex manager is needed. Everything else is off, so a stray manifest under `config/` never opens a pull request.
- **Policy.** Lock file maintenance, action digests, and patch or minor tool bumps auto-merge once `ci` is green. A major, or a 0.x minor, which semver lets break the same way, is never automerged: tool majors arrive one pull request each, action majors as one grouped pull request, and only a person merges them. Every bump waits three days after release, so a yanked release never lands. Commits are `chore(deps)`.
- **Every mise Pin is a full version.** Renovate writes `0.12.0` where it finds `0.11`, so the tables would otherwise drift into a mix of floating and fixed pins. With Renovate carrying patches, floating them bought nothing.
- **`ci` resolves every baseline Pin.** No job installs the baseline, so `check:pins` runs `mise latest` for each entry in `config/mise/config.toml` and `win/mise.toml` and fails when one does not resolve, or when the Windows table drifts from the baseline minus its three documented exceptions.
- **`upgrade` never writes a tracked file.** It refuses a dirty tree, pulls `main` fast-forward, applies, installs, then refreshes the tools no file pins. It never commits or opens a pull request; that stays with the person.

## Considered options

- **A prompt inside `upgrade`.** Adds friction without a build; the bump still reaches the other Platforms unbuilt.
- **DeterminateSystems/update-flake-lock.** Covers `flake.lock` only, as one more workflow to maintain.
- **Dependabot.** Supports flakes and actions, but has no mise ecosystem, and opens one pull request per flake input instead of one lock refresh.
- **Floating pins, no bot.** A floating pin moves no faster: it still waits for a machine to run `upgrade`, and nothing records what a machine runs.

## Consequences

- Repository settings outside the repo: auto-merge on, squash as the one merge method, a ruleset on `main` that requires `ci`, and the `production` environment holding `RENOVATE_TOKEN`.
- A security patch arrives with the next weekly pull request. Renovate's vulnerability alerts cover OSV ecosystems, not mise's github backend or nixpkgs, so the schedule window is the only lever on latency.
- `zizmor` runs its default `hash-pin` policy, since every `uses:` carries a digest.
- Research behind this decision: `.claude/docs/research/2026-10-29-renovate-pins.md`.
