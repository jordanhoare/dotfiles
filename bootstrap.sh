#!/bin/bash
set -eu

# Install brew (if not already installed)
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install git (if not already installed)
if ! command -v git &> /dev/null; then
    brew install git
fi

# Install zsh (if not already installed)
if ! command -v zsh &> /dev/null; then
    brew install zsh
fi

# Install zsh (if not already installed)
if ! command -v stow &> /dev/null; then
    brew install stow
fi

# Change the default shell to Zsh
chsh -s $(which zsh)

# Clone the dotfiles to ~/.dotfiles
git clone https://github.com/jordanhoare/dotfiles.git $HOME/.dotfiles

# Create symbolic links for the configuration files 
stow --dir=$HOME/.dotfiles/ --target=$HOME zsh

exec zsh
