#!/bin/bash
set -eu

PROFILE_NAME="Jordan"
FIREFOX_DIR="$HOME/.mozilla/firefox"
SNAP_PROFILES_INI="$FIREFOX_DIR/profiles.ini"

# Launch Firefox silently to ensure profiles.ini is created if Firefox has never been started
if [ ! -d "$FIREFOX_DIR" ]; then
    firefox -headless &
    sleep 5 # Give Firefox some time to initialize
    pkill firefox # Stop Firefox after initialization
fi

# Ensure the profile exists
if [ -f "$SNAP_PROFILES_INI" ]; then
    # Create the profile if it doesn't exist
    if ! grep -q "^Name=$PROFILE_NAME\$" "$SNAP_PROFILES_INI"; then
        firefox --CreateProfile "$PROFILE_NAME"
        # Wait a bit to ensure the profile is created
        sleep 2
    fi

    # Re-check for the existence of profiles.ini in case it needed to be created
    if [ -f "$SNAP_PROFILES_INI" ]; then
        # Find the "Jordan" profile path
        JORDAN_PROFILE_PATH=$(grep -A1 "^Name=$PROFILE_NAME\$" "$SNAP_PROFILES_INI" | grep "^Path=" | cut -d'=' -f2)

        # Ensure the path was found
        if [ -n "$JORDAN_PROFILE_PATH" ]; then
            # Set "Jordan" as the default profile
            sed -i "/^\[General\]/a Default=$JORDAN_PROFILE_PATH" "$SNAP_PROFILES_INI"

            # Disable "StartWithLastProfile" prompt
            sed -i "s/^StartWithLastProfile=.*/StartWithLastProfile=0/" "$SNAP_PROFILES_INI"
        else
            echo "Could not find the path for the '$PROFILE_NAME' profile."
        fi
    else
        echo "Failed to create profiles.ini."
    fi
else
    echo "The file $SNAP_PROFILES_INI does not exist and could not be created."
fi
