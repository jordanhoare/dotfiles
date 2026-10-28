# ADR 0014 - Native Windows development for Windows-target projects

## Context

ADR 0006 puts repos on `/mnt/d` so a Windows toolchain can reach them from WSL, and ADR 0011 keeps the Windows side to apps and editor config. Lantern changes the balance. It builds a Windows executable with the MSVC toolchain, and every run and host test needs the Windows desktop: topmost windows, display affinity, reading another process's memory. Driving that from WSL costs three things:

- A cross-compile with mingw or `cargo-xwin`, which is not the MSVC toolchain the release ships
- Interop to launch each binary, with no worktree support, because a Windows toolchain cannot build a worktree on ext4 (ADR 0013)
- git over drvfs/9p on every operation

Native Windows already had Claude Code, git, gh, MSVC Build Tools and a Windows SDK. It lacked mise, the Claude Code agent layer from ADR 0012, the SSH host aliases and the shared git config.

## Decision

Projects that build Windows binaries are developed on native Windows, with Claude Code running there. `win/bootstrap.ps1` brings native Windows to parity with the WSL agent layer:

| Target | Source | Mode |
|---|---|---|
| `%USERPROFILE%\.config\mise\config.toml` | `win\mise.toml` | Symlink |
| `%APPDATA%\uv\uv.toml` | `config\uv\uv.toml` | Symlink |
| `%USERPROFILE%\.config\git\{config,attributes,personal,hooks\agent-push-guard}` | `config\git\...` | Symlink |
| `%USERPROFILE%\.ssh\config` | `home\.ssh\config` | Copy |
| `%USERPROFILE%\.claude\{AGENTS.md,CLAUDE.md,settings.json,hooks,output-styles}` | `home\.claude\...` | Symlink |
| `%USERPROFILE%\.claude\skills\<skill>` | each `home\.claude\skills\<bucket>\<skill>` | Symlink |

- mise owns runtimes on Windows as it does on WSL. It installs rustup itself, and `win/mise.toml` enables the `rust` idiomatic file, so a repo's `rust-toolchain.toml` outranks the global `rust` entry. No global rustup or uv comes from winget
- `win/mise.toml` is a separate file that mirrors `config/mise/config.toml`, minus dotnet and cmake, which winget owns, and localstack, which only runs in WSL. Every other baseline tool has a Windows build
- The script prepends `%LOCALAPPDATA%\mise\shims` to the user `Path`. The non-interactive shells Claude Code spawns never run `mise activate`
- `mise run secrets` runs `.mise/tasks/secrets.ps1`, which restores `~/.ssh/personal` and `~/.ssh/private` and logs gh in to both accounts from Bitwarden, as `secrets.sh` does on Unix
- `jq` and `delta` come from winget, because the Claude hooks need `jq` and `config/git/config` sets `delta` as the pager
- `mise run secrets` decrypts every Sops file on Windows as on WSL (ADR 0017), the private identity among them
- The private profile works on Windows. `config/git/config` carries each private `includeIf` twice, as the `/mnt/d/...` path WSL sees and the `D:/...` path Windows sees, so a private repo gets the private identity from either side
- Worktrees go to `%USERPROFILE%\worktrees\<repo>\<name>`, the same `~/worktrees` rule as ADR 0013. On NTFS it changes nothing about speed

## Considered Options

- **WSL with a cross-compiler.** Rejected: mingw is not the shipped toolchain, and each run needs interop.
- **Claude in WSL driving Windows `cargo.exe` on `/mnt/d`.** The cheapest setup, because the agent layer is already linked. Rejected: it keeps git on 9p and cannot use ext4 worktrees.
- **Global rustup and uv from winget.** Rejected: mise already pins each tool per project on WSL, and a second installer splits the mental model across platforms.

## Consequences

- `win/bootstrap.ps1` now duplicates link entries from `nix/modules/base.nix` and `nix/modules/git.nix`. ADR 0011 accepted this cost at five entries. The skills, which are the bulk of the surface, are discovered by walking the buckets, so a new skill needs no change on either side.
- An existing `%USERPROFILE%\.gitconfig` is read after `~/.config/git/config`, so a `[user]` section there overrides the personal identity. The script warns and leaves the file alone, because that file may carry machine-local includes.
- The Claude hooks are bash and run through Git Bash on Windows. A missing `jq` makes `block-dangerous-git.sh` read an empty command and allow it, so `jq` is a hard dependency.
- Windows-side Claude edits to `settings.json` land in the repo working tree, as ADR 0011 already accepts for Zed.
- Claude Code project memory is off on every platform (`autoMemoryEnabled: false`). Facts that matter live in the repo, so a move between WSL and Windows loses nothing.
