#!/usr/bin/env bash

# Shows the AeroSpace binding mode (apps, music, layout, ...) while a chord is
# pending, like dwm shows a pending keychord. Hidden in main mode.

source "$CONFIG_DIR/colors.sh"

mode="$(aerospace list-modes --current 2>/dev/null | head -n 1)"

if [ -z "$mode" ] || [ "$mode" = "main" ]; then
  sketchybar --set "$NAME" drawing=off
else
  sketchybar --set "$NAME" drawing=on label="$mode"
fi
