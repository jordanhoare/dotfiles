# Windows

Windows-native apps are managed declaratively via [winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/). The app list lives at `win/winget.json`. Everything else - shell, prompt, tmux, nvim - runs inside WSL and reads config from the dotfiles repo on the Windows filesystem.

## 1. winutil (one-time)

Run in PowerShell as Administrator to debloat a fresh Windows install:

```powershell
irm "https://christitus.com/win" | iex
```

## 2. winget

```powershell
winget import --import-file D:\repositories\dotfiles\win\winget.json --accept-package-agreements --accept-source-agreements
```

Installs WSL, Obsidian, Bitwarden, Docker Desktop, Firefox, Claude Code, the GitHub CLI (`gh`), Ghostty, and Zed.

Re-run after editing `win/winget.json` - never install Windows apps manually.

## 3. WSL

```powershell
wsl --install -d Ubuntu
```

Restart when prompted and complete the Ubuntu user setup.

## 4. Inside WSL

```bash
sudo apt install -y git curl make
```

Install Nix: https://nixos.org/download/#nix-install-linux

Open a new shell to pick up the Nix environment.

## 5. Clone

Clone to `/mnt/d/repositories/dotfiles` so it survives a WSL reinstall and stays reachable from Windows apps.

```bash
mkdir -p /mnt/d/repositories
git clone https://github.com/jordanhoare/dotfiles.git /mnt/d/repositories/dotfiles
cd /mnt/d/repositories/dotfiles
```

## 6. Activate

Installs every package, links every config file, and applies the dotfiles to your home directory.

```bash
make switch
```

## 7. Restore secrets

Logs in to Bitwarden, restores both SSH keys, and decrypts the private git profile to `~/.config/git/private`.

```bash
make secrets
```

## 8. Swap remote to SSH

```bash
git remote set-url origin git@personal:jordanhoare/dotfiles.git
```

Done. See [Home](Home) for updating, identity switching, and other daily ops.

## App symlinks

> TODO: replace the per-app PowerShell snippets (Ghostty, Zed, plus the .azure/.aws pair documented in `win/README.md`) with a single declarative bootstrap. Candidates: a `win/bootstrap.ps1` driven from a manifest, or a managed solution that mirrors the way `make switch` handles the WSL side. The current instructions are brittle (hardcoded repo path, hardcoded distro name, hardcoded username, mixed `D:\` vs `\\wsl.localhost\` targets, no idempotency guard) and do not belong in a setup guide as raw shell.
