#!/bin/bash

# Load defined icons
source "$CONFIG_DIR/icons.sh"

# Load defined colors
source "$CONFIG_DIR/colors.sh"

PADDINGS=8
FONT="Hack Nerd Font"

# Bar Appearance
bar=(
	color=$BAR_COLOR
	sticky=on
	height=28
	padding_left=$PADDINGS
	padding_right=$PADDINGS
	corner_radius=0
	blur_radius=0
	border_width=2
	border_color=$TRANSPARENT
	background_color=$BAR_COLOR
	shadow=off
	position=bottom
	padding_right=10
	padding_left=10
	# y_offset=-2
	margin=-5
	sticky=on
	topmost=off # on/off/window
)

# Setting up default values
defaults=(
	updates=when_shown
	icon.font="$FONT:Bold:10.0"
	icon.color=$ICON_COLOR
	icon.padding_left=$PADDINGS
	icon.padding_right=$PADDINGS
	label.font="$FONT:Semibold:13"
	label.color=$LABEL_COLOR
	label.padding_left=$PADDINGS
	label.padding_right=$PADDINGS
	padding_right=$PADDINGS
	padding_left=$PADDINGS
	background.color=$BAR_COLOR
	background.height=24
	background.corner_radius=3
	background.border_width=1
	popup.background.border_width=2
	popup.background.corner_radius=9
	popup.background.border_color=$POPUP_BORDER_COLOR
	popup.background.color=$POPUP_BACKGROUND_COLOR
	popup.blur_radius=20
	popup.background.shadow.drawing=on
	scroll_texts=on
)

bracket_defaults=(
	background.height=24
	background.color=$BAR_COLOR
	blur_radius=32
	background.corner_radius=$PADDINGS
)

icon_defaults=(
	label.drawing=off
)

# Item Defaults
item_defaults=(
	background.color=$TRANSPARENT
	background.padding_left=$(($PADDINGS / 2))
	background.padding_right=$(($PADDINGS / 2))
	icon.padding_left=2
	icon.padding_right=$(($PADDINGS / 2))
	icon.background.corner_radius=4
	icon.background.height=24
	icon.font="$FONT:Regular:12"
	icon.color=$ICON_COLOR
	icon.highlight_color=$HIGHLIGHT
	label.font="$FONT:Regular:12"
	label.color=$LABEL_COLOR
	label.highlight_color=$HIGHLIGHT
	label.padding_left=$(($PADDINGS / 2))
	updates=when_shown
	scroll_texts=on
)

menu_defaults=(
	popup.background.border_color=$POPUP_BORDER_COLOR
	popup.background.color=$POPUP_BACKGROUND_COLOR
	popup.background.shadow.drawing=on
	popup.blur_radius=32
	popup.background.corner_radius=$PADDINGS
	popup.background.shadow.drawing=on
	popup.background.border_width=1
)

menu_item_defaults=(
	label.font="$FONT:Regular:13"
	padding_left=$PADDINGS
	padding_right=$PADDINGS
	icon.padding_left=0
	icon.color=$HIGHLIGHT
	background.color=$TRANSPARENT
)

notification_defaults=(
	drawing=off
	update_freq=120
	updates=on
	background.color=$WHITE_25
	background.height=24
	background.corner_radius=16
	icon.font.size=10
	icon.padding_left=$PADDINGS
	icon.padding_right=0
	icon.color=$BLACK_75
	label.color=$BLACK_75
	label.padding_right=$PADDINGS
	label.font.size=11
	label.font.style=Bold
)

separator=(
	background.height=1
	width=200
	background.color=$WHITE_25
	background.y_offset=-16
)
