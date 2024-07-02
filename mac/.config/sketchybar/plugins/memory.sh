#!/bin/bash

source "$CONFIG_DIR/globalstyles.sh"

# Get total physical memory in bytes
total_memory=$(sysctl -n hw.memsize)

# Get memory page size in bytes
page_size=$(vm_stat | grep "page size of" | awk '{print $8}' | sed 's/\.$//') # Correctly strip the period at the end

# Get various memory statistics from vm_stat
vm_stat=$(vm_stat)
pages_free=$(echo "$vm_stat" | grep "Pages free:" | awk '{print $3}' | sed 's/\.$//') # Remove dot at the end
pages_active=$(echo "$vm_stat" | grep "Pages active:" | awk '{print $3}' | sed 's/\.$//')
pages_inactive=$(echo "$vm_stat" | grep "Pages inactive:" | awk '{print $3}' | sed 's/\.$//')
pages_speculative=$(echo "$vm_stat" | grep "Pages speculative:" | awk '{print $3}' | sed 's/\.$//')
pages_wired_down=$(echo "$vm_stat" | grep "Pages wired down:" | awk '{print $4}' | sed 's/\.$//')
compressed_pages=$(echo "$vm_stat" | grep "Pages occupied by compressor:" | awk '{print $5}' | sed 's/\.$//')

# Calculate total used memory pages
total_used_pages=$((pages_active + pages_wired_down + compressed_pages))

# Convert pages to bytes
total_used_memory_bytes=$((total_used_pages * page_size))

# Calculate memory used percentage as an integer
USAGE=$((total_used_memory_bytes * 100 / total_memory))
COUNT="$(memory_pressure | grep "System-wide memory free percentage:" | awk '{ val = 100 - $5; if (val < 10) printf("%1.0f\n", val); else printf("%02.0f\n", val) }')"

COLOR=$RED

case "$COUNT" in
[5-6][0-9]) # 50-69%
	COLOR=$YELLOW
	;;
[3-4][0-9]) # 20-49%
	COLOR=$GREEN
	;;
[1-2][0-9]) # 10-19%
	COLOR=$LAVENDER
	;;
[0-9]) # 0-9%
	COLOR=$WHITE
	;;
esac

sketchybar -m --set "$NAME" \
	label="$COUNT / $USAGE%" \
	icon.color=$COLOR
