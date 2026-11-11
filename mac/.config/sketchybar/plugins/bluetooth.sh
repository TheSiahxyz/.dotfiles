#!/usr/bin/env bash

# Bluetooth status: off / on / AirPods connected.
# blueutil (brew install blueutil) answers instantly and is preferred; without
# it, fall back to one system_profiler call (slow, so it runs at most once).

source "$CONFIG_DIR/colors.sh"

BT_ENABLED=false
AIRPODS_CONNECTED=false

if command -v blueutil >/dev/null 2>&1; then
  [ "$(blueutil -p 2>/dev/null)" = "1" ] && BT_ENABLED=true
  if [ "$BT_ENABLED" = true ]; then
    case "$(blueutil --connected 2>/dev/null)" in
    *AirPods* | *"Air Pods"*) AIRPODS_CONNECTED=true ;;
    esac
  fi
else
  PROFILE="$(system_profiler SPBluetoothDataType 2>/dev/null)"
  printf '%s\n' "$PROFILE" | grep -qiE 'State: On|Bluetooth Power: On' && BT_ENABLED=true
  # Devices are listed under "Connected:" until the "Not Connected:" heading.
  if [ "$BT_ENABLED" = true ] &&
    printf '%s\n' "$PROFILE" |
    awk '/^ *Not Connected:/ { on = 0 } /^ *Connected:/ { on = 1 } on' |
      grep -qiE 'air ?pods'; then
    AIRPODS_CONNECTED=true
  fi
fi

if [ "$AIRPODS_CONNECTED" = true ]; then
  ICON="󰋋"
  COLOR=$ACCENT_PINK
elif [ "$BT_ENABLED" = true ]; then
  ICON="󰂯"
  COLOR=$ACCENT_PRIMARY
else
  ICON="󰂲"
  COLOR=$GREY
fi

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label.drawing=off
