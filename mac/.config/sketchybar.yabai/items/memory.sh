#!/bin/bash

source "$CONFIG_DIR/colors.sh" # Loads all defined colors
source "$CONFIG_DIR/icons.sh"  # Loads all defined icons

memory=(
	label.font="$FONT:Heavy:12"
	label.color="$TEXT"
	icon="$MEMORY"
	icon.font="$FONT:Bold:16.0"
	icon.font.size=20
	icon.color="$GREEN"
	update_freq=15
	script="$PLUGIN_DIR/memory.sh"
	icon.padding_right=-2
	padding_right=-2
)

sketchybar --add item memory right \
	--set memory "${memory[@]}"
