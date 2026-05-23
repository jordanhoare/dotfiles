# Ghostty — Windows Setup

Ghostty on Windows stores its config at `%APPDATA%\ghostty\config`, which maps to:

```
C:\Users\<user>\AppData\Roaming\ghostty\config
```

The tracked config lives at `config/ghostty/config` in this repo and stows correctly on Linux and macOS via `stow -t ~/.config config`. On Windows it must be linked manually.

## Symlinking from PowerShell (run as Administrator, or with Developer Mode enabled)

```powershell
$repo = "D:\repositories\dotfiles"
$target = "$env:APPDATA\ghostty"
New-Item -ItemType Directory -Force -Path $target
New-Item -ItemType SymbolicLink -Path "$target\config" -Target "$repo\config\ghostty\config"
```

## After setup

Restart Ghostty. Changes to `config/ghostty/config` in the repo are live immediately via the symlink.
