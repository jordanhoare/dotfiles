#!/bin/bash
set -eu

OH_MY_ZSH_INSTALL_SCRIPT_URL="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
OH_MY_ZSH_DIR="$HOME/.oh-my-zsh"
THEME_REPO_URL="https://github.com/ChesterYue/ohmyzsh-theme-passion"
THEME_DIR="$HOME/.config/ohmyzsh/themes"

# Check if Oh My Zsh is already installed
if [ ! -d "$OH_MY_ZSH_DIR" ]; then
    # Will not try to change the default shell, and won't run zsh when the installation has finished.
    sh -c "$(curl -fsSL "$OH_MY_ZSH_INSTALL_SCRIPT_URL")" "" --unattended
else
    echo "Oh My Zsh is already installed. Skipping installation."
fi

# Download the 'passion' theme
if [ ! -d "$THEME_DIR/ohmyzsh-theme-passion" ]; then
    mkdir -p "$THEME_DIR"
    git clone "$THEME_REPO_URL" "$THEME_DIR/ohmyzsh-theme-passion"
fi

# Ensure the theme is copied to the Oh My Zsh themes directory
cp "$THEME_DIR/ohmyzsh-theme-passion/passion.zsh-theme" "$OH_MY_ZSH_DIR/themes/passion.zsh-theme"
