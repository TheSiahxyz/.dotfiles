#!/usr/bin/env python3
"""Fetch lyrics from Genius for the current (or given) song and write them
in the flat `<artist> - <title>.txt` form that ncmpcpp reads.

Why this exists: ncmpcpp 0.10.1's built-in Genius scraper stops at the first
</div> inside the lyrics container. Genius now nests a LyricsHeader div there,
so ncmpcpp only captures the header ("N Contributors<title> Lyrics") and drops
the actual lyrics. This script parses the current Genius structure correctly.

Usage:
    genius-lyrics.py                # uses `mpc current` for artist/title
    genius-lyrics.py "Artist" "Title"
    genius-lyrics.py --force ...    # refetch even if a good file already exists

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

    url = genius_url(artist, title)
    if not url:
        return 0
    try:
        lyrics = extract_lyrics(get(url))
    except Exception:
        return 0
    if len(lyrics) < MIN_VALID_LEN or BROKEN_RE.match(lyrics):
        return 0  # don't overwrite with garbage

    write_atomic(path, lyrics)
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main(sys.argv[1:]))
    except Exception:
        sys.exit(0)  # never disrupt ncmpcpp's song-change command
