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

<br>

## Virtualisation and distros 

### VMWare
MacOS (ARM): https://www.vmware.com/products/fusion/fusion-evaluation.html
Windows: https://ubuntu.com/download/server/arm

### Ubuntu (ARM)
Distro: https://ubuntu.com/download/server/arm

#### Installation

You can install the complete ubuntu-desktop task in Ubuntu Server by running the following command:

sudo apt install -y ubuntu-desktop^

Here are some additional tips for installing an Ubuntu desktop using VMware Fusion 13 player for macOS.

- Use the Ubuntu Server 22.04.2 LTS ARM64 ISO to install an Ubuntu 22.04 virtual machine.
- After the installation of Ubuntu 22.04 is finished convert the Ubuntu Server using the tasksel program which can be installed by `sudo apt install tasksel`. Install the Ubuntu desktop task by selecting it with the space key in tasksel and remove every server task that you don't want to keep.
- Install the open-vm-tools-desktop package in Ubuntu with `sudo apt install open-vm-tools-desktop~`.
- `serverx`

