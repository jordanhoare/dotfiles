#!/bin/bash
set -eu

PROFILE_NAME="Jordan"
SNAP_PROFILES_INI="$HOME/snap/firefox/common/.mozilla/firefox/profiles.ini"

if [ -f "$SNAP_PROFILES_INI" ]; then
    if grep -q "^Name=$PROFILE_NAME\$" "$SNAP_PROFILES_INI"; then
        echo "The '$PROFILE_NAME' profile already exists. Skipping profile creation."
    else
        firefox --CreateProfile "$PROFILE_NAME"
    fi

    DEFAULT_PROFILE=$(grep -m 1 "^Path=" "$SNAP_PROFILES_INI" | cut -d'=' -f2)
    sed -i "s/^StartWithLastProfile=.*/StartWithLastProfile=0/" "$SNAP_PROFILES_INI"
    sed -i "/^Default=/s/^Default=.*/Default=$DEFAULT_PROFILE/" "$SNAP_PROFILES_INI"
fi
