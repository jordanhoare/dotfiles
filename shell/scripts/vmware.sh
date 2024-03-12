#!/bin/bash
set -eu


if [[ "$(uname -m)" == *"arm"* ]] || [[ "$(uname -m)" == "aarch64" ]] || [[ "$(uname -m)" == "x86_64" ]]; then
  sudo apt update -y

  # Check and install ubuntu-desktop if needed
  if ! dpkg-query -W ubuntu-desktop &>/dev/null; then
    sudo apt install 'ubuntu-desktop^' -y

    # Check and install tasksel if needed
    if ! dpkg-query -W tasksel &>/dev/null; then
      sudo apt install tasksel -y
    fi

    # Check and install open-vm-tools-desktop if needed
    if ! dpkg-query -W open-vm-tools-desktop &>/dev/null; then
      sudo apt install open-vm-tools-desktop -y
    fi

  fi

fi
