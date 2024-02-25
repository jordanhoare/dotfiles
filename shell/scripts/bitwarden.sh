#!/bin/bash
set -eu

# Check if Bitwarden is already installed
if ! [[ "$(uname -m)" == "aarch64" ]]; then
    if snap list | grep -q "bw"; then
        echo "Bitwarden is already installed. Skipping installation."
    else
        sudo snap install bw
    fi
fi