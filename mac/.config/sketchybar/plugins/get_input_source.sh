#!/bin/sh

PLIST="$HOME/Library/Preferences/com.apple.HIToolbox.plist"

get_source_id() {
  /usr/bin/defaults read "$PLIST" AppleCurrentKeyboardLayoutInputSourceID 2>/dev/null && return 0
  /usr/libexec/PlistBuddy -c 'Print :AppleSelectedInputSources' "$PLIST" 2>/dev/null |
    awk '
      BEGIN { RS=""; FS="\n" }
      {
        # split by entries, pick InputSourceID preceded by InputSourceKind
        n=split($0, lines, "\n")
        kind=""; id=""
        for (i=1;i<=n;i++) {
          if (lines[i] ~ /InputSourceKind/) {
            if (lines[i] ~ /Keyboard Layout/) kind="kbd"; else kind="ime"
          } else if (lines[i] ~ /InputSourceID/) {
            sub(/.*= /,"",lines[i]); sub(/;$/,"",lines[i]); id=lines[i]
          }
        }
        if (id != "") {
          if (kind=="kbd") { print id; exit } # prefer kbd
          last=id
        }
      }
      END { if (last!="") print last }'
}

SOURCE_ID="$(get_source_id | tr -d '"')"

if printf %s "$SOURCE_ID" | grep -q 'com\.apple\.keylayout\.2SetHangul'; then
  ICON="􀂩"
else
  ICON="􀂕"
fi

sketchybar --set input_source icon="$ICON"
