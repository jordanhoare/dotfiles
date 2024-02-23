#!/bin/bash
set -eu

# Determine OS
OS="$(uname -s)"
BREWFILE="$HOME/.dotfiles/Brewfile"
export XDG_CONFIG_HOME="$HOME"/.config

# Install brew (if not already installed)
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # For Linux, append Homebrew to the current session's PATH
    if [[ "$OS" == "Linux" ]]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
fi

# Function to install a package if it's not already installed
install_package() {
    local package=$1
    if ! command -v $package &> /dev/null; then
        brew install $package
    fi
}

# Install packages
install_package git
install_package zsh
install_package stow

# Change the default shell to Zsh (if not already changed)
if [ "$SHELL" != "$(which zsh)" ]; then
    sudo chsh -s $(which zsh)
fi

# Clone the dotfiles to ~/.dotfiles (if not already cloned)
if [ ! -d "$HOME/.dotfiles" ]; then
    git clone https://github.com/jordanhoare/dotfiles.git $HOME/.dotfiles 
fi

# Alacritty themes
if [ ! -d "$HOME/.config/alacritty" ]; then
    mkdir -p "$XDG_CONFIG_HOME"/alacritty
    mkdir -p "$XDG_CONFIG_HOME"/alacritty/themes
    git clone https://github.com/alacritty/alacritty-theme "$XDG_CONFIG_HOME"/alacritty/themes
fi

# Install Brew applications/libraries from Brewfile
brew bundle --file="$BREWFILE"

# Create symbolic links for the configuration files 
stow --dir=$HOME/.dotfiles/ --target=$HOME zsh

exec zsh
