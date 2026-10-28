# Can Renovate own every pin in this repo?

Date: 2026-10-29. No ticket; the grill behind ADR 0018.

Question: a plan hands `nix/flake.lock`, the three mise `[tools]` tables and the GitHub
Actions to Renovate, and reduces `mise run upgrade` to pull-and-apply. Does Renovate's
`nix` manager update every flake input, does its `mise` manager match the three tables
and the short pins in them, do digest pins satisfy zizmor, and is the self-hosted
workflow from `jordanhoare/portal` the right shape?

Sources are primary only: docs.renovatebot.com at Renovate 44.192.2 and the
`renovatebot/renovate` source on `main`, `renovatebot/github-action` 46.3.10,
`containerbase/base`, the zizmor docs, the GitHub docs for Dependabot, and the
`DeterminateSystems/update-flake-lock` readme. Claims marked **derived** come from
reading source, not a doc sentence.

## Summary

- **The `nix` manager covers every direct input through lock file maintenance.** It is
  opt-in (`nix: { enabled: true }`), its default pattern matches `nix/flake.nix` in a
  subdirectory, and lock file maintenance runs `nix flake update` with no input list from
  the flake's directory, so nixpkgs, home-manager and nix-darwin all move. An input whose
  `flake.nix` URL carries no `rev` gets no per-input pull request, only the lock refresh
  (**derived** from `extract.ts`). The nixpkgs versioning treats channel names as
  versions, so a ref bump away from `nixpkgs-unstable` is possible; the package rule
  disabling every `nix` update type closes that, and the dry run in `ci` shows it.
- **No Nix on the runner.** `renovatebot/github-action` runs Renovate in its container
  only; `binarySource` defaults to `install`, and containerbase fetches `nix` inside the
  container when the manager needs it. A failure becomes an artifact error on the pull
  request, not a crashed run.
- **The `mise` manager matches all three tables** through its default patterns:
  `**/{,.}mise/config{,.*}.toml` takes `.mise/config.toml` and
  `config/mise/config.toml`; `**/{,.}mise{,.*}.toml` takes `win/mise.toml`. Short names
  resolve through the bundled mise registry, github backend preferred. With no
  `mise.lock` nothing needs a `mise` binary or `allowedUnsafeExecutions`.
- **Short pins expand.** With no `versioning` set the fallback is `semver-coerced`, where
  `isSingleVersion("0.11")` is true and `getNewValue` returns the full new version:
  `shellcheck = "0.11"` becomes `"0.12.0"` (**derived**). `node = "24.16"` is the
  exception: node versioning wraps npm, where `24.16` is a range and the bump keeps two
  components. The repo moved every pin to a full version instead of carrying a regex
  versioning rule.
- **Digest pins satisfy zizmor.** The github-actions manager matches
  `.github/actions/**/action.yml` and walks composite `runs.steps`; it writes
  `owner/repo@<sha> # vX.Y.Z`, which is zizmor's own remediation form for
  `unpinned-uses` under its default `hash-pin` policy, and `ref-version-mismatch` checks
  the comment against the sha. A `with:` value such as `renovate-version` is never a
  dependency; a regex manager covers it.
- **Alternatives.** Dependabot added a `nix` ecosystem on 2026-04-07 (one pull request
  per input, no `mise` ecosystem). `update-flake-lock` is one job for one lock and
  needs a token so `ci` runs on its pull request. Neither reaches the mise tables.
- **Global config under a non-repository filename is the documented recipe.** The
  action's `configurationFile` is `RENOVATE_CONFIG_FILE`; `onboarding: false` with
  `requireConfig: "optional"` processes the repository with no file on `main`;
  `renovate-config.json5` is not among the repository config filenames, so it is read
  once.
- **Conflicts.** Each pull request is its own branch; after one merges, another touching
  the same file is conflicted and rebased on the next run (`rebaseWhen: auto`). No
  manager touches `win/winget.json`, sheldon, uv tools or the installer URLs.

## Sources

- https://docs.renovatebot.com/modules/manager/nix/ and
  `lib/modules/manager/nix/{extract,artifacts}.ts`
- https://docs.renovatebot.com/modules/manager/mise/ and
  `lib/modules/manager/mise/extract.ts`, `lib/modules/versioning/{index,semver-coerced,npm,node}`
- https://docs.renovatebot.com/modules/manager/github-actions/ and
  https://docs.renovatebot.com/presets-helpers/
- https://docs.zizmor.sh/audits/#unpinned-uses
- https://docs.renovatebot.com/self-hosted-configuration/ (`binarySource`, `onboarding`,
  `requireConfig`, `allowedUnsafeExecutions`)
- https://github.com/renovatebot/github-action/blob/main/README.md and
  https://github.com/containerbase/base/blob/main/src/cli/tools/nix.ts
- https://github.blog/changelog/2026-04-07-dependabot-version-updates-now-support-the-nix-ecosystem
- https://github.com/DeterminateSystems/update-flake-lock/blob/main/README.md
