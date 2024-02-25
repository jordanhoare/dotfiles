#!/bin/bash
set -eu

# Check if Bitwarden is already installed
if snap list | grep -q "bw"; then
    echo "Bitwarden is already installed. Skipping installation."
else
    sudo snap install bw
fi
