#!/bin/bash

# Trigger the package_monitor_udpate event when package_monitor update or upgrade is run from cmdline
# e.g. via function in .zshrc

package_monitor=(
	icon=􀐛
	icon.font.size=12
	icon.padding_right=-1
	label=?
	script="$PLUGIN_DIR/package_monitor.sh"
	padding_left=-2
)

sketchybar --add event package_monitor_update \
	--add item package_monitor right \
	--set package_monitor "${package_monitor[@]}" \
	--subscribe package_monitor package_monitor_update \
	mouse.clicked
