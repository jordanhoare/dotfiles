#!/bin/bash

# Suggests or performs a system reboot
suggest_reboot() {
    read -p "Would you like to reboot now? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo "Rebooting now..."
        sudo reboot
    else
        echo "Please remember to reboot your machine later."
    fi
}
