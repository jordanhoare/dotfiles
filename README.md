# dotfiles

Personal dotfiles for WSL, Linux, and macOS. Managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Setup

```bash
git clone git@personal:jordanhoare/dotfiles.git ~/repositories/dotfiles
stow -d ~/repositories/dotfiles -t ~ home
stow -d ~/repositories/dotfiles -t ~/.config config
```
