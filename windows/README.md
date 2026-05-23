# Windows Manual Config

Some tools install on Windows and store config in `%APPDATA%` or other Windows paths that cannot be reached by stow from WSL. This directory documents what needs to be handled manually on a Windows machine.

| Tool | Config tracked in repo | Windows config path |
|---|---|---|
| Ghostty | `config/ghostty/config` | `%APPDATA%\ghostty\config` |
| VSCode | `todo/vscode/` | `%APPDATA%\Code\User\` |

For each tool, see its dedicated note below for the manual steps.
