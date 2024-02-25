#!/bin/bash
set -eu

OH_MY_ZSH_INSTALL_SCRIPT_URL="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
OH_MY_ZSH_DIR="$HOME/.oh-my-zsh"

# Check if Oh My Zsh is already installed
if [ ! -d "$OH_MY_ZSH_DIR" ]; then
    # Will not try to change the default shell, and won't run zsh when the installation has finished.
    sh -c "$(curl -fsSL "$OH_MY_ZSH_INSTALL_SCRIPT_URL")" "" --unattended
else
    echo "Oh My Zsh is already installed. Skipping installation."
fi
