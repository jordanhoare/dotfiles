# Does a `[tools]` table in `.mise/config.toml` need trust or shadow the baseline?

Date: 2026-10-27. No ticket.

Question: ADR 0016 says `.mise/config.toml` "carries `[tasks]` only, never `[tools]` or
`[env]`, so it does not shadow the baseline in `config/mise/config.toml` and needs no
trust prompt on first run." Are both justifications true? The prompt for asking is a
plan to pin repo linters (shellcheck, shfmt, zizmor, yamllint, taplo, gitleaks,
editorconfig-checker, actionlint) in `.mise/config.toml`, as
`~/repositories/homelab/.mise/config.toml` does.

Sources are primary only: the mise docs and the jdx/mise source at tag `v2026.10.19`
(commit `860cdc0`, 2026-10-24), with `v2026.10.3` (the repo's `min_version`) checked
where the trust logic matters. Docs URLs are the published pages; their source is
`docs/` in the same tag. Local checks were run on this Mac with mise
`2026.10.19 macos-arm64`, in throwaway directories under the session scratchpad, with a
clean environment (`env -i`, stdin from `/dev/null`, separate `MISE_CONFIG_DIR`,
`MISE_STATE_DIR`, `MISE_DATA_DIR`, `MISE_CACHE_DIR`, no `CI`, no `MISE_YES`, no
`MISE_TRUSTED_CONFIG_PATHS`). Results marked **Empirical** come from those runs.

## Summary

- **Trust: the ADR's reason is wrong twice over.** A config holding only `min_version`,
  plain-version `[tools]` and `[tasks]` needs no trust. Adding `[tools]` does not change
  trust status. The file as it stands already needs trust, because its tasks use
  templates (`{{ os() }}`, `{{ config_root }}`, `{{ env.HOME }}`), and any template
  syntax disqualifies a config from the exemption. It still bootstraps, because
  `mise run` trusts its active config implicitly, non-interactively too.
- **Shadowing: real, but it is ADR 0002's normal case.** A repo `[tools]` entry
  replaces the baseline entry for that tool only, only for commands whose working
  directory is inside the repo. Tools it does not name still come from the baseline.
  Shells outside the repo are unaffected.
- **Two effects specific to this repo are real and are not about shadowing.**
  (1) `mise run` installs every missing tool in the merged toolset before it runs any
  task. On a fresh machine, before `switch` links the baseline, that toolset is only
  the repo pins. `yamllint` resolves to the `pipx:` (pypi) backend, which needs `uv` or
  `pipx`, so `mise run bootstrap` exits 1 before the `nix` task starts.
  (2) The `tools` task (`mise install`) and `mise upgrade` in the `up` task run from the
  repo root, so for a tool pinned in both places they act on the repo version and skip
  the baseline version.
- `[env]` is different: it needs trust, and an `[env]` variable applies to every
  command and task run inside the repo. Keeping it out is sound, though trust is again
  not the problem because `mise run` grants it.
- `.mise/config.toml` and a root `mise.toml` behave the same for all of this.
- Recommendation at the end: drop the trust half of the rule, narrow the shadowing half,
  and handle the fresh-machine install order explicitly.

## 1. Trust

### 1a. What needs trust

**Docs.** "A `mise.toml` loads without trust when it has no template syntax (`{{`,
`{%` or `{#`) and contains only: `min_version`; `[tools]` entries whose values are
version strings or arrays of version strings, with no options in the tool name
(`"tool[opt=value]"`) and no `path:` version [...]; `[tasks]`, as long as no task lists
`secrets`." "Anything else needs trust, including tool option tables, `[env]`,
`[hooks]`, `[settings]`, `[tool_alias]` and `include`."
https://mise.jdx.dev/security.html#what-needs-trust. The `mise trust` page says the same
and adds "does not need trust unless paranoid mode is on".
https://mise.jdx.dev/cli/trust.html

**Source.** The gate is `MiseToml::parse_body_reporting`, which calls `trust_check(path)`
only when `!Self::is_trust_exempt(body, path)`
(https://github.com/jdx/mise/blob/v2026.10.19/src/config/config_file/mise_toml.rs#L693-L695).
`is_trust_exempt` returns false in paranoid mode or for an ignored path, otherwise
returns `is_safe_config_body(body)` (same file, L762-L775). `is_safe_config_body`
(L2614-L2653):

- rejects any template syntax in the raw text or in any decoded key or value;
- accepts top-level keys `min_version`, `tasks` (unless a task has a `secrets` key) and
  `tools` (each key without `[`, not an `spm:` host-selecting key, each value a string or
  array of strings, none starting with `path:`);
- rejects every other top-level key (`_ => false`).

Tracked loading uses the same predicate through `detection_requires_trust`
(https://github.com/jdx/mise/blob/v2026.10.19/src/config/config_file/mod.rs#L576-L599).

So plain `[tools]` is in the exempt set. Trust is triggered by templates, `[env]`,
`[hooks]`, `[settings]`, `[tool_alias]`, `include`, tool options and `path:` versions.
Tasks are not gated by trust at load time; the docs add that "Tasks that load without
trust run nothing until you run one." https://mise.jdx.dev/security.html#what-needs-trust

**Paranoid mode** removes the exemption: `is_trust_exempt` returns false and
`detection_requires_trust` returns true when `paranoid.config()` is on, so every
non-global config needs trust, `[tasks]`-only included (mod.rs L581-L583). Docs:
"Paranoid mode removes these exemptions apart from `.miserc.toml`."
https://mise.jdx.dev/security.html#what-needs-trust

**This repo's file already needs trust.** `.mise/config.toml` contains
`run = 'mise run "switch:{{ os() }}"'`, `env = { DOTFILES = "{{ config_root }}" }` and
`"{{ env.HOME }}/.ssh/personal"`. The template rule rejects it.

**Empirical (2026.10.19), `mise ls` with stdin from `/dev/null`:**

| `.mise/config.toml` content | Result |
|---|---|
| `min_version`, `[tools] shfmt = "3.12"`, a plain task | loads, exit 0; `mise trust --show` still prints `untrusted` |
| one task using `{{ os() }}` | `Config files in .../.mise/config.toml are not trusted`, exit 1 |
| `[env] FOO = "bar"` plus a task | same error, exit 1 |
| a copy of this repo's `.mise/config.toml` | same error, exit 1 |
| the `[tools]` file with `MISE_PARANOID=1` | same error, exit 1 |

**Version check.** At `v2026.10.3` `is_safe_config_body` already exempted
`min_version`, `tasks` and plain `tools`, and rejected templates
(https://github.com/jdx/mise/blob/v2026.10.3/src/config/config_file/mise_toml.rs#L3163-L3196).
Later releases only tightened it: `path:` versions need trust from 2026.10.9 (#14358),
tasks listing `secrets` are in the current code, and untrusted `[settings]` are ignored
from 2026.10.13 (#14538) (`CHANGELOG.md`). The exemption itself dates from 2026.6.6,
"load safe mise.toml files without trust" (#10360).

### 1b. Non-interactive runs

**Docs.** "Without a terminal, such as in a script or an editor extension, mise cannot
ask, so the command fails with `Config files in <path> are not trusted`." Shell
activation "never asks. It skips the untrusted config, warns [...] and still applies the
trusted ones." https://mise.jdx.dev/security.html#when-mise-asks. Since 2026.8.11 mise
does not prompt when stdin is not a TTY (#12268, `CHANGELOG.md`).

**But `mise run` never reaches that path.** "Some commands trust the config they load
without asking [...]. In normal mode outside CI, these are `mise run`, task shorthand
such as `mise build`, `mise install`, `mise exec`, `mise watch`, and `mise daemons
start`, `restart` and `register`. They record trust for every non-global config they
load, including configs in parent directories, as if you had run `mise trust`."
https://mise.jdx.dev/security.html#implicit-trust

**Source.** `Commands::implicitly_trusts_active_config` returns true for `Run`, `Watch`,
`Exec`, `Install` and starting daemons
(https://github.com/jdx/mise/blob/v2026.10.19/src/cli/mod.rs#L495-L507). `Cli::run`
sets the flag from it before settings and config load (same file, L1121-L1129).
`trust_check` then writes the trust record and returns `Ok` before any prompt logic,
when the flag is set, mise is not in CI, paranoid mode is off, and the path is not on
the ignore list (https://github.com/jdx/mise/blob/v2026.10.19/src/config/config_file/mod.rs#L739-L806,
the first `if` at L751-L760). In `v2026.10.3` the same list was
`Exec | Install | Run | Watch` plus daemons
(https://github.com/jdx/mise/blob/v2026.10.3/src/cli/mod.rs#L471-L477); the feature
arrived in 2026.8.9 (#12107). 2026.10.19 narrowed it so help output, shims, hooks and
config writes no longer count as consent (#14903); `mise run <task>` still does.

**Empirical (2026.10.19).** With stdin from `/dev/null`, `mise run hello` succeeded,
exit 0, in the templated config, the `[env]` config and the copy of this repo's config,
and each run wrote a record under `$MISE_STATE_DIR/trusted-configs/`. A `mise ls`
afterwards loaded without error.

So `exec mise run bootstrap` from `curl | sh` neither prompts nor fails on trust,
whatever `.mise/config.toml` holds, as long as paranoid mode is off. What does fail
non-interactively on a fresh machine is a non-executing command run in the repo before
bootstrap, such as `mise tasks ls`. That holds for the current file, because of its
templates, not because of any `[tools]` table.

In CI (`CI` set), "it treats every config as trusted and records nothing"
(https://github.com/jdx/mise/blob/v2026.10.19/src/config/config_file/mod.rs#L958-L961;
https://mise.jdx.dev/security.html#ci-and---yes). Empirical: `CI=1 mise ls` on the
`[env]` config loaded, and no trust record was written. That is why the CI job's
`mise tasks ls` passes today.

### 1c. Pre-trusting from the entry scripts

All three are supported. None is needed while the scripts call `mise run`.

- `mise trust <path>` takes a config file or a directory and records trust for its
  config root. https://mise.jdx.dev/cli/trust.html. Trust "belongs to a config root,
  usually the directory that holds `mise.toml`, so it covers every config file there,
  such as `mise.local.toml` or `.mise/config.toml`."
  https://mise.jdx.dev/security.html#manage-trust. Empirical: `mise trust <dir>` run
  from another directory, then `mise ls` inside it, loaded an `[env]` config.
- `MISE_YES=1` / `--yes`: "Outside CI, `--yes` or `MISE_YES=1` answers the trust prompt
  with yes, which records trust. Paranoid mode turns off [...] `--yes` for trust."
  https://mise.jdx.dev/security.html#ci-and---yes (source: mod.rs L780-L784).
  Empirical: `MISE_YES=1 mise ls` on an `[env]` config loaded. It also auto-confirms
  every other prompt, so it is the blunt option.
- `MISE_TRUSTED_CONFIG_PATHS` is the env form of `trusted_config_paths`, which is
  global-only and "Covers config files at or below these paths"
  (`settings.toml`, `[trusted_config_paths]`;
  https://mise.jdx.dev/configuration/settings.html#trusted_config_paths).

Caveats, from source and docs:

- "Trust records use resolved paths." https://mise.jdx.dev/security.html#manage-trust.
  `is_trusted_with` canonicalizes before every lookup (mod.rs L878-L885). On WSL,
  `/mnt/d/repositories/dotfiles` contains no symlinks, so the recorded path matches
  what later commands see (inference; not tested on WSL).
- On Windows, `canonicalize` returns a `\\?\D:\...` verbatim path. mise matches both
  the written and the canonical forms for `trusted_config_paths` (mod.rs L1003-L1014,
  and the `path_is_under_any` comment at L1035-L1046). 2026.10.x also stopped printing
  the prefix (#12014). Not tested on Windows.
- A `.mise/` directory that is a git checkout of its own is trusted separately
  (https://mise.jdx.dev/security.html#manage-trust). That does not apply here.

### 1d. `trusted_config_paths` before `switch`

`trusted_config_paths` is set in `config/mise/config.toml` (`~/repositories`,
`/mnt/d/repositories`) and `win/mise.toml` (`D:\repositories`). Both reach the machine
only when `switch` links them, so the first `mise run bootstrap` cannot use them. The
first run relies on implicit trust alone. That is enough: the record it writes covers
the repo root, and the nested `mise run "switch:..."` and `mise install` (the `tools`
task) are themselves implicit-trust commands. The setting matters only later, for
non-executing commands in new clones under those roots. The earlier note reached the
same conclusion (`.claude/docs/research/2026-10-27-mise-bootstrap.md`, section 9).

## 2. Shadowing

### 2a. How a tool pinned in both places resolves

**Docs.** Load order is system, global, then "Config files in every directory from the
filesystem root down to the current directory", then global override files, "and a
later file overrides an earlier one." `[tools]` merge "Per tool. The nearest file's
entry replaces that tool's whole entry, including its options. Other tools are
inherited." https://mise.jdx.dev/configuration.html#configuration-hierarchy,
https://mise.jdx.dev/configuration.html#merge-behavior-by-section

So:

- A repo `[tools]` table affects only the tools it names. Every other baseline tool
  still resolves from `~/.config/mise/config.toml` inside the repo.
- It affects only commands whose working directory is the repo or below it. Discovery
  walks from the current directory up, so a shell elsewhere never reads it.

**Empirical (2026.10.19).** Global `shfmt = "3.10"`, repo `shfmt = "3.12"`. In the repo,
`mise ls` showed `shfmt 3.12.0` from `.mise/config.toml`. In the repo,
`mise install --dry-run` printed "all tools are installed" (3.12 was installed and 3.10
was not). In a sibling directory, `mise install --dry-run` printed
`shfmt@3.10.0 would install`.

### 2b. Is "shadow the baseline" a real harm?

**Inference.** For a shell in the repo, it is the same effect ADR 0002 calls the normal
case: "a repo pin outranks the baseline for that tool. Repo pins are the normal case."
Of the proposed pins, only `actionlint` is in the baseline (`actionlint = "1.7"`);
shellcheck, shfmt, zizmor, yamllint, taplo, gitleaks and editorconfig-checker are not.
`hadolint` and `pre-commit` are in the baseline but not in the proposal. A different
`actionlint` inside this repo is no different from a different `node` inside any other
repo.

The effects that are specific to this repo come from its tasks running mise from the
repo root.

1. **`mise run` installs the merged toolset first.** Before resolving tasks, `Run`
   builds the toolset from the loaded config and calls `install_missing_versions`,
   unless `--skip-tools` is passed or `task.run_auto_install` / `auto_install` is false
   (https://github.com/jdx/mise/blob/v2026.10.19/src/cli/run.rs#L932-L960; setting
   `task.run_auto_install`, default true, `MISE_TASK_RUN_AUTO_INSTALL`, in
   `settings.toml`). Docs: `mise run` installs "Missing tools the task needs",
   https://mise.jdx.dev/dev-tools/#auto-install-mechanisms. Empirical: in a repo with no
   `[tools]` and a global `shfmt = "3.11"`, `mise run hello` installed shfmt 3.11, so
   "needs" means the whole merged toolset, not only tools the task names.
   On a fresh machine the baseline is not linked yet, so the toolset is just the repo
   pins, installed before `nix`, `switch` and `tools`. Most of the proposed linters
   install from `aqua:` or `github:` and need nothing else (`registry/*.toml`).
   `yamllint` does not: its backends are `pipx:yamllint` and an asdf plugin
   (`registry/yamllint.toml`). The pypi/pipx backend "installs with uv, or with pipx
   when uv is not available" (https://mise.jdx.dev/dev-tools/backends/pypi.html).
   **Empirical:** with no global config and a repo `[tools] yamllint = "1"`,
   `mise run hello` printed "pipx may be required but was not found" and exited 1
   without running the task. With `MISE_TASK_RUN_AUTO_INSTALL=false`, or
   `mise run --skip-tools hello`, it printed `hello` and exited 0.
   The homelab repo avoids this by pinning `uv` and `python` next to `yamllint`. The
   docs say "When `uv`, `pipx` or `python` is in your config, mise installs it before
   your Python tools." https://mise.jdx.dev/dev-tools/backends/pypi.html
   The same pre-install runs in CI's Windows job, which calls `mise run nix` without
   `--dry-run` (`.github/workflows/ci.yml`). The `--dry-run` calls in the other jobs
   pass `dry_run` to the installer and install nothing.
2. **`mise run tools` and `mise run up` act on the repo version.** `mise install` with
   no arguments "installs every tool version your config requests"
   (https://mise.jdx.dev/cli/install.html), and the config is resolved from the repo
   root. For a tool pinned in both places, bootstrap installs the repo version and
   skips the baseline version, as the empirical run in 2a shows. The baseline version
   then installs on first use outside the repo, because the baseline sets
   `auto_install = true`. `mise upgrade` "Upgrades every configured tool when omitted"
   (https://mise.jdx.dev/cli/upgrade.html). Run from the repo by `.mise/tasks/up.sh`, it
   therefore misses a baseline tool shadowed by a repo pin. Today only `actionlint`
   would overlap.

Neither effect harms other shells. The first is an ordering bug: bootstrap fails. The
second is a coverage gap: the baseline version is not pre-installed or upgraded by
these tasks.

### 2c. `[env]` versus `[tools]`

`[env]` merges "Per variable; the nearest file wins"
(https://mise.jdx.dev/configuration.html#merge-behavior-by-section). It needs trust
(1a), and it applies to every command and task mise runs in the repo, including the
`switch` and `secrets` tasks. A repo `[tools]` entry changes the version of one named
tool. A repo `[env]` entry can change `PATH`, `HOME`-derived paths or Nix variables for
the bootstrap itself. Keeping `[env]` out of this file has a better rationale than
keeping `[tools]` out, though the rationale is the blast radius, not trust. Task-level
`env = {...}` (as `secrets`, `decrypt` and `encrypt` use) is scoped to one task and is
part of `[tasks]`.

## 3. `.mise/config.toml` versus a root `mise.toml`

Both are project config files in the same directory: "`mise.toml` | Shared project
config" and "`.mise/config.toml` | Project config in a hidden `.mise/` directory",
where "a file higher in the table overrides one lower down"
(https://mise.jdx.dev/configuration.html#mise-toml). The trust predicate is the same
`MiseToml` parse, keyed on content, and trust is recorded for the config root, which
covers both (https://mise.jdx.dev/security.html#manage-trust). Merge rules,
implicit-trust and auto-install behave the same. The only difference is precedence if
both files exist, and this repo has no root `mise.toml` (checked locally).

## Recommendation

**"Needs no trust prompt on first run": invalid. Drop it.** Plain `[tools]` is
trust-exempt (1a). The current file is not exempt anyway, because of its templates.
`mise run` trusts the config implicitly, including from `curl | sh` (1b). Nothing in
`install.sh` or `install.ps1` needs to change for trust. If a pre-bootstrap
non-executing command must work, such as `mise tasks ls` in a fresh clone, the minimal
change is one line before the `exec`/final line: `"$HOME/.local/bin/mise" trust
"$dotfiles"` in `install.sh` and `mise trust $dotfiles` in `install.ps1`. Prefer that
to `MISE_YES=1`, which also answers every other prompt.

**"Does not shadow the baseline": true as stated, but not a reason to forbid
`[tools]`.** Shadowing is per tool and repo-scoped (2a). It is what ADR 0002 already
accepts for every repo (2b). Narrow the rule to:

- No `[env]` in `.mise/config.toml`. Per-task `env` stays allowed.
- `[tools]` allowed for tools the repo's own checks need. A tool the baseline also
  declares is pinned to the same version, or left to the baseline. Then `mise run tools`
  and `mise run up` from the repo root still cover the baseline. Today that means
  dropping `actionlint` from the repo pins or matching `actionlint = "1.7"`.
- Any `pipx:`/pypi-backed pin (here `yamllint`) comes with `uv` pinned in the same
  table, as homelab does.

**Fix the fresh-machine install order explicitly.** Pick one:

- Pin `uv` alongside `yamllint`. Bootstrap then installs the linters before `nix`. This
  works, but it adds downloads to the first step and puts a second `uv` pin in the repo
  next to the baseline's `uv = "0.11"`. Match the version to avoid the 2b coverage gap.
- Or keep bootstrap free of repo tools: export `MISE_TASK_RUN_AUTO_INSTALL=false` in
  `install.sh` and `install.ps1` before `mise run bootstrap`. The variable is inherited
  by the nested `mise run "switch:..."`; the `--skip-tools` flag would not be. The
  linters then install on first `mise exec -- <tool>` (`exec_auto_install`) or on
  `mise run tools`, by which time the baseline's `uv` exists. This is the smaller
  change and keeps bootstrap's first step independent of the linter list.

Either way, update the comment at the top of `.mise/config.toml` and the ADR 0016
bullet. Both currently give the trust and shadowing reasons verbatim.

Open points not verified here: WSL (`/mnt/d`) and native Windows trust paths were
reasoned from source, not run. The `CI` job on Windows would hit the auto-install
behaviour in 2b(1) through `mise run nix` once repo `[tools]` exist.
