# Windows bootstrap

## Step 1 - winutil (manual, one-time)

Run in PowerShell as Administrator:

```powershell
irm "https://christitus.com/win" | iex
```

Use winutil to apply tweaks and debloat settings. This is interactive and has no config file - run it once on a fresh Windows install.

## Step 2 - winget

Install all Windows apps from the declarative list:

```powershell
winget import --import-file winget.json --accept-package-agreements --accept-source-agreements
```

This installs WSL, VSCode, Obsidian, Bitwarden, Docker Desktop, Firefox, Claude Code, Ghostty, and Zed.

To export the current state back to the file (if you have added apps and want to capture them):

```powershell
winget export --output winget.json
```

## Step 3 - WSL

WSL is installed by winget above. Complete setup:

```powershell
wsl --install -d Ubuntu-24.04
```

Restart when prompted, then complete the Ubuntu user setup.

## Step 4 - Nix inside WSL

Once inside the WSL shell, install nix following the Linux instructions at https://nixos.org/download/#nix-install-linux

Then clone the dotfiles and activate the WSL configuration:

```bash
git clone git@personal:jordanhoare/dotfiles.git /mnt/d/repositories/dotfiles
cd /mnt/d/repositories/dotfiles
make switch
```

## Step 5 - Windows -> WSL symlinks

> TODO: replace the current ad-hoc PowerShell snippets (.azure, .aws, Zed) with a single declarative bootstrap. Options to consider: a `win/bootstrap.ps1` driven from a manifest, or a managed solution that mirrors the way `make switch` handles the WSL side. The current instructions are brittle (hardcoded distro name, hardcoded username, no idempotency guard beyond `Remove-Item -ErrorAction SilentlyContinue`) and do not belong in a setup guide as raw shell.
