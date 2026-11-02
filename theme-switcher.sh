#!/bin/bash

# Configure the Unraid theme identifiers and local start hours (0-23) here.
# Schedule this script to run at both configured start hours in User Scripts.
LIGHT_THEME="white"
DARK_THEME="black"
LIGHT_MODE_STARTS_AT=8
DARK_MODE_STARTS_AT=17

# Unraid stores the selected Dynamix theme in this configuration file.
CONFIG_FILE=/boot/config/plugins/dynamix/dynamix.cfg

# Reject invalid hours before using them in arithmetic.
for HOUR_SETTING in "$LIGHT_MODE_STARTS_AT" "$DARK_MODE_STARTS_AT"; do
    if ! [[ "$HOUR_SETTING" =~ ^[0-9]{1,2}$ ]] || (( 10#$HOUR_SETTING > 23 )); then
        echo "Error: switch hours must be whole numbers from 0 to 23." >&2
        exit 1
    fi
done

# Restrict theme identifiers to characters safe for the config-file substitution below.
if [[ ! "$LIGHT_THEME" =~ ^[[:alnum:]_-]+$ ]] || [[ ! "$DARK_THEME" =~ ^[[:alnum:]_-]+$ ]]; then
    echo "Error: theme names may contain only letters, numbers, underscores, and hyphens." >&2
    exit 1
fi

# Both modes cannot start at the same hour because that would make the schedule ambiguous.
if (( 10#$LIGHT_MODE_STARTS_AT == 10#$DARK_MODE_STARTS_AT )); then
    echo "Error: light and dark switch hours must be different." >&2
    exit 1
fi

# Read the Unraid server's local time and the currently selected theme.
CURRENT_HOUR=$(date +%H)
CURRENT_MINUTE=$(date +%M)
CURRENT_HOUR=$((10#$CURRENT_HOUR))

CURRENT_THEME=$(grep -oP 'theme="\K[^"]+' "$CONFIG_FILE")

# Print the current state in the User Scripts log for troubleshooting.
echo "Current theme is: $CURRENT_THEME"
echo "Current time is: $CURRENT_HOUR:$CURRENT_MINUTE"

# Convert configured hours to decimal integers for reliable comparisons.
LIGHT_HOUR=$((10#$LIGHT_MODE_STARTS_AT))
DARK_HOUR=$((10#$DARK_MODE_STARTS_AT))

# Choose the active theme, including schedules where the light period crosses midnight.
if (( LIGHT_HOUR < DARK_HOUR )); then
    if (( CURRENT_HOUR >= LIGHT_HOUR && CURRENT_HOUR < DARK_HOUR )); then
        TARGET_THEME=$LIGHT_THEME
    else
        TARGET_THEME=$DARK_THEME
    fi
elif (( CURRENT_HOUR >= LIGHT_HOUR || CURRENT_HOUR < DARK_HOUR )); then
    TARGET_THEME=$LIGHT_THEME
else
    TARGET_THEME=$DARK_THEME
fi

# Update Unraid's saved theme only when it differs from the active scheduled theme.
if [[ "$CURRENT_THEME" != "$TARGET_THEME" ]]; then
    sed -i "s/theme=\"[^\"]*\"/theme=\"$TARGET_THEME\"/g" "$CONFIG_FILE"
    echo "Theme switched to $TARGET_THEME"
else
    echo "Theme is already $TARGET_THEME, no change needed."
fi

# Read back and log the saved theme so the result is visible in the User Scripts log.
NEW_THEME=$(grep -oP 'theme="\K[^"]+' "$CONFIG_FILE")
echo "New theme is: $NEW_THEME"
