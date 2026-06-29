# ADR 0011 - Windows bootstrap: nix-agnostic, repo-rooted symlinks

## Context

The Linux/WSL/macOS side of the dotfiles is managed entirely by Nix and Home Manager: `make switch` installs packages, links files into `~/.config/...` from the source files at `config/...`, and is the single mental model for "make this machine match the repo." Windows has no native Nix integration, so the same model does not transfer.

Earlier iterations of the Windows-side bootstrap drifted into two problematic patterns:

1. **WSL-rooted symlinks via Home Manager's output.** `%APPDATA%\Zed -> \\wsl.localhost\Ubuntu-24.04\home\jordanhoare\.config\zed`, where the WSL-side `~/.config/zed/` was itself a Home Manager symlink into `/nix/store/.../home-manager-files/.config/zed/`. Windows reaching across a UNC path, into a Home Manager symlink, into a read-only Nix store path is a fragile multi-hop chain that breaks when `/nix/store` regenerates on the next `make switch`.

2. **Raw PowerShell snippets in the setup guide.** `win/README.md` and `.github/wiki/Windows.md` documented ad-hoc `New-Item -ItemType SymbolicLink` invocations with hardcoded distro name (`Ubuntu-24.04`), hardcoded username (`jordanhoare`), and hardcoded repo path (`D:\repositories\dotfiles`). Not idempotent, not declarative, and the targets were inconsistent between the two docs.

Both were marked TODO in earlier commits pending a deliberate design.

## Decision

The Windows side is **intentionally nix-agnostic**. Bootstrap runs through a single script, `win/bootstrap.ps1`, invoked from elevated PowerShell on Windows. Nix is not installed, not invoked, and not referenced anywhere in the Windows bootstrap. The script does two things:

1. `winget import --import-file win/winget.json --accept-package-agreements --accept-source-agreements`
2. Creates per-file **repo-rooted** symlinks for managed Windows-side dotfiles:

   | Target | Source |
   |---|---|
   | `%APPDATA%\Zed\settings.json` | `<repo>\config\zed\settings.json` |
   | `%APPDATA%\Zed\keymap.json` | `<repo>\config\zed\keymap.json` |
   | `%APPDATA%\Zed\tasks.json` | `<repo>\config\zed\tasks.json` |
   | `%APPDATA%\Zed\snippets` | `<repo>\config\zed\snippets` |
   | `%USERPROFILE%\.wslconfig` | `<repo>\win\wslconfig` |

   The repo path is derived from `$PSScriptRoot`, not hardcoded. The Zed entries are parallel to (but independent of) `nix/modules/zed.nix`. `.wslconfig` lives on the Windows side (it is the WSL2 host-level config, read by the WSL hypervisor process before any distro starts) and has no Linux/WSL counterpart - the WSL distro-level config (`/etc/wsl.conf`) is managed separately by `nix/modules/wsl.nix` via a Home Manager activation.

Ghostty is intentionally out of the Windows-side surface. As of mid-2026 there is no official Ghostty Windows release, and the upstream team has asked community ports not to use "Ghostty for Windows" branding. Windows-side terminal use is the Microsoft-shipped Windows Terminal (declared in `win/winget.json`); the actual Ghostty runs inside WSL and is opened either directly under WSL or via Windsurf/VSCode-fork's integrated terminal. Revisit if an official Ghostty Windows package ships.

The script is **idempotent with backup semantics**:
- Target missing -> create symlink.
- Target is a symlink already pointing at the right source -> no-op.
- Target is a symlink pointing somewhere else -> delete and recreate.
- Target is a real file or directory -> rename to `<name>.bak.<timestamp>`, then create symlink.

The script enforces an **elevation precondition**: at start, it checks for Administrator elevation or Windows Developer Mode (registry key `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock\AllowDevelopmentWithoutDevLicense`). If neither is true, it prints a message and exits before `winget import` runs, so the failure mode is clear rather than a confusing access-denied mid-flight.

Stateful credential directories (`.azure`, `.aws`) are **out of scope** for the Windows side. They live in WSL's home directory, are managed by `nix/modules/cloud.nix`, and remain WSL-only. Windows-native `az` / `aws` CLI clients, if ever installed, authenticate independently against their own Windows-side credential paths.

## Consequences

- Windows-side bootstrap works on a fresh Windows machine with only the repo cloned to `D:\repositories\dotfiles`. No WSL distro required, no `wsl --install` required, no `\\wsl.localhost\` UNC paths in the symlink targets.
- The Windows-side symlinks survive `make switch` invocations on the WSL side - they don't depend on `/nix/store` paths that regenerate.
- Windows-side editor UI edits land directly in the repo working tree, visible to `git status`. This contradicts ADR 0007's "intentionally ephemeral" stance, which is preserved only on the WSL side via Home Manager's read-only symlinks. The Windows side accepts a different policy: edits are real and either committed or discarded.
- The link manifest is duplicated between `nix/modules/zed.nix` and `win/bootstrap.ps1`. At the current size (5 entries) the cost of keeping them in sync by hand is lower than the cost of building a shared manifest abstraction. Worth revisiting only if the managed-editor file count grows materially.
- `winget import` is naturally idempotent; re-running the script is safe.
- If the editor decision is ever revisited (see ADR 0010), `bootstrap.ps1`'s symlink manifest is the only Windows-side surface that needs editing, alongside the corresponding Nix module.
