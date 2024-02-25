#!/bin/bash
set -eu

sudo apt-get update && sudo apt-get upgrade -y


# For ARM Linux OS
if [[ "$(uname -s)" == "Linux" && "$(uname -m)" != "aarch64" ]]; then
    # Set up rbenv (3.14)
    sudo curl -sSL https://raw.githubusercontent.com/jordanhoare/dotfiles/main/rbenv/setup.sh | bash


    git clone https://github.com/Homebrew/linuxbrew.git ~/.linuxbrew
    export PATH="$HOME/.linuxbrew/bin:$PATH"
    export MANPATH="$HOME/.linuxbrew/share/man:$MANPATH"
    export INFOPATH="$HOME/.linuxbrew/share/info:$INFOPATH"

    git -C /home/ubuntu/.linuxbrew/Library/Taps/homebrew/homebrew-core fetch --unshallow
    source ~/.bashrc
    
fi

