#!/usr/bin/env bash

# Click on the volume popup slider: set the output volume to that position.

[ "$SENDER" = "mouse.clicked" ] || exit 0

case "$PERCENTAGE" in
'' | *[!0-9]*) exit 0 ;;
esac

osascript -e "set volume output volume $PERCENTAGE"
