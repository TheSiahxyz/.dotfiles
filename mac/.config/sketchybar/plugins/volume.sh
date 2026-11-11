#!/usr/bin/env bash

# Volume icon plus the popup contents (mute button, slider, percentage).
# The popup items are created once in sketchybarrc; this only updates them.

source "$CONFIG_DIR/colors.sh"

if [ "$SENDER" = "mouse.exited.global" ]; then
  sketchybar --set volume popup.drawing=off
  exit 0
fi

# "output volume:50, input volume:50, alert volume:100, output muted:false"
SETTINGS="$(osascript -e 'get volume settings' 2>/dev/null)"

VOLUME="$(printf '%s' "$SETTINGS" | sed -n 's/.*output volume:\([0-9][0-9]*\).*/\1/p')"
# Outputs without software volume (some HDMI/DP displays) report "missing value".
[ -n "$VOLUME" ] || VOLUME="${INFO:-0}"
case "$VOLUME" in '' | *[!0-9]*) VOLUME=0 ;; esac

case "$SETTINGS" in
*"output muted:true"*) MUTED=true ;;
*) MUTED=false ;;
esac

if [ "$MUTED" = true ] || [ "$VOLUME" -eq 0 ]; then
  ICON="󰖁"
  COLOR=$RED
elif [ "$VOLUME" -gt 75 ]; then
  ICON="󰕾"
  COLOR=$ACCENT_PRIMARY
elif [ "$VOLUME" -gt 50 ]; then
  ICON="󰖀"
  COLOR=$ACCENT_PRIMARY
elif [ "$VOLUME" -gt 25 ]; then
  ICON="󰕿"
  COLOR=$YELLOW
else
  ICON="󰕿"
  COLOR=$ORANGE
fi

if [ "$MUTED" = true ]; then
  MUTE_ICON="󰖁"
  MUTE_COLOR=$RED
else
  MUTE_ICON="󰕾"
  MUTE_COLOR=$GREEN
fi

sketchybar --set volume icon="$ICON" icon.color="$COLOR" \
  --set volume.mute icon="$MUTE_ICON" icon.color="$MUTE_COLOR" \
  --set volume.slider slider.percentage="$VOLUME" \
  --set volume.percent label="$VOLUME%"
