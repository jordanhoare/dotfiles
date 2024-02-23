# dotfiles

Two-step process to initialise a development environment on a fresh install of either Linux or macOS.

1. Sets up development environment, and sym links a clone @ ~/.dotfiles:
```bash
sudo curl -sSL https://raw.githubusercontent.com/jordanhoare/dotfiles/main/bootstrap.sh | bash
```

<br>

## Windows (Ubuntu WSL)
1. Chocolatey: [https://chocolatey.org/install]
1. choco install microsoft-windows-terminal --pre
1. Get gruvbox-material color scheme for Windows Terminal.
1. Open the settings.json in windows preview by opening a new tab and click on Settings while holding shift
1. Paste in the colorschemes and asssign it to the Ubuntu profile in Windows Terminal