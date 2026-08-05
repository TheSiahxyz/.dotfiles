#!/usr/bin/env python3
"""Split kr-holidays-source.ics into two calcurse-importable files.

  final-holidays.ics        public holidays + Labour Day -> individual all-day
                            events (rendered red by the patched calcurse)
  final-commemorations.ics  7 commemorative days -> yearly recurring events
                            (rendered green by the patched calcurse)

The holiday/commemoration split follows the DESCRIPTION tag that Google
Calendar attaches to every event ("공휴일" = public holiday, "기념일" =
commemorative day). Three cases need manual correction:

  Labour Day (노동절)    Tagged inconsistently across years, but it is a paid
                         holiday under the Labor Standards Act, so it is always
                         treated as a public holiday here.
  Constitution Day       Reinstated as a public holiday from 2026, so the
  (제헌절)               commemorative recurrence is cut off at UNTIL=20250717.
  Armed Forces Day       A public holiday in 2024 only, so that single year is
  (국군의날)             removed from the recurrence via EXDATE.

The two output files are consumed by `calcurse -i`. Because calcurse keeps
plain and recurring events in separate internal lists, importing them
separately is what lets the patched build colour them differently.
"""
import collections
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(HERE, "kr-holidays-source.ics")

# Recurrence overrides for the days whose classification changes by year.
RULE_OVERRIDE = {
    "제헌절": ("RRULE:FREQ=YEARLY;UNTIL=20250717\n", ""),
    "국군의날": ("RRULE:FREQ=YEARLY\n", "EXDATE;VALUE=DATE:20241001\n"),
}
DEFAULT_RULE = ("RRULE:FREQ=YEARLY\n", "")


def field(block, key):
    """Return the value of an iCalendar property, ignoring its parameters."""
    m = re.search(rf"^{key}[^:]*:(.*)$", block, re.M)
    return m.group(1).strip() if m else ""


def main():
    raw = open(SRC, encoding="utf-8").read().replace("\r\n", "\n")
    header = raw.split("BEGIN:VEVENT")[0]
    blocks = re.findall(r"BEGIN:VEVENT\n(.*?)END:VEVENT\n", raw, re.S)

    holidays, commemorations = [], []
    for b in blocks:
        summary = field(b, "SUMMARY")
        is_holiday = field(b, "DESCRIPTION") == "공휴일" or summary == "노동절"
        (holidays if is_holiday else commemorations).append((field(b, "DTSTART"), summary, b))

    # Commemorative days fall on fixed Gregorian dates, so each one collapses
    # into a single yearly recurrence instead of one event per year.
    fixed = collections.OrderedDict()
    for dtstart, summary, _ in commemorations:
        fixed.setdefault(summary, dtstart[4:8])

    out_h = os.path.join(HERE, "final-holidays.ics")
    with open(out_h, "w", encoding="utf-8") as f:
        f.write(header)
        for _, _, b in holidays:
            f.write("BEGIN:VEVENT\n" + b + "END:VEVENT\n")
        f.write("END:VCALENDAR\n")

    out_c = os.path.join(HERE, "final-commemorations.ics")
    with open(out_c, "w", encoding="utf-8") as f:
        f.write(header)
        for i, (name, mmdd) in enumerate(fixed.items()):
            rule, extra = RULE_OVERRIDE.get(name, DEFAULT_RULE)
            f.write(
                "BEGIN:VEVENT\n"
                f"DTSTART;VALUE=DATE:2021{mmdd}\nDTEND;VALUE=DATE:2021{mmdd}\n"
                f"{rule}{extra}UID:kr-com-{i}@local\n"
                f"SUMMARY:{name}\nDESCRIPTION:기념일\nEND:VEVENT\n"
            )
        f.write("END:VCALENDAR\n")

    print(f"holidays:       {len(holidays)} events -> {os.path.basename(out_h)}")
    print(f"commemorations: {len(commemorations)} events -> {len(fixed)} recurrences "
          f"-> {os.path.basename(out_c)}")
    for name, mmdd in fixed.items():
        note = ""
        if name == "제헌절":
            note = " (until 2025)"
        elif name == "국군의날":
            note = " (2024 excluded)"
        print(f"  {mmdd[:2]}/{mmdd[2:]}  {name}{note}")


if __name__ == "__main__":
    main()
