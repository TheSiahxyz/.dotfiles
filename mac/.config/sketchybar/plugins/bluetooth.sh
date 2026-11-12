#!/usr/bin/env bash

# Bluetooth status: off / on (nothing connected) / device connected / AirPods connected.
# blueutil (brew install blueutil) is tried first, but it aborts when the
# process that started sketchybar has no Bluetooth privacy permission (the
# usual case when AeroSpace launches the bar). Whenever it is missing or
# fails, fall back to one system_profiler call, which needs no permission.

source "$CONFIG_DIR/colors.sh"

BT_ENABLED=false
DEVICE_CONNECTED=false
AIRPODS_CONNECTED=false

if command -v blueutil >/dev/null 2>&1 && POWER="$(blueutil -p 2>/dev/null)"; then
  [ "$POWER" = "1" ] && BT_ENABLED=true
  if [ "$BT_ENABLED" = true ]; then
    CONNECTED="$(blueutil --connected 2>/dev/null)"
    [ -n "$CONNECTED" ] && DEVICE_CONNECTED=true
    case "$CONNECTED" in
    *AirPods* | *"Air Pods"*) AIRPODS_CONNECTED=true ;;
    esac
  fi
else
  PROFILE="$(system_profiler SPBluetoothDataType 2>/dev/null)"
  printf '%s\n' "$PROFILE" | grep -qiE 'State: On|Bluetooth Power: On' && BT_ENABLED=true
  # Devices are listed under "Connected:" until the "Not Connected:" heading.
  if [ "$BT_ENABLED" = true ]; then
    # Drop the "Connected:" heading itself; what is left is the device list.
    CONNECTED="$(printf '%s\n' "$PROFILE" |
      awk '/^ *Not Connected:/ { on = 0 } on; /^ *Connected:/ { on = 1 }')"
    [ -n "$CONNECTED" ] && DEVICE_CONNECTED=true
    printf '%s\n' "$CONNECTED" | grep -qiE 'air ?pods' && AIRPODS_CONNECTED=true
  fi
fi

if [ "$AIRPODS_CONNECTED" = true ]; then
  ICON="󰋋"
  COLOR=$ACCENT_PINK
elif [ "$DEVICE_CONNECTED" = true ]; then
  ICON="󰂱"
  COLOR=$ACCENT_PRIMARY
elif [ "$BT_ENABLED" = true ]; then
  ICON="󰂯"
  COLOR=$LIGHT_GREY
else
  ICON="󰂲"
  COLOR=$GREY
fi

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label.drawing=off
