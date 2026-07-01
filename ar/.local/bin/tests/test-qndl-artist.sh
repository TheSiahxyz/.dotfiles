#!/bin/sh
# 격리 fixture 하네스. 실행: sh tests/test-qndl-artist.sh
set -u
BIN="$(CDPATH= cd "$(dirname "$0")/.." && pwd)/qndl-artist"
FAIL=0
pass() { printf 'ok   - %s\n' "$1"; }
fail() { printf 'FAIL - %s\n     expected: [%s]\n     actual:   [%s]\n' "$1" "$2" "$3"; FAIL=1; }
eq() { if [ "$2" = "$3" ]; then pass "$1"; else fail "$1" "$2" "$3"; fi }

# 1초 무음 mp3 생성 (실제 파일이어야 ffmpeg 재태그 가능)
mkmp3() { mkdir -p "$(dirname "$1")"; ffmpeg -v error -y -f lavfi -i anullsrc=r=44100:cl=mono -t 1 -q:a 9 "$1"; }
tag_of() { ffprobe -v error -show_entries format_tags="$2" -of default=noprint_wrappers=1:nokey=1 "$1"; }

# --- fixtures ---
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export XDG_MUSIC_DIR="$TMP/Music"
export QNDL_ALIASES="$TMP/aliases.tsv"
mkdir -p "$XDG_MUSIC_DIR"
printf '# header\n4MEN\t4Men\nFoo\tBar\n' > "$QNDL_ALIASES"
mkdir -p "$XDG_MUSIC_DIR/Epik High" "$XDG_MUSIC_DIR/4Men" "$XDG_MUSIC_DIR/Foo"

# --- normalize ---
eq "normalize: map hit"        "4Men"      "$("$BIN" normalize '4MEN')"
eq "normalize: case fallback"  "Epik High" "$("$BIN" normalize 'EPIK HIGH')"
eq "normalize: unknown as-is"  "NewArtist" "$("$BIN" normalize 'NewArtist')"
eq "normalize: map beats folder" "Bar" "$("$BIN" normalize 'Foo')"

# --- apply ---
mkmp3 "$XDG_MUSIC_DIR/4MEN/Album1/song.mp3"
"$BIN" apply "$XDG_MUSIC_DIR/4MEN/Album1/song.mp3" "4Men"
eq "apply: moved to canonical dir" "yes" "$([ -f "$XDG_MUSIC_DIR/4Men/Album1/song.mp3" ] && echo yes || echo no)"
eq "apply: source pruned"          "no"  "$([ -d "$XDG_MUSIC_DIR/4MEN" ] && echo yes || echo no)"
eq "apply: album_artist set"       "4Men" "$(tag_of "$XDG_MUSIC_DIR/4Men/Album1/song.mp3" album_artist)"

# 대상에 동일 파일명 존재 → 이동 건너뜀
mkmp3 "$XDG_MUSIC_DIR/DUPE/Al/x.mp3"
mkmp3 "$XDG_MUSIC_DIR/Dupe/Al/x.mp3"
"$BIN" apply "$XDG_MUSIC_DIR/DUPE/Al/x.mp3" "Dupe" 2>/dev/null
eq "apply: conflict keeps source" "yes" "$([ -f "$XDG_MUSIC_DIR/DUPE/Al/x.mp3" ] && echo yes || echo no)"

exit $FAIL
