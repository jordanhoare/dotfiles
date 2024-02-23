#!/bin/bash
set -eu


DOTFILES_DIR="$HOME/.dotfiles"
SHELL_FUNCTIONS_DIR="$DOTFILES_DIR/shell/functions"


################################################################################
# Ask for root password upfront and keep updating the existing `sudo`
# timestamp on a background process until the script finishes. Note that
# you'll still need to use `sudo` where needed throughout the scripts.
################################################################################
sudo -v
while true; do
  sudo -n true
  sleep 30
  kill -0 "$$" || exit
done 2>/dev/null &


################################################################################
# Initial dependencies
################################################################################
if ! command -v rustc &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --no-modify-path --verbose -y
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# Install brew (if not already installed)
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# For Linux, append Homebrew to the current session's PATH
if [[ "$(uname -s)" == "Linux" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Function to install a package if it's not already installed
install_package() {
    local package=$1
    if ! command -v $package &> /dev/null; then
        brew install $package
    fi
}
install_package git
install_package zsh
install_package stow


################################################################################
# Update and upgrade system packages (MacOS, add Linux equivalent)
################################################################################
if [[ "$(uname -s)" == "Linux" ]]; then
    sudo apt-get update && sudo apt-get upgrade -y
fi

if [[ "$(uname -s)" == "Darwin" ]]; then
    brew update && brew upgrade
fi


################################################################################
# Clone the dotfiles to ~/.dotfiles
################################################################################
if [ ! -d "$HOME/.dotfiles" ]; then
    git clone https://github.com/jordanhoare/dotfiles.git $HOME/.dotfiles 
fi


################################################################################
# Import helper logging functions
################################################################################
source "$SHELL_FUNCTIONS_DIR/logging.sh"
source "$SHELL_FUNCTIONS_DIR/misc.sh"
source "$SHELL_FUNCTIONS_DIR/reboot.sh"


################################################################################
# Import helper logging functions
################################################################################


################################################################################
# Applications and dependencies
################################################################################
log_info "Installing packages from Brewfile..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

if [[ "$(uname -s)" == "Linux" ]]; then
    sudo snap install firefox
    cargo install alacritty
fi


################################################################################
# Shell tools
################################################################################
# Call ./zsh/setup.sh


################################################################################
# Development tools and managers
################################################################################
# Call ./python/setup.sh
run_script "$DOTFILES_DIR/python/setup.sh"

# Call ./go/setup.sh
# Call ./rust/setup.sh
# Call ./npm/setup.sh


################################################################################
# Developer environment
################################################################################
# Call ./nvim/setup.sh
# Call ./tmux/setup.sh


###############################################################################
# Reboot
###############################################################################
log_warning "❗❗ It is recommended to reboot your machine after running this script. ❗❗"
suggest_reboot
