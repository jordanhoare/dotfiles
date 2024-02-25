#!/usr/bin/env zsh

BREWFILE="$HOME/.dotfiles/Brewfile"
BREWFILE="$HOME/.dotfiles/Brewfile"
brew bundle --file="$BREWFILE" --build-from-source


export XDG_CONFIG_HOME="$HOME"/.config

mkdir -p "$XDG_CONFIG_HOME"/bash
mkdir -p "$XDG_CONFIG_HOME"/skhd
mkdir -p "$XDG_CONFIG_HOME"/k9s
mkdir -p "$XDG_CONFIG_HOME"/alacritty
mkdir -p "$XDG_CONFIG_HOME"/alacritty/themes

git clone https://github.com/alacritty/alacritty-theme "$XDG_CONFIG_HOME"/alacritty/themes

# Install Brew applications/libraries from Brewfile
brew bundle --file="$BREWFILE"

# Create symbolic links for the configuration files 
stow --dir=$HOME/.dotfiles/ --target=$HOME zsh

# Alacritty themes
if [ ! -d "$HOME/.config/alacritty" ]; then
    export XDG_CONFIG_HOME="$HOME"/.config
    mkdir -p "$XDG_CONFIG_HOME"/alacritty
    mkdir -p "$XDG_CONFIG_HOME"/alacritty/themes
    git clone https://github.com/alacritty/alacritty-theme "$XDG_CONFIG_HOME"/alacritty/themes
fi

# Install Homebrew packages and applications from Brewfile
brew bundle


