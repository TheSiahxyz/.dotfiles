# calcurse: Korean holiday colours

Stock calcurse colours a day only by *whether it holds an item*, so weekends
are never highlighted and public holidays look identical to personal
appointments. This patch splits calcurse's four internal item lists into four
distinct colours and adds a weekend rule.

Resulting colours in the calendar grid:

| Day | Colour | Source |
| --- | --- | --- |
| Weekend (Sat/Sun) | red | `tm_wday` check added by the patch |
| Public holiday | red | plain all-day event (`eventlist`) |
| Commemorative day | green | yearly recurring event (`recur_elist`) |
| Personal appointment | cyan | timed appointment (`alist_p`) |
| Today | yellow | unchanged upstream behaviour |
| Selected day | bold red | unchanged upstream behaviour |

The patch also removes a dead branch in the weekly view: `day_check_if_item()`
never returns `2`, so upstream's `item_this_day == 2` case was unreachable and
the two views disagreed on colours.

## Files

| File | Purpose |
| --- | --- |
| `kr-holiday-colors.patch` | Source patch, 4 files, applies to calcurse 4.8.2 |
| `kr-holidays-source.ics` | Upstream data, Google "대한민국의 휴일", 2021–2031 |
| `gen-ics.py` | Splits the source into the two import files below |
| `final-holidays.ics` | 210 public holidays (incl. Labour Day) |
| `final-commemorations.ics` | 7 commemorative days as yearly recurrences |

## Rebuilding after a calcurse release

The patched binary lives in `~/.local/bin/calcurse` and shadows the packaged
one, so `pacman -Syu` never overwrites it and no action is needed on upgrade.
Rebuild only to pick up a new upstream version:

```sh
curl -LO https://calcurse.org/files/calcurse-<version>.tar.gz
tar xzf calcurse-<version>.tar.gz && cd calcurse-<version>
patch -p1 < <this-dir>/kr-holiday-colors.patch
./configure --prefix="$HOME/.local" && make
cp src/calcurse ~/.local/bin/
rehash   # zsh caches command paths; without this the old binary keeps running
```

If `patch` rejects a hunk, upstream has touched the same lines. The patch is
only four edits — `ATTR_HOLIDAY` in `calcurse.h`, the array size and colour in
`custom.c`, the four-way return in `day.c`, and the two view branches in
`ui-calendar.c` — so re-applying by hand is straightforward.

## Refreshing holiday data

The source data ends in 2031. To extend it:

```sh
curl -L -o kr-holidays-source.ics \
  'https://calendar.google.com/calendar/ical/ko.south_korea%23holiday%40group.v.calendar.google.com/public/basic.ics'
python3 gen-ics.py
calcurse -i final-holidays.ics
calcurse -i final-commemorations.ics
```

calcurse does not deduplicate on re-import, so clear the previous holiday
entries first or they will accumulate.

Check `gen-ics.py`'s `RULE_OVERRIDE` when refreshing: it hard-codes the two
days whose status changes by year (Constitution Day became a holiday again in
2026, Armed Forces Day was one only in 2024). Further legal changes need a
matching edit there.

## Removing

```sh
rm ~/.local/bin/calcurse   # reverts to the packaged build; data is untouched
```
