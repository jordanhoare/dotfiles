# Can mise tasks replace the Makefile for bootstrapping this repo?

Date: 2026-10-27. No ticket.

Question: can mise (jdx/mise) tasks bootstrap this dotfiles repo on a fresh macOS,
Linux, WSL, or Windows machine so that mise is the only thing installed by hand, and
does a hand-installed "bootstrap" mise conflict with the mise that Nix later installs?

Sources are primary only: mise docs and the jdx/mise repo, the mise JSON schema, Nix
and nix-darwin docs and source, Determinate Systems docs and installer README,
Microsoft Learn, Apple's TN2339 and the local `xcode-select(1)` man page, Homebrew's
install script. Local checks were run on this Mac (mise 2026.10.3 from nix-darwin,
Determinate Nix 3.21.0).

## Summary

- mise tasks can express everything the Makefile does. OS selection is coarse: a task
  has `run` and `run_windows` only; there is no `os` key on tasks. Linux-vs-macOS
  branching happens inside the script (`{{ os() }}` template or `uname`), or by giving
  each OS its own config file (`config.macos.toml` with `auto_env`).
- `raw = true` connects the task to the terminal's stdin/stdout/stderr, so `sudo`
  prompts and interactive installers work. `interactive = true` is the lighter
  variant.
- mise now ships `mise bootstrap`, `[bootstrap.packages]` and `[dotfiles]`, which is
  the documented pattern for a dotfiles repo: install mise with `curl https://mise.run
  | sh`, then `mise bootstrap --adopt you/setup`. It targets host package managers
  (brew, apt, winget, nix, ...), dotfile symlinks, shell activation, and a final
  `bootstrap` task. It overlaps heavily with what Home Manager does here.
- Two mise binaries do not corrupt state: data, config, cache and state directories
  are keyed on `$HOME`/XDG and env vars, never on the binary's location. The conflict
  is in two places that record a binary path: Unix shims are symlinks to whichever
  `mise` ran `reshim`, and the `mise` shell function emitted by `mise activate` wraps
  the binary that was first on PATH when the shell started. Nix-installed mise has
  self-update disabled (`lib/mise/.disable-self-update`), so the two binaries also
  drift unless both are upgraded.
- Recommendation at the end: keep Nix as the owner of mise on macOS/Linux/WSL, use
  mise tasks as the entry point, and make the `mise.run` binary a throwaway that the
  task deletes after Nix's mise is active. Windows uses `winget install jdx.mise`
  (self-update is off there too) and the same tasks via `run_windows`.

## 1. mise tasks

### TOML tasks and file tasks

- TOML tasks live under `[tasks.<name>]` in `mise.toml`; file tasks are executable
  scripts in a task directory. The default task directories, in order, are
  `mise-tasks`, `.mise-tasks`, `.mise/tasks`, `.config/mise/tasks`, `mise/tasks`; when
  two define the same task "the one later in the list wins".
  https://mise.jdx.dev/tasks/task-discovery.html
- `run` is "a single command or an array of commands"; array entries run in order and
  stop at the first failure. https://mise.jdx.dev/tasks/toml-tasks.html
- `depends`: "Tasks that must finish before this task runs. When several tasks share a
  dependency, it runs once." `depends_post`: run "after this task finishes, whether it
  succeeds or fails, as long as it started". `wait_for`: waits for tasks only when they
  are already scheduled. https://mise.jdx.dev/tasks/task-configuration.html
- `env`: "Environment variables for this task's commands. They are not passed to its
  `depends` tasks." `tools`: install and activate for this task only.
  https://mise.jdx.dev/tasks/task-configuration.html
- `dir`: defaults to `{{ config_root }}`; `dir = "{{cwd}}"` runs where mise was
  invoked. https://mise.jdx.dev/tasks/task-configuration.html
- `sources`/`outputs`: freshness check, task skipped when no source changed since the
  last successful run; `outputs` defaults to `{ auto = true }`.
  https://mise.jdx.dev/tasks/task-configuration.html
- `hide = true` removes the task from `mise tasks ls`, help and completions; `mise run`
  still runs it. https://mise.jdx.dev/tasks/task-configuration.html
- `confirm`: "A prompt shown before the task's own command runs, for tasks that are
  destructive or slow." The prompt appears after `depends` have run. The `yes` setting
  / `MISE_YES` / `--yes` answers every confirmation prompt.
  https://mise.jdx.dev/tasks/task-configuration.html,
  https://mise.jdx.dev/configuration/settings.html#yes
- `raw`: "Connect each of the task's commands directly to your terminal's stdin,
  stdout, and stderr." Output is not prefixed, captured or redacted, and the task skips
  the artifact cache. https://mise.jdx.dev/tasks/task-configuration.html
- `quiet`: hides mise's own output for the task; `silent`: hides the task's output (or
  one stream). https://mise.jdx.dev/tasks/task-configuration.html
- `skip_if` (in the schema, not yet on the configuration page): "shell command checked
  before the task runs; if it exits 0, the task is skipped and counts as successful".
  https://mise.jdx.dev/schema/mise.json (`$defs.task_props.skip_if`)
- `interactive` (schema): "mark task as interactive, acquiring exclusive terminal access
  while allowing other non-interactive tasks to run in parallel".
  https://mise.jdx.dev/schema/mise.json (`$defs.task_props.interactive`)
- File tasks: name is the path below the task dir with `/` -> `:`; extensions `.sh`,
  `.py`, `.js`, `.ps1` are dropped; `#MISE key=value` header lines accept every
  `[tasks.<name>]` property except `run`, `run_windows`, `file`, `usage`. On Linux and
  macOS the script must be executable. https://mise.jdx.dev/tasks/file-tasks.html

### OS-specific tasks

- The only per-OS selector on a task is `run_windows`: "On Windows, mise runs this
  instead of `run`. [...] An empty list skips the task on Windows. A file task has no
  `run_windows`." https://mise.jdx.dev/tasks/task-configuration.html
- The full task property list in the JSON schema has no `os`, `platforms`, `run_linux`
  or `run_macos` key: `alias, allow_*, cache, confirm, daemons, deny_*, depends,
  depends_post, description, dir, env, file, hide, interactive, output, outputs,
  pass_through_env, quiet, raw, raw_args, run, run_windows, rust_cache, secrets, shell,
  silent, skip_if, sources, timeout, tools, usage, vars, wait_for, watch`.
  https://mise.jdx.dev/schema/mise.json
- `run_windows` originates from issue #2595 "windows alternate tasks"; the
  `[tasks-windows.x]` / `tasks.os.windows` alternatives were rejected.
  https://github.com/jdx/mise/issues/2595
- Linux-vs-macOS branching options:
  - Templates in `run`: `os()` returns `linux`, `macos`, `windows`; `os_family()`
    returns `unix`/`windows`; `arch()` returns `x64`/`arm64`. Example:
    `{% if os() is starting_with(pat="mac") %}`. Task fields are rendered "When the
    task runs". https://mise.jdx.dev/templates.html
  - `skip_if = "test $(uname) != Darwin"` (schema semantics above).
  - A platform config file such as `config.macos.toml` with `auto_env` enabled
    (documented for dotfiles entries; the same file carries `[tasks]`).
    https://mise.jdx.dev/dotfiles.html, https://mise.jdx.dev/dotfiles/managed.html
  - Paired file tasks `build.sh` + `build.ps1` in one directory: on Windows mise runs
    `build.ps1` as `build`. https://mise.jdx.dev/tasks/file-tasks.html

### Shell per OS

- Unix inline default: `unix_default_inline_shell_args = "sh -o errexit -c"`; Windows
  inline default: `windows_default_inline_shell_args = "cmd /c"`. Both global-only
  settings. File tasks without shebang/known extension use
  `unix_default_file_shell_args = "sh"` / `windows_default_file_shell_args = "cmd /c"`.
  https://mise.jdx.dev/configuration/settings.html
- Per task: `shell = "bash -c"`; default is `task_config.shell` if set. For PowerShell
  mise passes `-NoProfile` (`windows_powershell_no_profile`, default `true`). There is
  no `windows_shell` property; the Windows shell comes from the settings above or the
  task's `shell`. https://mise.jdx.dev/tasks/task-configuration.html,
  https://mise.jdx.dev/configuration/settings.html
- Custom shells and shebang scripts "do not stop at the first failure"; add `set -euo
  pipefail` yourself. https://mise.jdx.dev/tasks/toml-tasks.html
- File tasks on Windows: a file is a task if its extension is in
  `windows_executable_extensions` (default `exe, bat, cmd, com, ps1, vbs`) or it starts
  with a shebang; "A file with neither is not a task on Windows". A `#!/usr/bin/env
  pwsh` task runs from a temporary `.ps1` copy. https://mise.jdx.dev/tasks/file-tasks.html,
  https://mise.jdx.dev/configuration/settings.html

### Global vs repo-local tasks, merging

- Tasks in `$MISE_CONFIG_DIR/tasks` (`~/.config/mise/tasks`) are global and "are
  available in every directory". If a global config file exists, inline `[tasks]` in it
  are global too. https://mise.jdx.dev/tasks/task-discovery.html
- Precedence: "A task from a nearer directory replaces a same-named task from a parent
  directory, and a project task replaces a global task." Same-named tasks shadow, they
  do not merge; a block without `run`/`run_windows`/`file` only adds metadata.
  https://mise.jdx.dev/tasks/task-discovery.html
- `task_config.includes` "replaces the default task directories rather than adding to
  them"; a parent's list reaches children only with `task_config.cascade = true`.
  https://mise.jdx.dev/tasks/task-configuration.html,
  https://mise.jdx.dev/tasks/task-discovery.html
- `config.override.toml` in the global dir can define `[tasks]` that outrank project
  tasks. https://mise.jdx.dev/configuration.html

Implication for this repo: a `mise.toml` at the repo root with `[tasks.switch]` etc.
is the Makefile replacement. Tasks run from `{{ config_root }}` (the repo) by default,
which matches `$(DOTFILES)` in the Makefile. The repo can also keep its global config
at `config/mise/config.toml` linked to `~/.config/mise/config.toml` as today; the two
files merge per section, repo wins per tool/task name.

## 2. Installing mise, and its directories

Install methods (https://mise.jdx.dev/installing-mise.html):

- `curl -fsSL https://mise.run | sh` "installs the executable to `~/.local/bin/mise`".
  `MISE_INSTALL_PATH` defaults to `~/.local/bin/mise`; `MISE_VERSION` pins a release
  ("Bypasses the release-age delay"); without it "the script selects the newest stable
  release published at least 24 hours before it runs"; `MISE_INSTALL_HELP=0` silences
  the activation hint. Verified in the script: `install_path="${MISE_INSTALL_PATH:-$HOME/.local/bin/mise}"`.
  https://mise.run
- Homebrew `brew install mise` (builds from source). MacPorts `sudo port install mise`.
- winget `winget install jdx.mise`, "the recommended method on Windows".
- PowerShell `irm https://mise.run/powershell | iex` (PowerShell 5.1+): installs to
  `~\.local\bin` "with `mise-shim.exe` beside `mise.exe`", adds that dir to the user
  `Path` "(no admin rights needed)"; honours `MISE_VERSION`, `MISE_INSTALL_PATH`,
  `MISE_INSTALL_MODIFY_PATH=0`, `MISE_INSTALL_SHIMS_PATH=1`. Verified in the script
  header. https://mise.run/powershell
- Scoop `scoop install mise` (adds mise but not the shims dir to Path); Chocolatey
  `choco install mise` (can lag).
- Cargo `cargo install --locked mise`.
- Nix: `nix-env -iA nixpkgs.mise` (nixpkgs 24.05+); the repo is also a flake
  `github:jdx/mise`. Home Manager has `programs.mise.enable`, `programs.mise.package`
  (default `pkgs.mise`), `programs.mise.globalConfig` (writes
  `$XDG_CONFIG_HOME/mise/config.toml`) and `enableZshIntegration`.
  https://nix-community.github.io/home-manager/options/home-manager/programs/mise.html

Self-update for package manager installs:

- "If a package manager installed mise, update it with that package manager." and
  "Distribution packagers can disable `mise self-update`".
  https://mise.jdx.dev/installing-mise.html
- Packaging guide: an empty marker at `lib/.disable-self-update` (Homebrew),
  `lib/mise/.disable-self-update` or `lib64/mise/.disable-self-update` under the install
  prefix disables self-update; mise finds the prefix "from its own executable, resolving
  symlinks and going up two levels". `MISE_SELF_UPDATE_AVAILABLE=false|true` toggles it
  at runtime. These runtime methods are "do not update by default", and `mise
  self-update --force` skips the availability check; only building without the
  `self_update` cargo feature is a hard block. "mise detects WinGet installs by
  executable path and turns self-update off. It directs users to `winget upgrade
  jdx.mise`." https://mise.jdx.dev/packaging.html
- nixpkgs builds mise with default features (so `self_update` is compiled in) and in
  `postInstall` runs `touch $out/lib/mise/.disable-self-update`.
  https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/mi/mise/package.nix
- Local confirmation: `mise --version` prints "self-update is disabled for this
  install, update mise the same way you installed it"; `mise doctor` prints
  `self_update_available: no` and `Features: default, native-tls, self_update`.

Directories (https://mise.jdx.dev/directories.html):

| Variable | Linux | macOS | Windows |
|---|---|---|---|
| `MISE_CONFIG_DIR` | `~/.config/mise` | `~/.config/mise` | `%USERPROFILE%\.config\mise` |
| `MISE_DATA_DIR` (installs, plugins, shims) | `~/.local/share/mise` | `~/.local/share/mise` | `%LOCALAPPDATA%\mise` |
| `MISE_CACHE_DIR` | `~/.cache/mise` | `~/Library/Caches/mise` | `%TEMP%\mise` |
| `MISE_STATE_DIR` (trust decisions, freshness) | `~/.local/state/mise` | `~/.local/state/mise` | `%USERPROFILE%\.local\state\mise` |
| `MISE_SYSTEM_DIR` | `/etc/mise` | `/etc/mise` | `\etc\mise` |

"Without an override, each directory falls back to `XDG_*_HOME` + `/mise`". Nothing in
the directories page keys state on the binary's path. So a `mise.run` binary at
`~/.local/bin/mise` and a Nix one at `~/.nix-profile/bin/mise` (or, with nix-darwin,
`/etc/profiles/per-user/<user>/bin/mise`) read and write the same installs, config,
trust records and cache. The two things that do embed a binary path:

- Unix shims: "On Unix each shim is a symlink to the `mise` binary", example
  `~/.local/share/mise/shims/node -> ~/.local/bin/mise`. Local check: every shim here
  points at `/etc/profiles/per-user/jordanhoare/bin/mise`, including
  `~/.local/share/mise/shims/mise` itself. Whichever binary runs `mise reshim` (or an
  install that rebuilds shims) rewrites the targets. https://mise.jdx.dev/dev-tools/shims.html
- The `mise` shell function from `mise activate zsh` wraps an absolute path
  (`command /Users/.../.local/share/mise/shims/mise "$command" "$@"` in the local
  output), chosen when the shell evaluated the activation. The docs: "The mise
  executable must be on PATH before that line runs. Otherwise use its absolute path, for
  example `eval "$(~/.local/bin/mise activate zsh)"`." https://mise.jdx.dev/cli/activate.html

## 3. Two binaries on PATH, doctor, self-update

- The docs do not have a section on two mise binaries. `mise doctor` "Prints mise's
  version, whether shell activation and shims are set up, its directories" and "lists
  any problems and warnings with a suggested fix", exits 1 on a problem; `mise doctor
  path` shows "the PATH entries mise adds". https://mise.jdx.dev/cli/doctor.html,
  https://mise.jdx.dev/troubleshooting.html
- Troubleshooting: "Update mise with the package manager that installed it, or with
  `mise self-update`"; "Deleting mise's data or reinstalling every tool rarely fixes a
  version-selection or shell problem." https://mise.jdx.dev/troubleshooting.html
- On Windows, if an update replaces `mise.exe` but leaves an older `mise-shim.exe`,
  "`mise doctor` and `mise reshim` report it"; fix with `mise reshim --force`.
  https://mise.jdx.dev/dev-tools/shims.html
- Practical consequence: the only documented doctor check that catches a binary
  mismatch is the Windows shim-launcher one. On Unix a stale symlink target (binary
  removed) is a broken shim, not a doctor warning, per the docs. The local `which -a
  mise` shows three entries (shell function, shim, nix-darwin profile) and doctor
  reports nothing about it.

## 4. sudo and interactive commands in tasks

- `raw = true` per task, `--raw` on `mise run`, or the global `raw` setting
  (`MISE_RAW`) "Connect tasks and install commands directly to the terminal's stdin,
  stdout and stderr." With `--raw` "tasks run one at a time" and redaction is off.
  https://mise.jdx.dev/configuration/settings.html#raw, https://mise.jdx.dev/cli/run.html
- Without raw, stdin is connected only in `interleave` output mode, which is "the
  default for a single task, a sequential chain, or `--jobs 1`"; it is not connected for
  `prefix` (parallel) output. `interactive = true` gives a task "exclusive terminal
  access while it runs". https://mise.jdx.dev/tasks/running-tasks.html
- mise's own bootstrap step runs root-requiring package managers "through `sudo` and
  logs each command first", falling back to `run0` then `doas`; `system_packages.sudo =
  false` forbids elevation. `[bootstrap.user]` may run `chsh -s` which "may ask for your
  password", and uses sudo for `/etc/shells` ("Otherwise it needs passwordless sudo").
  So sudo prompts inside mise are an expected pattern.
  https://mise.jdx.dev/bootstrap/packages/, https://mise.jdx.dev/bootstrap/shell.html
- `darwin-rebuild switch` must run as root: "Accordingly, `darwin-rebuild` must now be
  run as root" (nix-darwin 2025-01-30), with `system.primaryUser` naming the user.
  https://github.com/nix-darwin/nix-darwin/blob/master/CHANGELOG. The README shows
  `sudo nix run nix-darwin/master#darwin-rebuild -- switch` and `sudo darwin-rebuild
  switch`. https://github.com/nix-darwin/nix-darwin
- `xcode-select --install` "Opens a user interface dialog to request automatic
  installation of the command line developer tools" (`man xcode-select`, macOS 14
  local). A task can launch it with `raw = true`, but the dialog is GUI and the command
  returns before installation finishes; see section 8 for the headless route.

## 5. mise on Windows

- "mise runs natively on Windows, with PowerShell activation, shims, `mise exec`, and
  `mise run`." asdf plugins do not work there. In WSL "install the Linux build of mise
  and manage Linux tools there." https://mise.jdx.dev/faq.html
- Inline task shell on Windows is `cmd /c` by default; set `shell = "pwsh -c"` (mise
  adds `-NoProfile`) or `windows_default_inline_shell_args` globally.
  https://mise.jdx.dev/configuration/settings.html, https://mise.jdx.dev/tasks/task-configuration.html
- `run_windows` replaces `run`; empty list skips the task on Windows (bug #14840 on
  that behaviour closed 2026-10-23). https://mise.jdx.dev/tasks/task-configuration.html,
  https://github.com/jdx/mise/issues/14840
- File tasks need an executable extension or a shebang; `env._.source` on Windows "needs
  a POSIX bash" and never uses the WSL `bash.exe`. https://mise.jdx.dev/tasks/file-tasks.html,
  https://mise.jdx.dev/environments/
- Shims: `windows_shim_mode = "exe"` copies `mise-shim.exe` as `<tool>.exe`; WSL does
  not match those names. PATH length warning for `cmd.exe`.
  https://mise.jdx.dev/troubleshooting.html, https://mise.jdx.dev/configuration/settings.html
- Windows builds exclude the Homebrew managers; `winget` manager "never uses sudo, but
  the installer can raise its own UAC prompt". https://mise.jdx.dev/bootstrap/packages/
- Installer: `irm https://mise.run/powershell | iex` exists (section 2); winget is
  recommended. https://mise.jdx.dev/installing-mise.html
- `[bootstrap.user]` (login shell) is skipped on Windows; `[dotfiles]` symlinks work
  "without elevation once Developer Mode is on", otherwise copy; `symlink-each` always
  copies unless `dotfiles.windows_symlinks = true` (then "Developer Mode or an elevated
  shell is required"). https://mise.jdx.dev/bootstrap/shell.html,
  https://mise.jdx.dev/dotfiles/managed.html
- winget: `winget import --import-file ... --accept-package-agreements
  --accept-source-agreements --disable-interactivity` are all documented flags; import
  installs "in a serial fashion". https://learn.microsoft.com/en-us/windows/package-manager/winget/import

## 6. `[tools]` and `[env]` in repo-local vs global config

- Load order: system `/etc/mise`, then global `~/.config/mise`, then each directory
  from root down to cwd ("The nearest file wins"), then `config.override.toml`.
  `[tools]` merge per tool: "The nearest file's entry replaces that tool's whole entry,
  including its options." `[env]`: "Per variable; the nearest file wins." `[tasks]`:
  per task name. `[settings]`: per setting, and `trusted_config_paths`, `yes`,
  `paranoid`, the `*_shell_args` are global-only. https://mise.jdx.dev/configuration.html,
  https://mise.jdx.dev/configuration/settings.html
- A repo `mise.toml` with `[tools]` therefore overrides the global entry for the same
  tool while inside the repo, and adds any tools the global file lacks. Installs live
  once in `MISE_DATA_DIR/installs/<tool>/<version>`, so the same version resolved by
  both files installs once; a different version is a second install by design.
  https://mise.jdx.dev/directories.html
- `MISE_GLOBAL_CONFIG_FILE` "replaces all of these files with one file. It also turns
  off the override files." https://mise.jdx.dev/configuration.html
- `mise use --global node@24` writes "a personal default to ~/.config/mise/config.toml".
  https://mise.jdx.dev/dev-tools/
- For this repo: putting only `[tasks]` (no `[tools]`) in the root `mise.toml` avoids
  any override of `config/mise/config.toml`. If the bootstrap needs a tool before the
  global file is linked, use the task-level `tools = { ... }` key, which applies to that
  task only. https://mise.jdx.dev/tasks/task-configuration.html

## 7. Installing Nix non-interactively

Upstream installer (https://nixos.org/download/, https://nix.dev/manual/nix/latest/installation/installing-binary):

- Linux multi-user: `curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh -s -- --daemon`; macOS: same without flags ("macOS 14.0 or newer is required");
  WSL2 multi-user "requires systemd", else `--no-daemon`.
- Flags from the tarball installer source: `--daemon`, `--no-daemon` ("no-longer
  supported on Darwin/macOS"), `--daemon-user-count INT`, `--yes` ("Run the script
  non-interactively, accepting all prompts."), `--no-channel-add`,
  `--no-modify-profile`, `--nix-extra-conf-file FILE`.
  https://github.com/NixOS/nix/blob/master/packaging/scripted-installer/install-nix-from-tarball.sh
- Headless detection: `if [ -t 0 ] && [ -z "${NIX_INSTALLER_YES:-}" ]; then IS_HEADLESS='no'`, and `ui_confirm` prints "No TTY, assuming you would say yes :)" when headless. https://github.com/NixOS/nix/blob/master/packaging/scripted-installer/install-multi-user.sh
- The Darwin script checks for a writable `/nix` APFS volume (`diskutil`), not for
  Xcode CLT. https://github.com/NixOS/nix/blob/master/packaging/scripted-installer/install-darwin-multi-user.sh

Determinate installer (https://github.com/DeterminateSystems/nix-installer):

- `curl -fsSL https://install.determinate.systems/nix | sh -s -- install`; `--no-confirm`
  "is especially useful when using the installer in non-interactive scripts"; every
  setting is also a `NIX_INSTALLER_*` env var (`NIX_INSTALLER_NO_CONFIRM`,
  `NIX_INSTALLER_INIT`, `NIX_INSTALLER_START_DAEMON`). Determinate Nix is the default;
  `--prefer-upstream-nix` is "Not a supported configuration".
- WSL2: "We strongly recommend first enabling systemd and then installing Nix as
  normal"; "If enabling systemd is not an option, pass `--init none`", in which case
  "only root or users who can elevate to root privileges can run Nix".
- systemd in WSL: add `[boot] systemd=true` to `/etc/wsl.conf`, WSL 0.67.6+, then
  `wsl.exe --shutdown`; it is the default for current Ubuntu installed by `wsl --install`.
  https://learn.microsoft.com/en-us/windows/wsl/systemd
- macOS also has a `.pkg` (`https://install.determinate.systems/determinate-pkg/stable/Universal`).
  The installer "writes a `nix.conf` configuration file to `/etc/nix/nix.conf`".
  https://docs.determinate.systems/determinate-nix/
- With Determinate Nix, nix-darwin must set `nix.enable = false` ("Let Determinate Nix
  handle Nix configuration"). https://docs.determinate.systems/guides/nix-darwin/.
  This repo already does: `nix/modules/macos.nix:36 nix.enable = false;` and the local
  Nix is "Determinate Nix 3.21.0" with `/nix/nix-installer` present.

Both installers run unattended from a script. Both need sudo (multi-user), so the mise
task that runs them needs `raw = true` for the password prompt.

## 8. Xcode Command Line Tools

- Apple TN2339 lists three routes: Xcode, download from developer.apple.com, or
  `xcode-select --install`. No `softwareupdate` route is documented.
  https://developer.apple.com/library/archive/technotes/tn2339/_index.html
- `man xcode-select`: `--install` "Opens a user interface dialog to request automatic
  installation of the command line developer tools." (local macOS 14 man page)
- `softwareupdate --help` (local): `-l | --list`, `-i | --install <label>`,
  `--agree-to-license`. The headless route is Homebrew's: `sudo touch
  /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress`, then
  `softwareupdate -l | grep -B 1 -E 'Command Line Tools'` to find the label, then `sudo
  softwareupdate -i "$label"` and `sudo xcode-select --switch
  /Library/Developer/CommandLineTools`; Homebrew falls back to `xcode-select --install`
  plus "Press any key when the installation has completed." only when a TTY exists.
  https://github.com/Homebrew/install/blob/HEAD/install.sh. The placeholder-file
  mechanism is undocumented by Apple; it is a Homebrew-maintained workaround.
- Does Nix need CLT? Neither installer README nor the Darwin install script checks for
  it (section 7). nix-darwin: "The only prerequisite is a Nix implementation".
  https://github.com/nix-darwin/nix-darwin. Flakes in a git checkout are treated as
  `git+file:` ("If the directory is part of a Git repository, then the input will be
  treated as a `git+file:` URL"); only files "added to the Git repository" are seen.
  https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-flake. Nix bundles
  libgit2 for this (three `libgit2-1.9.x-lib` paths in the local store), so the `git`
  binary is not needed for `nix build`, but cloning the repo in the first place is.
  On a fresh Mac `/usr/bin/git` is a CLT stub that triggers the same GUI dialog. mise's
  own bootstrap docs list "Git on each machine (Xcode Command Line Tools on macOS)" as
  a prerequisite. https://mise.jdx.dev/bootstrap/setup.html
- Practical: CLT is the one step before mise on macOS. Either accept the GUI dialog
  once, or script the softwareupdate route (sudo, no GUI).

## 9. `min_version` and trust

- `min_version = "2026.1.0"` is a hard minimum; a `{ hard, soft }` table adds a
  warning threshold. https://mise.jdx.dev/configuration.html
- Trust: configs with only `min_version`, plain-version `[tools]`, and `[tasks]`
  without `secrets` "need no trust unless paranoid mode is on". `[env]`, `[settings]`,
  `[hooks]`, tool option tables, templates and `include` need trust. Without trust mise
  "prompts, skips the file, or fails with an untrusted-config error when it cannot
  prompt"; shell activation never prompts. https://mise.jdx.dev/cli/trust.html,
  https://mise.jdx.dev/security.html#configuration-trust
- Running a task auto-trusts: "`mise run`, task shorthand like `mise build`, `mise
  install`, `mise exec`, `mise watch` [...] trust the configs they load without
  asking" (normal mode, outside CI). https://mise.jdx.dev/security.html#configuration-trust
- `trusted_config_paths` (global-only): "Directories whose config files mise trusts
  without asking." Already set here to `~/repositories` (and `D:\repositories` on
  Windows). `CI=1` treats every config as trusted and turns on `yes`; `--yes` /
  `MISE_YES=1` answers the prompt. https://mise.jdx.dev/configuration/settings.html,
  https://mise.jdx.dev/security.html#configuration-trust
- Caveat for a fresh machine: `trusted_config_paths` lives in the global config, which
  is not linked until Home Manager runs. The first `mise run switch` relies on
  auto-trust, which the docs confirm.

## 10. Documented dotfiles bootstrap pattern

mise has first-class support, documented at https://mise.jdx.dev/bootstrap.html:

- `mise bootstrap` "sets up a machine from your mise configuration": "host packages,
  system files, services, Git repositories, dotfiles, shell activation, tools, and your
  `bootstrap` task". It "never runs on its own". Local `mise bootstrap --help` lists 8
  phases ending with "The `bootstrap` task, when defined, then the final hook."
- `[bootstrap.packages]` keys are `"manager:package"`; managers: apk, apt, aur, brew,
  brew-cask, choco, dnf, flatpak, macos-app, mas, nix, pacman, scoop, snap, winget,
  zypper. Entries take `os = "macos"` / `"linux"` / `"windows"` (or `macos/arm64`).
  Unavailable managers are skipped. The `nix` manager runs when `nix` is on PATH,
  cannot pin versions, never uses sudo, and `mise bootstrap packages export --format
  nix` emits a NixOS module. https://mise.jdx.dev/bootstrap/packages/
- `[dotfiles]`: modes `symlink` (default), `symlink-each`, `copy`, `template`,
  `absent`; `variants` select targets by `os`; conflicts need `--force`; Stow-style
  `[dotfile_groups.<name>] root = "home" target = "~" mode = "symlink-each"`.
  https://mise.jdx.dev/dotfiles/managed.html, https://mise.jdx.dev/dotfiles/groups.html
- `[bootstrap.mise_shell_activate] zsh = true` writes `eval "$(mise activate zsh
  --shims)"` to `~/.zprofile` and `eval "$(mise activate zsh)"` to `~/.zshrc` between
  `# >>> mise:activate >>>` markers. https://mise.jdx.dev/bootstrap/shell.html
- New machine flow: `curl -fsSL https://mise.run | sh`, add `~/.local/bin` to PATH,
  `mise exec gh@latest` to authenticate, then `mise bootstrap --adopt you/setup`; or
  `mise bootstrap --from https://github.com/you/workstation.git`, which reads the
  repo's `mise.toml`, offers to install `git`/`ssh` with the host package manager, and
  "trusts that configuration for this run". Prerequisite: "Git on each machine (Xcode
  Command Line Tools on macOS)". https://mise.jdx.dev/bootstrap/setup.html,
  https://mise.jdx.dev/bootstrap/from-repository.html
- The docs do not mark `bootstrap` experimental; the release stream is fast (bootstrap
  `unapply` in v2026.9.13, dotfile groups in v2026.10.3). The local 2026.10.3 binary
  already has the command.

## A. Shims and activate in the same shell

Current setup here: `home/.zshenv:43 export PATH="$HOME/.local/share/mise/shims:$PATH"`
and `home/.zshrc:11 eval "$(mise activate zsh)"`; `which -a mise` resolves the shell
function, then the shim, then `/etc/profiles/per-user/jordanhoare/bin/mise`.

- Activation keeps shims: "By default, activation also keeps the shim directories on
  `PATH`, behind the real tool directories, even in a directory with no `mise.toml`".
  `mise settings activate_shims=false` removes them. https://mise.jdx.dev/dev-tools/shims.html
- Recommended pairing: `mise activate --shims` in the login profile (`~/.zprofile`) and
  `mise activate` in the interactive file (`~/.zshrc`). `--shims` "puts the shims
  directory on PATH instead of updating PATH at each prompt", roughly
  `PATH="$HOME/.local/share/mise/shims:$PATH"`. The docs use `.zprofile`, never
  `.zshenv`. https://mise.jdx.dev/dev-tools/shims.html, https://mise.jdx.dev/cli/activate.html
- Non-interactive shells: editors and GUI apps "find mise tools without a prompt hook"
  via the login-profile shims; "Schedulers, services, and IDEs that skip your profile"
  get their own PATH or call `mise exec`; "Scripts and CI jobs never show a prompt, so
  use `mise exec` or `mise run` there." Zed "loads your shell's environment for the
  project, so the tools that `mise activate` puts on `PATH` are found without shims".
  VS Code remote needs mise on the remote host. https://mise.jdx.dev/dev-tools/shims.html,
  https://mise.jdx.dev/ide-integration.html, https://mise.jdx.dev/faq.html
- Shims vs activate: shims "do not set `[env]` variables in your shell", and `cd` /
  `enter` / `leave` hooks and `watch_files` "run only with `mise activate`".
  https://mise.jdx.dev/dev-tools/shims.html
- Local observation: the activation output starts the exported PATH with the shims dir
  (the `.zshenv` prepend survives), and the `mise` function wraps the shim path, which
  is a symlink to the Nix binary. This works, but a `.zshenv` prepend applies to every
  zsh including scripts, which is wider than the documented `.zprofile` (login) scope
  and puts shims ahead of the real tool dirs until activation reorders them.

## B. Pinning mise without Nix

- `https://mise.run` honours `MISE_VERSION` ("Release to install, such as
  `v2026.10.4`. Bypasses the release-age delay"), confirmed in the script
  (`if [ -n "${MISE_VERSION:-}" ]`). https://mise.jdx.dev/installing-mise.html, https://mise.run
- `mise self-update [FLAGS] [VERSION]`: "`[VERSION]` — Update to a specific version,
  skipping the minimum release age"; `-f/--force` "Also updates when the package that
  installed mise has disabled self-update"; `-y/--yes`; `--no-plugins`;
  `--minimum-release-age`. Local `--help` matches. https://mise.jdx.dev/cli/self-update.html
- Disabled for package-manager installs: Nix via `lib/mise/.disable-self-update`
  (nixpkgs `postInstall`), Homebrew via `lib/.disable-self-update`, winget detected by
  executable path. `mise doctor` reports `self_update_available: no` (local), and
  `mise --version` warns "self-update is disabled for this install, update mise the
  same way you installed it". https://mise.jdx.dev/packaging.html,
  https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/mi/mise/package.nix
- `self_update.auto` (global-only) updates mise before eligible commands and skips
  installs whose packager disabled self-update. https://mise.jdx.dev/configuration/settings.html,
  https://mise.jdx.dev/installing-mise.html

## C. Windows install paths

- `irm https://mise.run/powershell | iex`: official release to `~\.local\bin`
  (`mise.exe` + `mise-shim.exe`), user `Path` modified without admin, re-run upgrades;
  self-update stays enabled (no packager marker). https://mise.jdx.dev/installing-mise.html
- `winget install jdx.mise`: recommended; "mise detects WinGet installs by executable
  path and turns self-update off. It directs users to `winget upgrade jdx.mise`."
  https://mise.jdx.dev/packaging.html. The winget manifest tree shows versions up to
  2025.12.13 under `manifests/j/jdx/mise` in the listing fetched, so the winget package
  can trail the GitHub release stream (the docs say the same of Chocolatey; verify the
  current winget version before relying on a feature).
  https://github.com/microsoft/winget-pkgs/tree/master/manifests/j/jdx/mise
- This repo's `win/winget.json` import already pulls packages with
  `--accept-package-agreements --accept-source-agreements`; `--disable-interactivity`
  is also available. https://learn.microsoft.com/en-us/windows/package-manager/winget/import

## Recommendation

Yes, mise tasks can replace the Makefile, and the only hand-installed piece is mise
plus, on macOS, the Command Line Tools dialog (or the `softwareupdate` route run with
sudo from the task). The Nix installers and `darwin-rebuild switch` run from a task
with `raw = true` so sudo can prompt.

Shape:

1. Root `mise.toml` with `[tasks]` only, no `[tools]` or `[env]`, so it never overrides
   `config/mise/config.toml` and needs no trust for the first run. `min_version` pins
   the task features used (`run_windows`, `skip_if`, `confirm`).
2. Tasks: `clt` (macOS, `skip_if = "xcode-select -p"`, sudo softwareupdate route),
   `nix` (`skip_if = "command -v nix"`, Determinate installer with `--no-confirm`, and
   `--init none` only when `systemctl` is absent on WSL), `switch` (macOS: `nix build`
   - `sudo result/sw/bin/darwin-rebuild switch`; Linux/WSL: `nix run .#home-manager --
   switch`; `run_windows = ["pwsh -NoProfile -File win/bootstrap.ps1"]`), `tools`
   (`mise install`), `secrets`, `hooks`, `encrypt`/`decrypt`. OS branching via
   `{{ os() }}` inside `run` or separate `switch:macos` / `switch:linux` tasks with a
   `switch` dispatcher.
3. Keep mise in `base.nix`. Install the bootstrap mise with `MISE_VERSION=v<pinned>
   curl https://mise.run | sh` to `~/.local/bin/mise`, and have the `switch` task end
   with `depends_post = ["cleanup-bootstrap-mise"]` that removes `~/.local/bin/mise`
   once `~/.nix-profile/bin/mise` (Linux) or `/etc/profiles/per-user/$USER/bin/mise`
   (macOS) exists, then runs `mise reshim` from the Nix binary so the shim symlinks
   point at the surviving binary. The two binaries share every directory, so nothing
   else needs migrating. The alternative, keeping `mise.run` as the owner and dropping
   it from Nix, gains `self-update` but loses the flake-pinned version and puts an
   unmanaged binary on every machine; do not do that given ADR 0005.
4. Move the shims prepend from `.zshenv` to `.zprofile` as `eval "$(mise activate zsh
   --shims)"`, keep `eval "$(mise activate zsh)"` in `.zshrc`; that is the documented
   pairing and keeps Zed remote and SSH working.
5. Windows: `winget install jdx.mise` stays the hand step; `mise run switch` then
   dispatches to `bootstrap.ps1` via `run_windows`. Accept that winget-installed mise
   cannot self-update and that the winget package may trail releases.
6. Do not adopt `mise bootstrap` / `[dotfiles]` / `[bootstrap.packages]` now. They
   duplicate what Home Manager and nix-darwin already own here (links, packages,
   activation), and the feature set is moving monthly. Revisit if Nix is ever dropped
   on a platform; `mise bootstrap packages export --format nix` is a migration aid in
   the other direction.

Open risk: the `softwareupdate` placeholder-file trick is a Homebrew workaround, not an
Apple-documented interface. Keep the `xcode-select --install` fallback.
