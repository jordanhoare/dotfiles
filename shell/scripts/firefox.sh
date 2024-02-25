#!/bin/bash
set -eu

PROFILE_NAME="Jordan"
SNAP_PROFILES_INI="$HOME/snap/firefox/common/.mozilla/firefox/profiles.ini"

# Ensure the profile exists
if [ -f "$SNAP_PROFILES_INI" ]; then
    # Create the profile if it doesn't exist
    if ! grep -q "^Name=$PROFILE_NAME\$" "$SNAP_PROFILES_INI"; then
        firefox --CreateProfile "$PROFILE_NAME"
    fi

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
    echo "The file $SNAP_PROFILES_INI does not exist."
fi
