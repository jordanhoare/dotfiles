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

This installs WSL, VSCode, Obsidian, Bitwarden, Docker Desktop, Firefox, Claude Code, and Ghostty.

To export the current state back to the file (if you have added apps and want to capture them):

```powershell
winget export --output winget.json
```

## Step 3 - WSL

WSL is installed by winget above. Complete setup:

```powershell
wsl --install -d Ubuntu
```

Restart when prompted, then complete the Ubuntu user setup.

## Step 4 - Nix inside WSL

Once inside the WSL shell:

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

Then activate the WSL configuration:

```bash
git clone git@personal:jordanhoare/dotfiles.git ~/repositories/dotfiles
home-manager switch --flake ~/repositories/dotfiles/nix#jordan@wsl
```

## VSCode extensions

Extensions are not managed by winget. Install them from the extensions list in `../config/Code/User/` or run:

```powershell
code --install-extension jnoortheen.nix-ide
# ... add others as needed
```
