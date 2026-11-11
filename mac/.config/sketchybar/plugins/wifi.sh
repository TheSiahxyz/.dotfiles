#!/usr/bin/env bash

# Wi-Fi status. Connected means the Wi-Fi interface has an IPv4 address.
# (networksetup -getairportnetwork no longer reports the SSID on current
# macOS, system_profiler takes seconds, and scutil --nc lists VPNs, not Wi-Fi.)

source "$CONFIG_DIR/colors.sh"

DEVICE="$(networksetup -listallhardwareports 2>/dev/null |
  awk '/Hardware Port: Wi-Fi/ { getline; print $2; exit }')"
DEVICE="${DEVICE:-en0}"

if [ -n "$(ipconfig getifaddr "$DEVICE" 2>/dev/null)" ]; then
  ICON="󰤨"
  COLOR=$ACCENT_SECONDARY
else
  ICON="󰤭"
  COLOR=$GREY
fi

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label.drawing=off
