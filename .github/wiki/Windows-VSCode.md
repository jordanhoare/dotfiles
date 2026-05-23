# VSCode — Windows Setup

VSCode config is tracked at `config/Code/User/` and stows to `~/.config/Code/User/` on Linux and macOS automatically.

On Windows, VSCode stores settings at `%APPDATA%\Code\User\`, which maps to:

```
C:\Users\<user>\AppData\Roaming\Code\User\settings.json
C:\Users\<user>\AppData\Roaming\Code\User\keybindings.json
```

## Recommended: Settings Sync

Use VSCode's built-in Settings Sync (sign in with GitHub account) to keep settings, keybindings, and extensions in sync across machines automatically.

## Alternative: Manual symlink from PowerShell (Developer Mode or run as Administrator)

```powershell
$repo = "D:\repositories\dotfiles"
$target = "$env:APPDATA\Code\User"
New-Item -ItemType SymbolicLink -Path "$target\settings.json" -Target "$repo\config\Code\User\settings.json"
New-Item -ItemType SymbolicLink -Path "$target\keybindings.json" -Target "$repo\config\Code\User\keybindings.json"
```
