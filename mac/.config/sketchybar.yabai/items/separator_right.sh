#!/usr/bin/env bash

separator_right=(
	icon=󰅁
	icon.font="$FONT:Regular:25.0"
	label.drawing=off
	click_script='sketchybar --trigger toggle_stats'
	icon.color="$TEXT"
	padding_right=10
)

sketchybar --add item separator_right right \
	--set separator_right "${separator_right[@]}"
