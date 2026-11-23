#!/usr/bin/env bash

# Source colors and icons for consistent theming
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

# An empty workspace has no front app. macOS keeps the previous app frontmost
# there (and fires no front_app_switched), so ask AeroSpace instead.
if [ "$(aerospace list-windows --workspace focused --count 2>/dev/null)" = "0" ]; then
    sketchybar --set "$NAME" drawing=off
    exit 0
fi

# Get the current application
if [ "$SENDER" = "front_app_switched" ]; then
    APP_NAME="$INFO"
else
    # Startup, workspace change, window opened/closed: no app payload, so ask AeroSpace.
    APP_NAME="$(aerospace list-windows --focused --format '%{app-name}' 2>/dev/null | head -n 1)"
    [ -n "$APP_NAME" ] || APP_NAME="$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null)"
fi

# Icon mapping for common applications
case $APP_NAME in
    "Cursor")
        ICON="󰨞"
        ;;
    "Visual Studio Code")
        ICON="󰨞"
        ;;
    "Slack")
        ICON="󰒱"
        ;;
    "Discord")
        ICON="󰙯"
        ;;
    "Google Chrome")
        ICON="󰊯"
        ;;
    "Safari")
        ICON="󰀹"
        ;;
    "Firefox")
        ICON="󰈹"
        ;;
    "Terminal")
        ICON="󰆍"
        ;;
    "iTerm2")
        ICON="󰆍"
        ;;
    "Finder")
        ICON="󰀶"
        ;;
    "Spotify")
        ICON="󰓇"
        ;;
    "Music")
        ICON="󰎆"
        ;;
    "Mail")
        ICON="󰇮"
        ;;
    "Messages")
        ICON="󰍦"
        ;;
    "FaceTime")
        ICON="󰍫"
        ;;
    "Zoom")
        ICON="󰊶"
        ;;
    "Notion")
        ICON="󰈭"
        ;;
    "Obsidian")
        ICON="󰈭"
        ;;
    "Xcode")
        ICON="󰙳"
        ;;
    "Docker")
        ICON="󰡨"
        ;;
    "Figma")
        ICON="󰤼"
        ;;
    "Sketch")
        ICON="󰤼"
        ;;
    "Photoshop")
        ICON="󰤿"
        ;;
    "System Preferences")
        ICON="󰒓"
        ;;
    "System Settings")
        ICON="󰒓"
        ;;
    "Activity Monitor")
        ICON="󰖚"
        ;;
    *)
        # Default icon for unknown applications
        ICON="󰄛"
        ;;
esac

# Update the front_app item
sketchybar --set "$NAME" drawing=on \
                        icon="$ICON" \
                        icon.color=$ACCENT_QUATERNARY \
                        label="$APP_NAME" \
                        label.color=$WHITE
