#!/usr/bin/env python3
"""Fetch lyrics (Genius, then Bugs) for the current (or given) song and write them
in the flat `<artist> - <title>.txt` form that ncmpcpp reads.

Why this exists: ncmpcpp 0.10.1's built-in Genius scraper stops at the first
</div> inside the lyrics container. Genius now nests a LyricsHeader div there,
so ncmpcpp only captures the header ("N Contributors<title> Lyrics") and drops
the actual lyrics. This script parses the current Genius structure correctly.
Sources, in order: LRCLIB (lrclib.net), Bugs (music.bugs.co.kr), Genius.

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


def get(url: str, ua: str = UA) -> str:
    req = urllib.request.Request(url, headers={"User-Agent": ua})
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
    # '$' stands in for 'S' in stylised names (GI$T == Gist).
    return "".join(ch for ch in s.casefold().replace("$", "s") if ch.isalnum())


def _name_variants(name: str) -> set[str]:
    """Normalised forms of an artist credit: 'Kenshi Yonezu(켄시 요네즈/米津 玄師)'
    -> {'kenshiyonezu', '켄시요네즈', '米津玄師', ...}; word order is ignored
    too ('Joe Hisaishi' == 'Hisaishi Joe')."""
    pieces = [name] + re.split(r"[\(\)\[\]/,，&]|\s+x\s+", name)
    out = set()
    for p in pieces:
        for q in (p, " ".join(sorted(p.split()))):
            n = _norm(q)
            if len(n) >= 2:
                out.add(n)
    return out


def _artist_matches(query_artist: str, hit_artist: str) -> bool:
    for a in _name_variants(query_artist):
        for b in _name_variants(hit_artist):
            if a == b:
                return True
            # substring only for non-trivial names, so 'IU' can't match 'IUZY'
            if min(len(a), len(b)) >= 4 and (a in b or b in a):
                return True
    return False


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


# Parenthesised descriptors, not titles: '(Remastered)', '(Live Demo)', '(2013)'.
# Sharing one of these must never count as a title match (Live Forever
# (Remastered) once matched Wonderwall (Remastered)).
_SKIP_PAREN_RE = re.compile(
    r"^\s*(feat|ft|with|prod|inst\w*|remaster\w*|live|ver\w*|remix|mix|edit|"
    r"acoustic|demo|mono|stereo|bonus|original|radio|single|deluxe|explicit|clean|"
    r"\d{4})\b", re.I)


_NOISE_RE = re.compile(  # '[Official Video]', '【OFFICIAL MUSIC VIDEO】', '[자막/가사]'
    r"[\[【［][^\]】］]*(official|video|m/?v|lyric|audio|자막|가사)[^\]】］]*[\]】］]", re.I)
_FEAT_PAREN_RE = re.compile(r"\s*[\(\[（]\s*(feat|ft|with|prod)\b[^\(\)\[\]（）]*[\)\]）]", re.I)
_FEAT_TAIL_RE = re.compile(r"\s+(feat|ft)\.?\s.*$", re.I)
_INNER_PAREN_RE = re.compile(r"[\(\[（]([^\(\)\[\]（）]*)[\)\]）]")
# Versions whose lyrics differ from (or are absent in) the original.
_BAD_VERSION_RE = re.compile(
    r"\b(inst\.?|instrumental|m\.?r\.?|karaoke|off\s*vocal)(?![a-z])"
    r"|\b(japanese|english|chinese|jp|eng|chn)\s*(ver|version)\b", re.I)


def _clean_title(title: str) -> str:
    t = _NOISE_RE.sub(" ", title)
    t = re.sub(r"\s(official\s+)?(music\s+)?(video|m/?v)\s*$", "", t, flags=re.I)
    prev = None
    while prev != t:  # innermost first, so nested '(추억에 살아 (Feat. 이영현))' works
        prev, t = t, _FEAT_PAREN_RE.sub("", t)
    t = _FEAT_TAIL_RE.sub("", t)
    return " ".join(t.split())


def _title_variants(title: str, artist: str = "") -> list[str]:
    """Search/compare forms of a title, e.g.
    'Go Back (고백)'            -> 'Go Back', '고백'
    '바보 Babo (Feat. X)'       -> '바보 Babo', '바보', 'Babo'
    'Official髭男dism - Pretender [Official Video]' -> 'Pretender'
    Feat. credits, video-site noise and pieces equal to the artist are
    dropped: matching on them paired unrelated songs."""
    artist_forms = _name_variants(artist) if artist else set()
    base = _clean_title(title)
    roots = [base]
    if " - " in base:  # YouTube rips: '<artist> - <song>'
        roots += [p.strip() for p in base.split(" - ")]
    variants = [title]
    for r in roots:
        outer = r
        prev = None
        while prev != outer:
            prev, outer = outer, _INNER_PAREN_RE.sub(" ", outer)
        variants += [r, " ".join(outer.split())]
        variants += [i.strip() for i in _INNER_PAREN_RE.findall(r)
                     if not _SKIP_PAREN_RE.match(i)]
    for v in list(variants[1:]):
        hangul = " ".join(re.findall(r"[가-힣0-9]+(?:\s+[가-힣0-9]+)*", v))
        latin = " ".join(re.findall(r"[A-Za-z0-9$'’.&]+(?:\s+[A-Za-z0-9$'’.&]+)*", v))
        if hangul and latin and re.search(r"[가-힣]", hangul) and re.search(r"[A-Za-z]", latin):
            variants += [hangul, latin]
    out = []
    for v in variants:
        n = _norm(v)
        # Bare credit words ('Feat.') only; real titles like 'Live Forever' stay.
        if len(n) < 2 or n in artist_forms or n in {"feat", "ft", "with", "prod"}:
            continue
        if v not in out:
            out.append(v)
    return out or [title]


def _bad_version(query_title: str, hit_title: str) -> bool:
    return bool(_BAD_VERSION_RE.search(hit_title)) and not _BAD_VERSION_RE.search(query_title)


def _dash_parts(title: str) -> set[str]:
    base = _clean_title(title)
    return {_norm(p) for p in base.split(" - ")} if " - " in base else set()


def _titles_match(q_title: str, q_artist: str, h_title: str, h_artist: str) -> bool:
    shared = ({_norm(v) for v in _title_variants(q_title, q_artist)}
              & {_norm(v) for v in _title_variants(h_title, h_artist)})
    # 'X - MIXED NUTS' vs 'X - ホワイトノイズ' share only the channel/artist
    # half 'X'; that is not a title match.
    if _norm(_clean_title(q_title)) != _norm(_clean_title(h_title)):
        shared -= _dash_parts(q_title) & _dash_parts(h_title)
    return bool(shared)


def _search_pairs(artist: str, title: str):
    """(artist, title) query pairs, bare forms first: tags like
    'M.C the MAX(엠씨더맥스)' match nothing verbatim on search endpoints."""
    a_vars, t_vars = _title_variants(artist), _title_variants(title, artist)
    for a in a_vars[1:] or a_vars:
        for t in t_vars[1:] or t_vars:
            yield a.replace("$", "S"), t


def _trace(trace, **event):
    # Optional diagnostics: callers pass a list to see every query, every
    # candidate and why it was accepted or rejected. None = normal run.
    if trace is not None:
        trace.append(event)


def _bugs_candidates(artist: str, title: str, trace=None):
    want_full = _norm(title)
    exact, loose = [], []
    for a_query, variant in _search_pairs(artist, title):
        q = urllib.parse.quote(f"{a_query} {variant}")
        try:
            page = get(f"https://music.bugs.co.kr/search/track?q={q}")
        except Exception as e:
            _trace(trace, src="bugs", query=[a_query, variant], error=repr(e))
            continue
        rows = list(re.finditer(r'<tr[^>]*trackId="(\d+)"[^>]*>(.*?)</tr>', page, re.S | re.I))
        _trace(trace, src="bugs", query=[a_query, variant], hits=len(rows))
        for m in rows:
            row, track_id = m.group(2), m.group(1)
            t = re.search(r'<p class="title"[^>]*>\s*<a[^>]*title="([^"]*)"', row)
            a = re.search(r'<p class="artist"[^>]*>\s*<a[^>]*title="([^"]*)"', row)
            if not t or not a or track_id in exact + loose:
                continue
            hit_title, hit_artist = html.unescape(t.group(1)), html.unescape(a.group(1))
            if not _artist_matches(artist, hit_artist):
                verdict = "reject:artist"
            elif _bad_version(title, hit_title):
                verdict = "reject:version"
            elif _norm(hit_title) == want_full:
                exact.append(track_id)
                verdict = "exact"
            elif _titles_match(title, artist, hit_title, hit_artist):
                loose.append(track_id)
                verdict = "loose"
            else:
                verdict = "reject:title"
            _trace(trace, src="bugs", cand=[hit_artist, hit_title], id=track_id, verdict=verdict)
        if exact:
            break
    return exact, loose


def bugs_lyrics(artist: str, title: str, trace=None):
    """Fallback for Korean tracks Genius lacks: search Bugs and scrape the
    plain lyrics block (<div class="lyricsContainer"><p><xmp>...</xmp>)."""
    exact, loose = _bugs_candidates(artist, title, trace)
    for track_id in (exact + loose)[:3]:
        try:
            track = get(f"https://music.bugs.co.kr/track/{track_id}")
        except Exception as e:
            _trace(trace, src="bugs", id=track_id, error=repr(e))
            continue
        m = re.search(r'<div class="lyricsContainer">.*?<xmp>(.*?)</xmp>', track, re.S)
        if m:
            text = html.unescape(m.group(1)).strip()
            if len(text) >= MIN_VALID_LEN:
                _trace(trace, src="bugs", chosen=track_id)
                return text
        _trace(trace, src="bugs", id=track_id, note="no lyrics on page")
    return None


def lrclib_lyrics(artist: str, title: str, trace=None):
    """LRCLIB (lrclib.net): open lyrics API, no key needed. Covers many
    Korean/indie tracks that Genius and Bugs lack."""
    for a_query, variant in _search_pairs(artist, title):
        q = urllib.parse.urlencode({"artist_name": a_query, "track_name": variant})
        try:
            hits = json.loads(get(f"https://lrclib.net/api/search?{q}",
                                  ua="fetch-lyrics (ncmpcpp helper script)"))
        except Exception as e:
            _trace(trace, src="lrclib", query=[a_query, variant], error=repr(e))
            continue
        _trace(trace, src="lrclib", query=[a_query, variant], hits=len(hits))
        for hit in hits:
            cand = [hit.get("artistName", ""), hit.get("trackName", "")]
            if hit.get("instrumental"):
                verdict = "reject:inst"
            elif not _artist_matches(artist, cand[0]):
                verdict = "reject:artist"
            elif _bad_version(title, cand[1]):
                verdict = "reject:version"
            elif not _titles_match(title, artist, cand[1], cand[0]):
                verdict = "reject:title"
            elif len((hit.get("plainLyrics") or "").strip()) < MIN_VALID_LEN:
                verdict = "reject:no_lyrics"
            else:
                _trace(trace, src="lrclib", cand=cand, id=hit.get("id"),
                       album=hit.get("albumName"), verdict="chosen")
                return hit["plainLyrics"].strip()
            _trace(trace, src="lrclib", cand=cand, id=hit.get("id"), verdict=verdict)
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
        # Bugs serves CRLF; store plain LF like every other source.
        f.write(content.replace("\r\n", "\n").replace("\r", "\n") + "\n")
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

    # Genius sits behind a Cloudflare bot challenge (HTTP 403) as of 2026-11,
    # so it rarely succeeds; it stays last as a cheap fallback.
    lyrics = (lrclib_lyrics(artist, title)
              or bugs_lyrics(artist, title)
              or genius_lyrics(artist, title))
    if not lyrics:
        return 0

    write_atomic(path, lyrics)
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main(sys.argv[1:]))
    except Exception:
        sys.exit(0)  # never disrupt ncmpcpp's song-change command
