#!/bin/sh
# 격리 fixture 하네스. 실행: sh tests/test-qndl-artist.sh
set -u
BIN="$(CDPATH= cd "$(dirname "$0")/.." && pwd)/qndl-artist"
FAIL=0
pass() { printf 'ok   - %s\n' "$1"; }
fail() { printf 'FAIL - %s\n     expected: [%s]\n     actual:   [%s]\n' "$1" "$2" "$3"; FAIL=1; }
eq() { if [ "$2" = "$3" ]; then pass "$1"; else fail "$1" "$2" "$3"; fi }

# --- fixtures ---
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export XDG_MUSIC_DIR="$TMP/Music"
export QNDL_ALIASES="$TMP/aliases.tsv"
mkdir -p "$XDG_MUSIC_DIR"
printf '# header\n4MEN\t4Men\n' > "$QNDL_ALIASES"
mkdir -p "$XDG_MUSIC_DIR/Epik High" "$XDG_MUSIC_DIR/4Men"

# --- normalize ---
eq "normalize: map hit"        "4Men"      "$("$BIN" normalize '4MEN')"
eq "normalize: case fallback"  "Epik High" "$("$BIN" normalize 'EPIK HIGH')"
eq "normalize: unknown as-is"  "NewArtist" "$("$BIN" normalize 'NewArtist')"

exit $FAIL
