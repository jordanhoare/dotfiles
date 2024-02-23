# dotfiles

Two-step process to initialise a development environment on a fresh install of either Linux or macOS.

1. Installs brew, git, zsh (sets to default), and sym links a clone @ ~/.dotfiles:
```bash
curl -sSL https://raw.githubusercontent.com/jordanhoare/dotfiles/main/bootstrap.sh | bash
```
2. Sets up development environment:
```zsh
cd $HOME/.dotfiles && ./setup.zsh
```
