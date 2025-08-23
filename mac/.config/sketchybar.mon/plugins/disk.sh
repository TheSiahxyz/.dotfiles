#!/bin/bash

source "$CONFIG_DIR/globalstyles.sh"

COUNT="$(df -H | grep -E '^(/dev/disk3s5)' | awk '{ printf ("%s\n", $5) }' | sed 's/%//')"

COLOR=$RED

case "$COUNT" in
[7-8][0-9]) # 70-89%
	COLOR=$PEACH
	;;
[5-6][0-9]) # 50-69%
	COLOR=$YELLOW
	;;
[3-4][0-9]) # 20-49%
	COLOR=$GREEN
	;;
[1-2][0-9]) # 10-19%
	COLOR=$LAVENDER
	;;
[0-9]) # 0-9%
	COLOR=$WHITE
	;;
esac

sketchybar -m --set "$NAME" \
	label="$COUNT%" \
	icon.color=$COLOR
