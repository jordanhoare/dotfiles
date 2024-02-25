#!/bin/bash
set -eu


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
# Directories
################################################################################
DOTFILES_DIR="$HOME/.dotfiles"
FUNCTIONS_DIR="$DOTFILES_DIR/shell/functions"
SCRIPTS_DIR="$DOTFILES_DIR/shell/scripts"


################################################################################
# Update system packages & install initial dependencies
################################################################################
if [[ "$(uname -s)" == "Linux" ]]; then
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt install -y libz-dev libssl-dev liblzma-dev libcurl4-gnutls-dev libexpat1-dev gettext cmake gcc
    sudo apt-get install -y git zsh stow
fi

if [[ "$(uname -s)" == "Darwin" ]]; then
    # Install brew (if not already installed)
    if ! command -v brew &> /dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        brew update && brew upgrade
    fi

    install_package() {
    local package=$1
    if ! command -v $package &> /dev/null; then
        brew install $package
    fi
    }
    install_package git
    install_package zsh
    install_package stow
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
chmod +x $HOME/.dotfiles/shell/scripts/*.sh
source "$FUNCTIONS_DIR/logging.sh"
source "$FUNCTIONS_DIR/misc.sh"


################################################################################
# Applications and dependencies
################################################################################
if [[ "$(uname -s)" == "Linux" ]]; then
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt-get install -y git zsh stow
fi

if [[ "$(uname -s)" == "Darwin" ]]; then
    brew update && brew upgrade
    brew bundle --file="$DOTFILES_DIR/brew/Brewfile"
fi


################################################################################
# Terminal and workspace tools
################################################################################
# run_script "$SCRIPTS_DIR/firefox.sh"
run_script "$SCRIPTS_DIR/bitwarden.sh"
run_script "$SCRIPTS_DIR/zsh.sh"
run_script "$SCRIPTS_DIR/alacritty.sh"
# Call ./nvim/setup.sh
# Call ./tmux/setup.sh


################################################################################
# Development ecosystem
################################################################################
run_script "$SCRIPTS_DIR/python.sh"
# Call ./go/setup.sh
# Call ./rust/setup.sh
# Call ./npm/setup.sh
# Call ./dotnet/setup.sh


################################################################################
# VMware fusion (only applicable for Linux ARM servers)
################################################################################
if [[ "$(uname -m)" == *"arm"* ]] || [[ "$(uname -m)" == "aarch64" ]]; then
  sudo apt update -y

  # Check and install tasksel if needed
  if ! dpkg-query -W tasksel &>/dev/null; then
    sudo apt install tasksel -y
  fi

  # Check and install ubuntu-desktop if needed
  if ! dpkg-query -W ubuntu-desktop &>/dev/null; then
    sudo apt install 'ubuntu-desktop^' -y
  fi

  # Check and install open-vm-tools-desktop if needed
  if ! dpkg-query -W open-vm-tools-desktop &>/dev/null; then
    sudo apt install open-vm-tools-desktop -y
  fi
fi


################################################################################
# Symbolic linking for configuration files 
################################################################################
stow --dir=$HOME/.dotfiles/ --target=$HOME --adopt zsh tmux
cd $DOTFILES_DIR
git restore .


################################################################################
# Set default shell
################################################################################
if [ "$SHELL" != "$(which zsh)" ]; then
    sudo chsh -s "$(which zsh)" $USER
fi


###############################################################################
# Reboot warning
###############################################################################
log_warning "❗❗ It is recommended to reboot your machine after running this script. ❗❗"
