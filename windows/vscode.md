# VSCode — Windows Setup

VSCode on Windows stores settings at `%APPDATA%\Code\User\`, which maps to:

```
C:\Users\<user>\AppData\Roaming\Code\User\settings.json
C:\Users\<user>\AppData\Roaming\Code\User\keybindings.json
```

## Recommended: Settings Sync

Use VSCode's built-in Settings Sync (sign in with GitHub account) to keep settings, keybindings, and extensions in sync across machines automatically. This is the canonical cross-machine solution for VSCode.

## Alternative: Manual symlink from PowerShell

If you prefer git-tracked settings over Settings Sync:

```powershell
$repo = "D:\repositories\dotfiles"
$target = "$env:APPDATA\Code\User"
New-Item -ItemType SymbolicLink -Path "$target\settings.json" -Target "$repo\todo\vscode\settings.json"
New-Item -ItemType SymbolicLink -Path "$target\keybindings.json" -Target "$repo\todo\vscode\keybindings.json"
```
