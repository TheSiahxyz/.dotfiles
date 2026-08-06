#!/usr/bin/env python3
"""newsboat commit-diff filter.

Reads a git commit feed (GitHub/GitLab .atom, stagit or cgit atom.xml) on
stdin and replaces each item's body with the full commit: message + diffstat +
unified diff. Output is the same feed with the body element newsboat renders
filled in.

Used from ~/.config/newsboat/urls as:
    filter:~/.config/newsboat/gitdiff.py:https://github.com/user/repo/commits/master.atom

Why this is needed: commit feeds only carry the commit *message*. GitHub's
<content> is the subject plus body in a <pre>; stagit's is the commit header
plus message. Neither includes the diff, so the interesting part of a commit is
only reachable by opening the link.

Where the diff comes from, per forge:
- GitHub/GitLab: <commit-url>.patch - mail-format patch (message + diff). The
  RFC822 header block is stripped since newsboat already shows Author/Date/Title.
- stagit (git.suckless.org): the linked commit/<sha>.html page already renders
  header + message + diffstat + diff; tags are stripped back to text.
- cgit: /commit/?id=<sha> has a /patch/?id=<sha> sibling serving a raw patch.

Two ways to read the result, because they want opposite things:
- In newsboat, the diff is shown as-is. Deeply indented code will run past a
  narrow window and newsboat, which cannot scroll sideways, has to wrap it.
  That is fine for skimming what changed.
- For reading the code properly, `--raw <commit-url>` prints the unmodified
  patch for a pager. The ',g' macro in the newsboat config pipes it through
  delta into `less -RS`, where the arrow keys scroll left and right.

Design notes:
- Per-URL disk cache. Commits are immutable, so a cached patch is never stale;
  reloads and the pager macro both cost nothing after the first fetch.
- Concurrency-limited; per-commit timeout.
- Fail-safe: if anything fails (unknown forge, network error, deleted commit),
  the item's original message is left untouched so the feed never breaks.
- Truncation: a single commit can be megabytes (vendored deps, generated files).
  Oversized diffs are cut with a visible marker rather than pushed into newsboat.
"""

import sys
import os
import re
import html
import hashlib
import urllib.request
import urllib.error
import xml.etree.ElementTree as ET
from concurrent.futures import ThreadPoolExecutor

CACHE_DIR = os.path.expanduser("~/.cache/newsboat-gitdiff")
TIMEOUT = 20            # seconds per commit
MAX_WORKERS = 6         # parallel fetches
MAX_LINES = 600         # diff lines kept per commit
MAX_BYTES = 256 * 1024  # hard cap before truncation
CONTENT_NS = "http://purl.org/rss/1.0/modules/content/"
ATOM_NS = "http://www.w3.org/2005/Atom"
UA = "newsboat-gitdiff/1.0"

os.makedirs(CACHE_DIR, exist_ok=True)
ET.register_namespace("content", CONTENT_NS)

# Forges that serve a mail-format patch at <commit-url>.patch.
PATCH_SUFFIX_RE = re.compile(
    r"^https?://(?:www\.)?(?:github\.com|gitlab\.com)/[^/]+/[^/]+/"
    r"(?:-/)?commit/[0-9a-f]{7,40}/?$",
    re.IGNORECASE,
)

# stagit writes static pages at <repo>/commit/<sha>.html.
STAGIT_RE = re.compile(r"^https?://.+/commit/[0-9a-f]{7,40}\.html$", re.IGNORECASE)

# cgit uses a query string; /patch/ is the raw-patch sibling of /commit/.
CGIT_RE = re.compile(r"^(https?://.+?)/commit/\?(?:.*&)?id=([0-9a-f]{7,40})", re.IGNORECASE)

# "From <sha> Mon Sep 17 00:00:00 2001" + RFC822 headers, up to the first blank
# line. newsboat already shows author/date/title, so this block is pure noise.
MAIL_HEADER_RE = re.compile(r"\A(?:From [0-9a-f]{40} .*\n)?(?:[A-Za-z-]+:.*\n(?:[ \t].*\n)*)+\n")

# git's "-- \n<version>" trailer at the end of a format-patch.
SIGNATURE_RE = re.compile(r"\n-- \s*\n[0-9][0-9.]*\s*\Z")

TAG_RE = re.compile(r"<[^>]+>")


def cache_path(url):
    return os.path.join(CACHE_DIR, hashlib.sha256(url.encode()).hexdigest() + ".txt")


def fetch(url):
    """Return the response body as text, or None on any failure."""
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    try:
        with urllib.request.urlopen(req, timeout=TIMEOUT) as r:
            raw = r.read(MAX_BYTES + 1)
    except (urllib.error.URLError, OSError, ValueError):
        return None
    return raw.decode("utf-8", errors="replace")


def strip_html(fragment):
    """Flatten a stagit content <div> back to the plain text it renders as."""
    fragment = re.sub(r"</t[dh]>", " ", fragment)
    fragment = re.sub(r"</tr>", "\n", fragment)
    fragment = re.sub(r"<hr\s*/?>", "\n", fragment)
    return html.unescape(TAG_RE.sub("", fragment))


def truncate(text):
    lines = text.split("\n")
    note = None
    if len(lines) > MAX_LINES:
        lines = lines[:MAX_LINES]
        note = "diff truncated at %d lines" % MAX_LINES
    text = "\n".join(lines)
    if len(text) > MAX_BYTES:
        text = text[:MAX_BYTES]
        note = "diff truncated at %d KB" % (MAX_BYTES // 1024)
    if note:
        text += "\n\n[... %s - open with ',g' or 'o' for the rest ...]" % note
    return text


def commit_text(url):
    """Return the commit patch text for url, or None if unsupported."""
    if not url:
        return None
    cp = cache_path(url)
    if os.path.exists(cp) and os.path.getsize(cp) > 0:
        with open(cp, "r", encoding="utf-8", errors="replace") as f:
            return f.read()

    text = None
    if PATCH_SUFFIX_RE.match(url):
        body = fetch(url.rstrip("/") + ".patch")
        if body:
            text = SIGNATURE_RE.sub("", MAIL_HEADER_RE.sub("", body)).strip()
    elif STAGIT_RE.match(url):
        page = fetch(url)
        if page:
            m = re.search(r'<div id="content">(.*)</div>', page, re.DOTALL)
            if m:
                text = strip_html(m.group(1)).strip()
    else:
        m = CGIT_RE.match(url)
        if m:
            body = fetch("%s/patch/?id=%s" % (m.group(1), m.group(2)))
            if body:
                text = SIGNATURE_RE.sub("", MAIL_HEADER_RE.sub("", body)).strip()

    # A commit with no diff (empty or merge commit) is a legitimate result, but
    # there is nothing to add over the message already in the feed.
    if not text or len(text) < 20:
        return None

    text = truncate(text)
    with open(cp, "w", encoding="utf-8") as f:
        f.write(text)
    return text


def find_link(item):
    # RSS <link>text</link>
    el = item.find("link")
    if el is not None and el.text and el.text.strip():
        return el.text.strip()
    # Atom <link href="..."/> (prefer rel=alternate / no rel)
    for el in item.findall("{%s}link" % ATOM_NS):
        rel = el.get("rel", "alternate")
        if rel in ("alternate", "") and el.get("href"):
            return el.get("href").strip()
    return None


def main():
    raw = sys.stdin.buffer.read()
    try:
        root = ET.fromstring(raw)
    except ET.ParseError:
        # Not parseable as XML - pass through untouched so the feed still works.
        sys.stdout.buffer.write(raw)
        return

    items = root.findall(".//item")
    is_atom = not items
    if is_atom:
        items = root.findall(".//{%s}entry" % ATOM_NS)

    links = [find_link(it) for it in items]
    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as ex:
        texts = list(ex.map(commit_text, links))

    # Which element newsboat actually renders depends on the feed type: an Atom
    # entry's <content> wins over a content:encoded sibling, so writing only the
    # RSS extension would leave Atom feeds showing the untouched message.
    tag = "{%s}content" % ATOM_NS if is_atom else "{%s}encoded" % CONTENT_NS

    for item, text in zip(items, texts):
        if not text:
            continue
        # <pre> keeps the diff's alignment; escaping first stops '<' in the code
        # being read as markup by newsboat's HTML renderer.
        payload = "<pre>" + html.escape(text) + "</pre>"
        ce = item.find(tag)
        if ce is None:
            ce = ET.SubElement(item, tag)
        else:
            ce.clear()  # drop the original message and any type="text" attribute
        if is_atom:
            ce.set("type", "html")
        ce.text = payload  # ElementTree escapes it; newsboat's renderer decodes

    sys.stdout.buffer.write(ET.tostring(root, encoding="utf-8"))


def raw_mode(url):
    """Print the patch for one commit URL, for piping into a pager.

    newsboat's article view cannot scroll sideways, so indented code in a narrow
    window is only skimmable there. This is the way to actually read it. Shares
    the filter's cache, so it is free once the feed has been reloaded."""
    text = commit_text(url)
    if not text:
        sys.stderr.write("gitdiff: no diff available for %s\n" % url)
        return 1
    sys.stdout.write(text + "\n")
    return 0


if __name__ == "__main__":
    if len(sys.argv) == 3 and sys.argv[1] == "--raw":
        sys.exit(raw_mode(sys.argv[2]))
    main()
