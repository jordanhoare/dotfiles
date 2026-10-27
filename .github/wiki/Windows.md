# Windows

Windows-native apps are managed declaratively via [winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/) and activated through `win/bootstrap.ps1`, which `mise run switch` runs on Windows. The app list lives at `win/winget.json`; the Windows-side symlink design is described in [ADR 0011](https://github.com/jordanhoare/dotfiles/blob/main/.claude/docs/adr/0011-windows-bootstrap.md). Everything else - shell, prompt, tmux, nvim - runs inside WSL and reads config from the dotfiles repo on the Windows filesystem.

## 1. winutil (one-time)

Run in PowerShell as Administrator to debloat a fresh Windows install:

```powershell
irm "https://christitus.com/win" | iex
```

## 2. Install

From an elevated PowerShell (or any PowerShell if Developer Mode is enabled in **Settings -> For developers**). One command: it installs git and mise with winget, clones the repo to `D:\repositories\dotfiles`, then runs `mise run bootstrap`, which runs `win\bootstrap.ps1`.

```powershell
irm https://raw.githubusercontent.com/jordanhoare/dotfiles/main/install.ps1 | iex
```

`bootstrap.ps1` imports every app declared in `win/winget.json`, then links the Zed, mise, uv, git, SSH and Claude Code configs from the repo and puts mise's shims on the user `Path`. Idempotent - re-run it as `mise run switch` after editing `win/winget.json`, adding a skill, or adding files under `config/zed/`. See [ADR 0014](https://github.com/jordanhoare/dotfiles/blob/main/.claude/docs/adr/0014-native-windows-development.md) for native Windows development.

Open a new shell afterwards so the `Path` change applies.

## 3. Restore secrets

Restores both SSH keys and gh logins from Bitwarden, then decrypts every `*.sops` file. Repos under `D:\repositories\private\` pick up the private identity, as they do from WSL.

```powershell
mise run secrets
```

Ghostty has no official Windows release as of mid-2026 and community ports do not meet the bar for inclusion. Windows-side terminal use defaults to Windows Terminal (preinstalled on Windows 11, declared in `winget.json` for explicitness); the actual Ghostty runs inside WSL via `mise run switch`.

If you've added Windows apps manually and want to capture them in the manifest:

```powershell
winget export --output D:\repositories\dotfiles\win\winget.json
```

## 4. WSL (optional)

If you also want the Linux side of the dotfiles active:

```powershell
wsl --install -d Ubuntu-24.04
```

Restart when prompted and complete the Ubuntu user setup.

## 5. Inside WSL

The same entry script as Linux. On WSL it reuses the clone at `/mnt/d/repositories/dotfiles` (see ADR 0006), so the one checkout serves both sides. The `nix` task enables systemd in `/etc/wsl.conf` on the first run and asks for a `wsl --shutdown` from Windows; rerun `mise run bootstrap` after the distro restarts.

```bash
curl -fsSL https://raw.githubusercontent.com/jordanhoare/dotfiles/main/install.sh | sh
```

## 6. Restore secrets in WSL

Logs in to Bitwarden, restores both SSH keys, and decrypts every `*.sops` file to its target:

```bash
mise run secrets
```

## 7. Swap remote to SSH

```bash
git remote set-url origin git@personal:jordanhoare/dotfiles.git
```

Done. See [Home](Home) for updating, identity switching, and other daily ops.
