#!/bin/bash

### Colours taken from dwm (config.def.h) and st (gruvbox dark palette),
### so the bar looks like the dwm bar on Linux.

# dwm bar
export DWM_BG=0xc8222222       # normbgcolor #222222 at baralpha 0xc8
export DWM_SEL_BG=0xff005577   # selbgcolor / seltagbgcolor / selinfobgcolor
export TAG_SEL_FG=0xffffffff   # seltagfgcolor
export TAG_SEL_BG=$DWM_SEL_BG
export TAG_NORM_FG=0xffcccccc  # normtagfgcolor
export TAG_NORM_BG=0x00000000  # unselected tags have no background
export STATUS_FG=0xffeeeeee    # normstatusfgcolor / selfgcolor
export DWM_BORDER=0xff444444   # normbordercolor
export DWM_SEL_BORDER=0xff770000 # selbordercolor

# st palette (gruvbox dark), used for the icon accents
export BLACK=0xff282828
export WHITE=$STATUS_FG
export RED=0xfffb4934
export GREEN=0xffb8bb26
export BLUE=0xff83a598
export YELLOW=0xfffabd2f
export ORANGE=0xfffe8019
export MAGENTA=0xffd3869b
export CYAN=0xff8ec07c
export PURPLE=0xffb16286
export GREY=0xff928374
export LIGHT_GREY=0xffa89984
export DARK_GREY=0xff222222
export TRANSPARENT=0x00000000

# Battery levels
export BATTERY_1=$GREEN
export BATTERY_2=$YELLOW
export BATTERY_3=$ORANGE
export BATTERY_4=$RED
export BATTERY_5=0xffcc241d

# General bar colours. Items sit directly on the bar, as dwmblocks text does.
export BAR_COLOR=$DWM_BG
export BAR_BORDER_COLOR=$DWM_BORDER
export BACKGROUND_1=$TRANSPARENT
export BACKGROUND_2=$DWM_BORDER
export ICON_COLOR=$STATUS_FG
export LABEL_COLOR=$STATUS_FG
export POPUP_BACKGROUND_COLOR=0xff222222
export POPUP_BORDER_COLOR=$DWM_SEL_BG
export SHADOW_COLOR=$BLACK

# Accents
export ACCENT_PRIMARY=$BLUE
export ACCENT_SECONDARY=$GREEN
export ACCENT_TERTIARY=$ORANGE
export ACCENT_QUATERNARY=$MAGENTA
export ACCENT_PINK=$MAGENTA
