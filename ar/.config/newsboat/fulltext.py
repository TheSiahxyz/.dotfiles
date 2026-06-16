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
- Paywall honesty: some sites (e.g. Seeking Alpha, behind PerimeterX + a metered
  wall) only serve a short teaser to non-browser clients like rdrview. rdrview
  "succeeds" but the body is cut off mid-sentence with a regwall stub. We detect
  that, strip the legal boilerplate, and prepend a visible banner so the preview
  isn't mistaken for the full article. The rest is only reachable in a real
  browser, so open the link ('o') to read it.
"""

import sys
import os
import re
import html
import hashlib
import subprocess
import xml.etree.ElementTree as ET
from concurrent.futures import ThreadPoolExecutor
from urllib.parse import urlparse

CACHE_DIR = os.path.expanduser("~/.cache/newsboat-fulltext")
TIMEOUT = 20          # seconds per article
MAX_WORKERS = 6       # parallel rdrview processes
CONTENT_NS = "http://purl.org/rss/1.0/modules/content/"

os.makedirs(CACHE_DIR, exist_ok=True)
ET.register_namespace("content", CONTENT_NS)

# Hosts that gate articles behind bot-detection (PerimeterX) + a metered wall:
# a non-browser client like rdrview always gets a short teaser cut off
# mid-sentence, never the full body. Anything fetched from these is a teaser.
GATED_HOSTS = (
    "seekingalpha.com",
)

# Content markers for the same situation on other sites. Kept conservative so
# normal feeds (CNBC, etc.) are never flagged. (rdrview's readability strips
# empty regwall stubs, so host-based detection above is the reliable path.)
PAYWALL_MARKERS = (
    "signup_widget_placeholder",
    'data-test-id="paywall"',
)

# Legal boilerplate to drop from teasers so the short preview isn't buried.
DISCLAIMER_RE = re.compile(
    r"<p>\s*<strong>[^<]*Disclaimer:?\s*</strong>.*?</p>",
    re.IGNORECASE | re.DOTALL,
)

# Prepended to detected teasers so the reader sees at a glance it's not the
# full text. newsboat's HTML renderer turns &#9888; into the warning sign.
TEASER_BANNER = (
    "<p><strong>&#9888; PAYWALLED TEASER</strong> &mdash; the site gated this "
    "article; only the preview below is available. Open the link in a browser "
    "('o') for the full text.</p>\n<hr/>\n"
)


def is_teaser(url, body):
    host = (urlparse(url).hostname or "").lower()
    if any(host == g or host.endswith("." + g) for g in GATED_HOSTS):
        return True
    return any(marker in body for marker in PAYWALL_MARKERS)


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
    if is_teaser(url, body):
        # Not the full article — flag it honestly instead of passing the
        # teaser off as extracted content.
        body = TEASER_BANNER + DISCLAIMER_RE.sub("", body).strip()
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
