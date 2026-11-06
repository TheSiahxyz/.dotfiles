#!/usr/bin/env python3
"""Fetch lyrics (Genius, then Bugs) for the current (or given) song and write them
in the flat `<artist> - <title>.txt` form that ncmpcpp reads.

Why this exists: ncmpcpp 0.10.1's built-in Genius scraper stops at the first
</div> inside the lyrics container. Genius now nests a LyricsHeader div there,
so ncmpcpp only captures the header ("N Contributors<title> Lyrics") and drops
the actual lyrics. This script parses the current Genius structure correctly.
If Genius has no match (common for Korean tracks), it falls back to Bugs
(music.bugs.co.kr).

Usage:
    fetch-lyrics.py                 # uses `mpc current` for artist/title
    fetch-lyrics.py  "Artist" "Title"
    fetch-lyrics.py  --force ...    # refetch even if a good file already exists

Designed to be safe to call from ncmpcpp's execute_on_song_change: it never
raises to the caller, runs quietly, and skips songs that already have lyrics.
"""
from __future__ import annotations

import html
import json
import os
import re
import subprocess
import sys
import urllib.parse
import urllib.request

LYRICS_DIR = os.path.expanduser(
    os.environ.get("NCMPCPP_LYRICS_DIR", "~/.local/share/lyrics")
)
UA = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36"
TIMEOUT = 12

# Content that means a previous (broken) scrape, so we should refetch:
# e.g. "2 Contributorsgestalt Lyrics"
BROKEN_RE = re.compile(r"^\s*\d+\s+Contributors?.*Lyrics\s*$", re.IGNORECASE | re.DOTALL)
MIN_VALID_LEN = 60  # real lyrics are always longer than this


def get(url: str) -> str:
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=TIMEOUT) as r:
        return r.read().decode("utf-8", "replace")


def current_song():
    try:
        out = subprocess.run(
            ["mpc", "current", "-f", "%artist%\t%title%"],
            capture_output=True, text=True, timeout=5,
        ).stdout.strip()
    except Exception:
        return None
    if not out or "\t" not in out:
        return None
    artist, title = out.split("\t", 1)
    if not artist or not title:
        return None
    return artist, title


def lyrics_path(artist: str, title: str) -> str:
    # ncmpcpp stores lyrics flat as "<artist> - <title>.txt"; '/' is unsafe.
    name = f"{artist} - {title}.txt".replace("/", "_")
    return os.path.join(LYRICS_DIR, name)


def needs_fetch(path: str, force: bool) -> bool:
    if force or not os.path.exists(path):
        return True
    try:
        with open(path, encoding="utf-8") as f:
            content = f.read()
    except OSError:
        return True
    return len(content.strip()) < MIN_VALID_LEN or bool(BROKEN_RE.match(content))


def _norm(s: str) -> str:
    # Keep only alphanumerics (Unicode-aware: Korean stays), casefolded.
    return "".join(ch for ch in s.casefold() if ch.isalnum())


def _artist_matches(query_artist: str, hit_artist: str) -> bool:
    a, b = _norm(query_artist), _norm(hit_artist)
    if not a or not b:
        return False
    return a in b or b in a


def genius_url(artist: str, title: str):
    q = urllib.parse.quote(f"{artist} {title}")
    try:
        data = json.loads(get(f"https://genius.com/api/search/multi?q={q}"))
    except Exception:
        return None
    # Only accept a hit whose artist matches the song's artist. Genius search
    # happily returns unrelated songs when it lacks the track; writing those
    # would be worse than writing nothing.
    for section in data.get("response", {}).get("sections", []):
        for hit in section.get("hits", []):
            if hit.get("type") != "song":
                continue
            result = hit.get("result", {})
            hit_artist = result.get("primary_artist", {}).get("name", "")
            if _artist_matches(artist, hit_artist):
                return result.get("url")
    return None


def extract_lyrics(page: str) -> str:
    # Every verse lives in a data-lyrics-container; concatenate them all.
    parts = re.findall(
        r'data-lyrics-container="true"[^>]*>(.*?)</div>'
        r'(?=\s*<div data-lyrics-container|\s*<div[^>]*class="[^"]*RightSidebar'
        r'|\s*</div>\s*<div[^>]*StyledLink|$)',
        page, re.S,
    )
    if not parts:
        parts = re.findall(r'data-lyrics-container="true"[^>]*>(.*)', page, re.S)
    text = "".join(parts)
    # Drop the nested header block (Contributors / "<song> Lyrics") that broke ncmpcpp.
    text = re.sub(
        r'<div[^>]*data-exclude-from-selection="true".*?</div>\s*</div>\s*</div>',
        "", text, flags=re.S,
    )
    text = re.sub(r"<br\s*/?>", "\n", text)        # line breaks
    text = re.sub(r"<[^>]+>", "", text)            # strip remaining tags
    return html.unescape(text).strip()


_PAREN_RE = re.compile(r"\s*[\(\[][^\)\]]*[\)\]]")


def bugs_lyrics(artist: str, title: str):
    """Fallback for Korean tracks Genius lacks: search Bugs and scrape the
    plain lyrics block (<div class="lyricsContainer"><p><xmp>...</xmp>)."""
    base_title = _PAREN_RE.sub("", title).strip() or title
    q = urllib.parse.quote(f"{artist} {base_title}")
    try:
        page = get(f"https://music.bugs.co.kr/search/track?q={q}")
    except Exception:
        return None

    want_full, want_base = _norm(title), _norm(base_title)
    exact, loose = [], []
    for m in re.finditer(r'<tr[^>]*trackId="(\d+)"[^>]*>(.*?)</tr>', page, re.S | re.I):
        row = m.group(2)
        t = re.search(r'<p class="title"[^>]*>\s*<a[^>]*title="([^"]*)"', row)
        a = re.search(r'<p class="artist"[^>]*>\s*<a[^>]*title="([^"]*)"', row)
        if not t or not a:
            continue
        hit_title, hit_artist = html.unescape(t.group(1)), html.unescape(a.group(1))
        if not _artist_matches(artist, hit_artist):
            continue
        if _norm(hit_title) == want_full:
            exact.append(m.group(1))
        elif _norm(_PAREN_RE.sub("", hit_title)) == want_base and "inst" not in hit_title.casefold():
            loose.append(m.group(1))

    for track_id in (exact + loose)[:3]:
        try:
            track = get(f"https://music.bugs.co.kr/track/{track_id}")
        except Exception:
            continue
        m = re.search(r'<div class="lyricsContainer">.*?<xmp>(.*?)</xmp>', track, re.S)
        if m:
            text = html.unescape(m.group(1)).strip()
            if len(text) >= MIN_VALID_LEN:
                return text
    return None


def genius_lyrics(artist: str, title: str):
    url = genius_url(artist, title)
    if not url:
        return None
    try:
        lyrics = extract_lyrics(get(url))
    except Exception:
        return None
    if len(lyrics) < MIN_VALID_LEN or BROKEN_RE.match(lyrics):
        return None  # don't overwrite with garbage
    return lyrics


def write_atomic(path: str, content: str) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    tmp = path + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        f.write(content + "\n")
    os.replace(tmp, path)


def main(argv) -> int:
    force = "--force" in argv
    argv = [a for a in argv if a != "--force"]

    if len(argv) >= 2:
        artist, title = argv[0], argv[1]
    else:
        song = current_song()
        if not song:
            return 0  # nothing playing; nothing to do
        artist, title = song

    path = lyrics_path(artist, title)
    if not needs_fetch(path, force):
        return 0

    lyrics = genius_lyrics(artist, title) or bugs_lyrics(artist, title)
    if not lyrics:
        return 0

    write_atomic(path, lyrics)
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main(sys.argv[1:]))
    except Exception:
        sys.exit(0)  # never disrupt ncmpcpp's song-change command
