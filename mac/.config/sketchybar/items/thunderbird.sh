#!/bin/bash

thunderbird=(
	"${notification_defaults[@]}"
	icon=
	icon.font.size=17
	icon.color=$OSBLUE
	icon.y_offset=0
	background.color=$WHITE
	script="$PLUGIN_DIR/thunderbird.sh"
	click_script="open -a /System/Applications/Thunderbird.app"
	icon.padding_left=7
	icon.padding_right=-1
	label.padding_right=7
	background.padding_right=5
	background.height=20
)

sketchybar --add item thunderbird right \
	--set thunderbird "${thunderbird[@]}"
