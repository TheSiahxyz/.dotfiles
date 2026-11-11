#!/usr/bin/env bash

# Clock label plus the date popup rows (created once in sketchybarrc).

source "$CONFIG_DIR/colors.sh"

if [ "$SENDER" = "mouse.exited.global" ]; then
  sketchybar --set clock popup.drawing=off
  exit 0
fi

sketchybar --set clock label="$(date '+%I:%M %p  %a %d %b')" \
  --set clock.full_date label="$(date '+%A, %B %d, %Y')" \
  --set clock.week label="$(date '+Week %V')" \
  --set clock.day_of_year label="$(date '+Day %j of %Y')"
