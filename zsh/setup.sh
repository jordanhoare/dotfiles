#!/bin/bash
set -eu

# Zsh environment setup steps...

# Change the default shell to Zsh (if not already changed)
if [ "$SHELL" != "$(which zsh)" ]; then
    sudo chsh -s $(which zsh)
fi
