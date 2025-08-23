#!/bin/bash

kakaotalk=(
	"${notification_defaults[@]}"
	icon=󰅺
	icon.font.size=13
	background.color=$YELLOW
	script="$PLUGIN_DIR/kakaotalk.sh"
	click_script="open -a /System/Applications/KakaoTalk.app"
	icon.padding_left=7
	icon.padding_right=2
	label.padding_right=7
	background.padding_right=5
	background.height=20
)

sketchybar --add item kakaotalk right \
	--set kakaotalk "${kakaotalk[@]}"
