#!/bin/bash

source "$CONFIG_DIR/globalstyles.sh"

network_down=(
	y_offset=-9
	label.font="$FONT:Heavy:10"
	label.color="$TEXT"
	icon="$NETWORK_DOWN"
	icon.font="$NERD_FONT:Bold:16.0"
	icon.font.size=15
	icon.color="$GREEN"
	icon.highlight_color="$BLUE"
	icon.padding_right=2
	padding_right=-2
	update_freq=1
	icon.y_offset=1
)

network_up=(
	background.padding_right=-65
	y_offset=5
	label.font="$FONT:Heavy:10"
	label.color="$TEXT"
	label.padding_right=5
	icon="$NETWORK_UP"
	icon.font="$NERD_FONT:Bold:16.0"
	icon.font.size=15
	icon.color="$GREEN"
	icon.highlight_color="$BLUE"
	icon.padding_right=2
	icon.y_offset=1
	update_freq=1
	script="$PLUGIN_DIR/network.sh"
)

sketchybar --add item network.down right \
	--set network.down "${network_down[@]}" \
	--add item network.up right \
	--set network.up "${network_up[@]}"
