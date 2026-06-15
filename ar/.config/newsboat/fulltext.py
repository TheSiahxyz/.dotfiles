#!/usr/bin/env python3
"""newsboat full-text filter.

Reads an RSS/Atom feed on stdin, and for each item replaces the body with the
full article text extracted from the item's link via `rdrview`. Output is the
same feed with <content:encoded> filled in, which newsboat shows in the article
view.

Used from ~/.config/newsboat/urls as:
    filter:~/.config/newsboat/fulltext.py:https://example.com/feed.xml

Design notes:
- Per-URL disk cache so reloads don't re-fetch unchanged articles.
- Concurrency-limited; per-article timeout.
- Fail-safe: if extraction fails (rdrview missing, network error, paywall),
  the item's original summary is left untouched so the feed never breaks.
"""

import sys
import os
import re
import html
import hashlib
import subprocess
import xml.etree.ElementTree as ET
from concurrent.futures import ThreadPoolExecutor

CACHE_DIR = os.path.expanduser("~/.cache/newsboat-fulltext")
TIMEOUT = 20          # seconds per article
MAX_WORKERS = 6       # parallel rdrview processes
CONTENT_NS = "http://purl.org/rss/1.0/modules/content/"

os.makedirs(CACHE_DIR, exist_ok=True)
ET.register_namespace("content", CONTENT_NS)


def cache_path(url):
    return os.path.join(CACHE_DIR, hashlib.sha256(url.encode()).hexdigest() + ".html")


def extract(url):
    """Return clean article HTML for url, or None on any failure."""
    if not url:
        return None
    cp = cache_path(url)
    if os.path.exists(cp) and os.path.getsize(cp) > 0:
        with open(cp, "r", encoding="utf-8", errors="replace") as f:
            return f.read()
    try:
        out = subprocess.run(
            ["rdrview", "-H", url],
            capture_output=True, text=True, timeout=TIMEOUT,
        )
    except (FileNotFoundError, subprocess.TimeoutExpired):
        return None
    body = out.stdout.strip()
    if out.returncode != 0 or len(body) < 200:
        return None
    with open(cp, "w", encoding="utf-8") as f:
        f.write(body)
    return body


def find_link(item):
    # RSS <link>text</link>
    el = item.find("link")
    if el is not None and el.text and el.text.strip():
        return el.text.strip()
    # Atom <link href="..."/> (prefer rel=alternate / no rel)
    for el in item.findall("{http://www.w3.org/2005/Atom}link"):
        rel = el.get("rel", "alternate")
        if rel in ("alternate", "") and el.get("href"):
            return el.get("href").strip()
    return None


def main():
    raw = sys.stdin.buffer.read()
    try:
        root = ET.fromstring(raw)
    except ET.ParseError:
        # Not parseable as XML — pass through untouched so feed still works.
        sys.stdout.buffer.write(raw)
        return

    # RSS items live under channel/item; Atom uses <entry>.
    items = root.findall(".//item")
    if not items:
        items = root.findall(".//{http://www.w3.org/2005/Atom}entry")

    links = [find_link(it) for it in items]
    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as ex:
        bodies = list(ex.map(extract, links))

    for item, body in zip(items, bodies):
        if not body:
            continue
        tag = "{%s}encoded" % CONTENT_NS
        ce = item.find(tag)
        if ce is None:
            ce = ET.SubElement(item, tag)
        ce.text = body  # ElementTree escapes it; newsboat's HTML renderer decodes

    sys.stdout.buffer.write(ET.tostring(root, encoding="utf-8"))


if __name__ == "__main__":
    main()
