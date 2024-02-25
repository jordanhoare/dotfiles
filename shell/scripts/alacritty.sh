#!/bin/bash
set -e

# Download Alacritty themes
if [ ! -d "$HOME/.config/alacritty/themes" ]; then
    mkdir -p "$HOME"/.config/alacritty
    mkdir -p "$HOME"/.config/alacritty/themes
    git clone https://github.com/alacritty/alacritty-theme "$HOME"/.config/alacritty/themes
fi
