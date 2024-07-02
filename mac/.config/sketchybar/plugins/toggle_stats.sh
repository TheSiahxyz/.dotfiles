#!/bin/bash

stats=(
	cpu.top
	cpu.percent
	cpu.sys
	cpu.user
	memory
	disk
	network.up
	network.down
)

hide_stats() {
	args=()
	for item in "${stats[@]}"; do
		args+=(--set "$item" drawing=off)
	done

	sketchybar "${args[@]}" \
		--set separator_right \
		icon=󰅂 \
		icon.font.size=25 \
		padding_right=10
}

show_stats() {
	args=()
	for item in "${stats[@]}"; do
		args+=(--set "$item" drawing=on)
	done

	sketchybar "${args[@]}" \
		--set separator_right \
		icon=󰅁 \
		icon.font.size=25 \
		padding_right=10
}

toggle_stats() {
	state=$(sketchybar --query separator_right | jq -r .icon.value)

	case $state in
	"󰅂")
		show_stats
		;;
	"󰅁")
		hide_stats
		;;
	esac
}

case "$SENDER" in
"hide_stats")
	hide_stats
	;;
"show_stats")
	show_stats
	;;
"toggle_stats")
	toggle_stats
	;;
esac
