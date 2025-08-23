#!/bin/bash

# window_state() {
# 	source "$CONFIG_DIR/globalstyles.sh"
#
# 	COLOR=$LABEL_COLOR
#
# 	WINDOW=$(yabai -m query --windows --window)
# 	read -r FLOATING SPLIT PARENT FULLSCREEN STICKY STACK_INDEX <<<$(echo "$WINDOW" | jq -rc '.["is-floating", "split-type", "has-parent-zoom", "has-fullscreen-zoom", "is-sticky", "stack-index"]')
#
# 	if [[ $STACK_INDEX -gt 0 ]]; then
# 		LAST_STACK_INDEX=$(yabai -m query --windows --window stack.last | jq '.["stack-index"]')
# 		ICON=$YABAI_STACK
# 		LABEL="$(printf "%s/%s  " "$STACK_INDEX" "$LAST_STACK_INDEX")"
# 		COLOR=$YELLOW
# 	elif [[ $FLOATING == "true" ]]; then
# 		ICON=$YABAI_FLOAT
# 	elif [[ $PARENT == "true" ]]; then
# 		ICON="􁈔"
# 	elif [[ $FULLSCREEN == "true" ]]; then
# 		ICON=$YABAI_FULLSCREEN_ZOOM
# 	elif [[ $SPLIT == "vertical" ]]; then
# 		ICON=$YABAI_SPLIT_VERTICAL
# 	elif [[ $SPLIT == "horizontal" ]]; then
# 		ICON=$YABAI_SPLIT_HORIZONTAL
# 	else
# 		ICON=$YABAI_GRID
# 	fi
#
# 	args=(--bar border_color=$COLOR --animate sin 10 --set $NAME icon=$ICON icon.color=$COLOR)
#
# 	[ -z "$LABEL" ] && args+=(label.drawing=off) ||
# 		args+=(label.drawing=on label="$LABEL" label.color=$COLOR)
#
# 	[ -z "$ICON" ] && args+=(icon.width=0) ||
# 		args+=(icon="$ICON")
#
# 	sketchybar -m "${args[@]}"
# }
#
# windows_on_spaces() {
# 	/usr/bin/python3 $CONFIG_DIR/plugins/space.py # New spaces python script to consolidate spaces
# }
#
# mouse_clicked() {
#
# 	yabai_mode=$(yabai -m query --spaces --space | jq -r .type)
#
# 	case "$yabai_mode" in
# 	bsp)
# 		yabai -m config layout stack
# 		;;
# 	stack)
# 		yabai -m config layout float
# 		;;
# 	float)
# 		yabai -m config layout bsp
# 		;;
# 	esac
#
# 	window_state
# }
#
# case "$SENDER" in
# "mouse.clicked")
# 	mouse_clicked
# 	;;
# "forced")
# 	exit 0
# 	;;
# "window_focus")
# 	window_state
# 	;;
# "windows_on_spaces" | "space_change")
# 	windows_on_spaces
# 	;;
# esac

window_state() {
	source "$CONFIG_DIR/colors.sh"
	source "$CONFIG_DIR/icons.sh"

	COLOR=$ROSEWATER

	WINDOW=$(yabai -m query --windows --window)
	read -r FLOATING SPLIT PARENT FULLSCREEN STICKY STACK_INDEX <<<$(echo "$WINDOW" | jq -rc '.["is-floating", "split-type", "has-parent-zoom", "has-fullscreen-zoom", "is-sticky", "stack-index"]')

	if [[ $STACK_INDEX -gt 0 ]]; then
		LAST_STACK_INDEX=$(yabai -m query --windows --window stack.last | jq '.["stack-index"]')
		ICON=$YABAI_STACK
		LABEL="$(printf "%s/%s  " "$STACK_INDEX" "$LAST_STACK_INDEX")"
		COLOR=$YELLOW
	elif [[ $FLOATING == "true" ]]; then
		ICON=$YABAI_FLOAT
	elif [[ $PARENT == "true" ]]; then
		ICON="􁈔"
	elif [[ $FULLSCREEN == "true" ]]; then
		ICON=$YABAI_FULLSCREEN_ZOOM
	elif [[ $SPLIT == "vertical" ]]; then
		ICON=$YABAI_SPLIT_VERTICAL
	elif [[ $SPLIT == "horizontal" ]]; then
		ICON=$YABAI_SPLIT_HORIZONTAL
	else
		ICON=$YABAI_GRID
	fi

	args=(--bar --animate sin 10 --set $NAME icon=$ICON icon.color=$COLOR)
	# args=(--bar border_color=$COLOR --animate sin 10 --set $NAME icon=$ICON icon.color=$COLOR)

	[ -z "$LABEL" ] && args+=(label.drawing=off) ||
		args+=(label.drawing=on label="$LABEL" label.color=$COLOR)

	[ -z "$ICON" ] && args+=(icon.width=0) ||
		args+=(icon="$ICON")

	sketchybar -m "${args[@]}"
}

windows_on_spaces() {
	/usr/bin/python3 $CONFIG_DIR/plugins/space.py # New spaces python script to consolidate spaces
}

mouse_clicked() {
	yabai -m window --toggle float
	window_state
}

case "$SENDER" in
"mouse.clicked")
	mouse_clicked
	;;
"forced")
	exit 0
	;;
"window_focus")
	window_state
	;;
# "windows_on_spaces" | "space_change")
# 	windows_on_spaces
# 	;;
esac
