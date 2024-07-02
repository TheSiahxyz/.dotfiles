#!/bin/bash

volume_slider=(
	script="$PLUGIN_DIR/volume.sh"
	updates=on
	label.drawing=off
	icon.drawing=off
	slider.highlight_color=$BLUE
	slider.background.height=5
	slider.background.corner_radius=3
	slider.background.color=$BACKGROUND_2
	slider.knob=􀀁
	slider.knob.drawing=on
	padding_left=-5
	padding_right=-1
)

volume_icon=(
	click_script="$PLUGIN_DIR/volume_click.sh"
	icon=$VOLUME_100
	icon.width=0
	icon.align=left
	icon.font="$FONT:Regular:14.0"
	label.width=25
	label.align=left
	label.font="$FONT:Regular:14.0"
)

sketchybar --add slider volume right \
	--set volume "${volume_slider[@]}" \
	--subscribe volume volume_change \
	mouse.clicked \
	\
	--add item volume_icon right \
	--set volume_icon "${volume_icon[@]}"
