# Windows bootstrap

## Step 1 - winutil (manual, one-time)

Run in PowerShell as Administrator:

```powershell
irm "https://christitus.com/win" | iex
```

Use winutil to apply tweaks and debloat settings. This is interactive and has no config file - run it once on a fresh Windows install.

## Step 2 - install

From an elevated PowerShell (or any PowerShell if Developer Mode is enabled in Settings > For developers):

```powershell
irm https://raw.githubusercontent.com/jordanhoare/dotfiles/main/install.ps1 | iex
```

`install.ps1` installs git and mise with winget, clones the repo to `D:\repositories\dotfiles`, and runs `mise run bootstrap`. On Windows that runs `win\bootstrap.ps1`: `winget import` against `win/winget.json`, then links the Zed, mise, uv, git, SSH and Claude Code configs from the repo into `%APPDATA%` and `%USERPROFILE%`, puts mise's shims on the user `Path`, and strips nvm for Windows from the `Path` and environment because runtimes come from mise (ADR 0002). Idempotent: rerun as `mise run switch` after adding apps to `winget.json`, skills, or files to `config/zed/`. See ADR 0011, ADR 0014 and ADR 0016.

Open a new shell afterwards so the `Path` change applies.

## Step 3 - secrets

Restore the personal SSH key and gh login from Bitwarden:

```powershell
mise run secrets
```

The private profile stays WSL-only (ADR 0014). If the bootstrap warns that `%USERPROFILE%\.gitconfig` sets `[user]`, delete that section so the personal identity applies.

Ghostty has no official Windows release as of mid-2026 and community ports do not meet the bar for inclusion. Windows-side terminal use defaults to Windows Terminal (preinstalled on Windows 11, declared in `winget.json` for explicitness); the actual Ghostty runs inside WSL via `mise run switch`.

To export the current installed-app state back into `winget.json` (after manually adding apps and wanting to capture them):

```powershell
winget export --output winget.json
```

## Step 4 - WSL (optional)

If you also want the Linux side of the dotfiles active, install WSL:

```powershell
wsl --install -d Ubuntu-24.04
```

Restart when prompted, then complete the Ubuntu user setup. Inside the WSL shell run the same entry script as Linux. It reuses the clone at `/mnt/d/repositories/dotfiles` (ADR 0006), enables systemd in `/etc/wsl.conf`, and asks for one `wsl --shutdown` before installing Nix; rerun `mise run bootstrap` after the restart.

```bash
curl -fsSL https://raw.githubusercontent.com/jordanhoare/dotfiles/main/install.sh | sh
```
