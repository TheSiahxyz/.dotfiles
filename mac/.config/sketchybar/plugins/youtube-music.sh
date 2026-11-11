#!/usr/bin/env bash

# Now playing from YouTube Music (th-ch/youtube-music API server plugin).
# Hides both items when the app is not running or nothing is loaded, and only
# downloads the album art when it changes.

API="http://127.0.0.1:26538/api/v1"

SONG_INFO="$(curl -s -m 2 "$API/song-info" 2>/dev/null)"
TITLE="$(printf '%s' "$SONG_INFO" | jq -r '.title // empty' 2>/dev/null)"

if [ -z "$TITLE" ]; then
  sketchybar --set music drawing=off --set music-artwork drawing=off
  exit 0
fi

ARTIST="$(printf '%s' "$SONG_INFO" | jq -r '.artist // empty')"
PAUSED="$(printf '%s' "$SONG_INFO" | jq -r '.isPaused')"
ARTWORK="$(printf '%s' "$SONG_INFO" | jq -r '.imageSrc // empty')"

if [ "$PAUSED" = true ]; then
  ICON=􀊄
else
  ICON=􁁒
fi

args=(--set music drawing=on icon="$ICON" label="$TITLE${ARTIST:+ - $ARTIST}")

if [ -n "$ARTWORK" ]; then
  CACHE_DIR="${TMPDIR:-/tmp}/sketchybar-ytm"
  mkdir -p "$CACHE_DIR"
  ART_FILE="$CACHE_DIR/$(printf '%s' "$ARTWORK" | md5 -q)"
  if [ ! -s "$ART_FILE" ]; then
    rm -f "$CACHE_DIR"/*
    curl -s -m 5 -o "$ART_FILE" "$ARTWORK"
  fi
  if [ -s "$ART_FILE" ]; then
    args+=(--set music-artwork drawing=on background.image="$ART_FILE")
  else
    args+=(--set music-artwork drawing=off)
  fi
else
  args+=(--set music-artwork drawing=off)
fi

sketchybar "${args[@]}"
