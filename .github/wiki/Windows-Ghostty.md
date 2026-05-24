# Ghostty — Windows Setup

Ghostty on Windows launches your WSL zsh session directly - it is not a separate shell environment. Your starship prompt, tmux, nvim, and all shell config run inside WSL and read from the dotfiles repo on the Windows filesystem.

Ghostty stores its own config at `%APPDATA%\ghostty\config`. Symlink it to the repo so changes stay in sync:

```powershell
$repo = "D:\repositories\dotfiles"
$target = "$env:APPDATA\ghostty"
New-Item -ItemType Directory -Force -Path $target
New-Item -ItemType SymbolicLink -Path "$target\config" -Target "$repo\config\ghostty\config"
```

Restart Ghostty after creating the symlink. Changes to `config/ghostty/config` in the repo are live immediately.
