#!/usr/bin/env bash

# Workspace indicator, dwm style: one chip per workspace that has a window,
# plus whatever workspace is currently visible (so an empty focused workspace
# still shows). The focused one is highlighted. Runs on ws.1 only and updates
# every ws.N slot, so a change costs one script run instead of one per chip.
#
# Slots are filled left to right in AeroSpace's own workspace order; nothing
# is cached, AeroSpace is asked on every event.

source "$CONFIG_DIR/colors.sh"

# Must match the number of ws.N items created in sketchybarrc.
MAX_SLOTS=21

command -v aerospace >/dev/null 2>&1 || exit 0

# Passed by exec-on-workspace-change; ask AeroSpace on every other event.
focused="${FOCUSED_WORKSPACE:-}"
[ -n "$focused" ] || focused="$(aerospace list-workspaces --focused 2>/dev/null)"

all="$(aerospace list-workspaces --all 2>/dev/null)"
[ -n "$all" ] || exit 0
occupied="$(aerospace list-workspaces --monitor all --empty no 2>/dev/null)"
visible="$(aerospace list-workspaces --monitor all --visible 2>/dev/null)"

# is_listed <name> <newline separated list>
is_listed() {
  printf '%s\n' "$2" | grep -qxF -- "$1"
}

args=()
slot=0
while IFS= read -r ws; do
  [ -n "$ws" ] || continue
  is_listed "$ws" "$occupied" || is_listed "$ws" "$visible" || [ "$ws" = "$focused" ] || continue

  slot=$((slot + 1))
  [ "$slot" -le "$MAX_SLOTS" ] || break

  if [ "$ws" = "$focused" ]; then
    color="$WHITE"
    bg="$BACKGROUND_2"
  else
    color="$GREY"
    bg="$BACKGROUND_1"
  fi

  args+=(--set "ws.$slot"
    drawing=on
    icon="$ws"
    icon.color="$color"
    background.color="$bg"
    click_script="aerospace workspace $ws")
done <<EOF
$all
EOF

# Hide the unused slots.
while [ "$slot" -lt "$MAX_SLOTS" ]; do
  slot=$((slot + 1))
  args+=(--set "ws.$slot" drawing=off)
done

sketchybar "${args[@]}"
