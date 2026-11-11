#!/usr/bin/env bash

# Workspace indicator: one chip per connected monitor showing the workspace
# that is visible on it. Runs on ws.1 only and updates every ws.N slot, so a
# workspace change costs one script run instead of one per chip.
#
# Monitor ids are whatever AeroSpace reports right now (they are renumbered
# when displays are plugged in or rearranged), so nothing is hard-coded and
# nothing is cached: the visible workspace is asked for directly.

source "$CONFIG_DIR/colors.sh"

MAX_SLOTS=3

command -v aerospace >/dev/null 2>&1 || exit 0

# Passed by exec-on-workspace-change; ask AeroSpace on every other event.
focused="${FOCUSED_WORKSPACE:-}"
[ -n "$focused" ] || focused="$(aerospace list-workspaces --focused 2>/dev/null)"

# "<id> | <name>" per line, ordered left to right.
monitors="$(aerospace list-monitors 2>/dev/null)"
[ -n "$monitors" ] || exit 0
count="$(printf '%s\n' "$monitors" | grep -c .)"

args=()
slot=0
while IFS= read -r line; do
  [ -n "$line" ] || continue
  slot=$((slot + 1))
  [ "$slot" -le "$MAX_SLOTS" ] || break

  id="${line%% *}"
  ws="$(aerospace list-workspaces --monitor "$id" --visible 2>/dev/null | head -n 1)"

  if [ "$count" -gt 1 ]; then
    text="M$slot:$ws"
    width=52
  else
    text="$ws"
    width=32
  fi

  if [ "$ws" = "$focused" ]; then
    color="$WHITE"
    bg="$BACKGROUND_2"
  else
    color="$GREY"
    bg="$BACKGROUND_1"
  fi

  args+=(--set "ws.$slot"
    drawing=on
    icon="$text"
    icon.width="$width"
    icon.color="$color"
    background.color="$bg"
    click_script="aerospace workspace $ws")
done <<EOF
$monitors
EOF

# Hide the slots of monitors that are not connected.
while [ "$slot" -lt "$MAX_SLOTS" ]; do
  slot=$((slot + 1))
  args+=(--set "ws.$slot" drawing=off)
done

sketchybar "${args[@]}"
