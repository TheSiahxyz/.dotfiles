# Important Note

These cronjobs post notifications through `osascript` (Notification Center), which
has two requirements on macOS:

1. **Notification permission.** The program that launches `cron` must be allowed to
   post notifications. Open System Settings → Notifications and enable the entry for
   `cron` (or `Script Editor`) once it first appears there.
2. **Full Disk Access.** macOS sandboxes `cron`, so jobs touching `~/Library`,
   `~/Documents`, `~/Desktop` or similar fail silently. Add `/usr/sbin/cron` under
   System Settings → Privacy & Security → Full Disk Access.

`cron` also runs with a minimal environment (`PATH=/usr/bin:/bin:/usr/sbin:/sbin`),
so Homebrew binaries are not on `PATH`. The scripts here prepend Homebrew
themselves, but anything else you add should set `PATH` explicitly at the top of
the crontab:

```crontab
PATH=/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

*/15 * * * * $HOME/.local/bin/cron/newsup
0 */3 * * *  $HOME/.local/bin/cron/checkup
@daily       $HOME/.local/bin/cron/mediaup
```

There is no `DISPLAY`/`DBUS_SESSION_BUS_ADDRESS` to export — those are X11 and
Linux D-Bus concepts and do not exist here.

> Note: Apple has deprecated `cron` in favour of `launchd`. If a job needs to
> survive sleep, run at login, or hold its own permissions, prefer a
> `launchd` agent in `~/Library/LaunchAgents/` over a crontab entry.
