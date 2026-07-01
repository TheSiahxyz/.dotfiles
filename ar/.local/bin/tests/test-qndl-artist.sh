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

# isolate mpd reindex: stub mpc + temp playlist so tests never touch real mpd/playlist
mkdir -p "$TMP/bin"
printf '#!/bin/sh\nexit 0\n' > "$TMP/bin/mpc"; chmod +x "$TMP/bin/mpc"
PATH="$TMP/bin:$PATH"; export PATH
export QNDL_MPD_PLAYLIST="$TMP/entire.m3u"

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

# regression: 프루닝이 MUSIC 루트를 삭제하지 않음
SOLO="$(mktemp -d)/Music"; mkdir -p "$SOLO"
( export XDG_MUSIC_DIR="$SOLO"; mkmp3 "$SOLO/Solo/Al/s.mp3"; "$BIN" apply "$SOLO/Solo/Al/s.mp3" "SoloCanon" )
eq "apply: prune keeps MUSIC root" "yes" "$([ -d "$SOLO" ] && echo yes || echo no)"

# --- apply-download ---
# 맵에 4MEN→4Men 이 있으므로 다운로드가 4MEN 폴더에 떨어지면 4Men으로 통일돼야 함
mkmp3 "$XDG_MUSIC_DIR/4MEN/Later/y.mp3"
"$BIN" apply-download "$XDG_MUSIC_DIR/4MEN/Later/y.mp3"
eq "apply-download: unified via map" "yes" "$([ -f "$XDG_MUSIC_DIR/4Men/Later/y.mp3" ] && echo yes || echo no)"
eq "apply-download: album_artist"    "4Men" "$(tag_of "$XDG_MUSIC_DIR/4Men/Later/y.mp3" album_artist)"

# --- merge dry-run ---
MTMP="$(mktemp -d)"; export XDG_MUSIC_DIR="$MTMP/Music"; export QNDL_ALIASES="$MTMP/aliases.tsv"
: > "$QNDL_ALIASES"
# 대소문자 그룹 (4Men 이 파일 더 많음 → 표준)
mkmp3 "$XDG_MUSIC_DIR/4MEN/A/a.mp3"
mkmp3 "$XDG_MUSIC_DIR/4Men/B/b.mp3"; mkmp3 "$XDG_MUSIC_DIR/4Men/B/c.mp3"
# 병기+순서+대소문자 그룹 (영문전용 혼합대소문자 = 표준)
mkmp3 "$XDG_MUSIC_DIR/엠씨더맥스 (M.C The Max)/A/a.mp3"
mkmp3 "$XDG_MUSIC_DIR/M.C the MAX(엠씨더맥스)/A/b.mp3"
mkmp3 "$XDG_MUSIC_DIR/M.C The Max/A/c.mp3"
# 단독(그룹 아님)
mkmp3 "$XDG_MUSIC_DIR/Lauv/A/a.mp3"

DRY="$("$BIN" merge)"
eq "merge dry: 4Men canonical" "yes" "$(printf '%s' "$DRY" | grep -q '→ 4Men (' && echo yes || echo no)"
eq "merge dry: MC=영문혼합"     "yes" "$(printf '%s' "$DRY" | grep -q '→ M.C The Max (' && echo yes || echo no)"
eq "merge dry: 단독 미포함"     "no"  "$(printf '%s' "$DRY" | grep -q 'Lauv' && echo yes || echo no)"
eq "merge dry: 비파괴"          "yes" "$([ -f "$XDG_MUSIC_DIR/4MEN/A/a.mp3" ] && echo yes || echo no)"

# --- merge --apply ---
"$BIN" merge --apply >/dev/null 2>&1
eq "apply: 4MEN 사라짐"       "no"  "$([ -d "$XDG_MUSIC_DIR/4MEN" ] && echo yes || echo no)"
eq "apply: 4Men에 병합"       "yes" "$([ -f "$XDG_MUSIC_DIR/4Men/A/a.mp3" ] && echo yes || echo no)"
eq "apply: MC 표준폴더 생성"  "yes" "$([ -d "$XDG_MUSIC_DIR/M.C The Max" ] && echo yes || echo no)"
eq "apply: MC 한글폴더 제거"  "no"  "$([ -d "$XDG_MUSIC_DIR/엠씨더맥스 (M.C The Max)" ] && echo yes || echo no)"
eq "apply: album_artist 통일" "4Men" "$(tag_of "$XDG_MUSIC_DIR/4Men/A/a.mp3" album_artist)"
eq "apply: 맵 기록"           "yes" "$(awk -F'\t' '$1=="4MEN" && $2=="4Men"{print "yes"; exit}' "$QNDL_ALIASES")"
eq "apply: idempotent 재실행" "No case/paren duplicate groups found." "$("$BIN" merge)"
eq "apply: mpd 재인덱스는 격리된 플레이리스트로" "yes" "$([ -s "$QNDL_MPD_PLAYLIST" ] && echo yes || echo no)"

exit $FAIL
