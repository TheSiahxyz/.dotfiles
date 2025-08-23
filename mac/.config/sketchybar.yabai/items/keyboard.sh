#!/bin/bash

keyboard=(
	padding_right=4
	icon.drawing=off
	script="$PLUGIN_DIR/keyboard.sh"
	icon.color=$GREY
	icon.font="$FONT:Regular:14.0"
)

sketchybar --add item keyboard right \
	--set keyboard "${keyboard[@]}" \
	--add event keyboard_change "AppleSelectedInputSourcesChangedNotification" \
	--subscribe keyboard keyboard_change
