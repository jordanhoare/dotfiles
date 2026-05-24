# VSCode — Windows Setup

VSCode on Windows stores settings at `%APPDATA%\Code\User\`. Symlink them to the repo so changes stay in sync with the tracked config:

```powershell
$repo = "D:\repositories\dotfiles"
$target = "$env:APPDATA\Code\User"
New-Item -ItemType SymbolicLink -Path "$target\settings.json" -Target "$repo\config\Code\User\settings.json"
New-Item -ItemType SymbolicLink -Path "$target\keybindings.json" -Target "$repo\config\Code\User\keybindings.json"
```

Run PowerShell as Administrator, or enable Developer Mode in Windows Settings to create symlinks without elevation.
