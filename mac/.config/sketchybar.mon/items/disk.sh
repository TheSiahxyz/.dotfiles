#!/bin/bash

source "$CONFIG_DIR/colors.sh" # Loads all defined colors
source "$CONFIG_DIR/icons.sh"  # Loads all defined icons

disk=(
	label.font="$FONT:Heavy:12"
	label.color="$TEXT"
	icon="$DISK"
	icon.font="$FONT:Bold:18.0"
	icon.padding_right=-2
	icon.color="$MAROON"
	update_freq=60
	script="$PLUGIN_DIR/disk.sh"
)

sketchybar --add item disk right \
	--set disk "${disk[@]}"
