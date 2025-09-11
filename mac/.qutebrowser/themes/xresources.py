import subprocess


def read_xresources(prefix):
    props = {}
    x = subprocess.run(["xrdb", "-query"], capture_output=True, check=True, text=True)
    lines = x.stdout.split("\n")
    for line in filter(lambda l: l.startswith(prefix), lines):
        prop, _, value = line.partition(":\t")
        props[prop] = value
    return props


xresources = read_xresources("*")

base00 = xresources["*.color0"]
base01 = xresources["*.color1"]
base02 = xresources["*.color2"]
base03 = xresources["*.color3"]
base04 = xresources["*.color4"]
base05 = xresources["*.color5"]
base06 = xresources["*.color6"]
base07 = xresources["*.color7"]
base08 = xresources["*.color8"]
base09 = xresources["*.color9"]
base0A = xresources["*.color10"]
base0B = xresources["*.color11"]
base0C = xresources["*.color12"]
base0D = xresources["*.color13"]
base0E = xresources["*.color14"]
base0F = xresources["*.color15"]
foreground = xresources["*.foreground"]
background = xresources["*.background"]

# Text color of the completion widget. May be a single color to use for
# all columns or a list of three colors, one for each column.
c.colors.completion.fg = foreground

# Background color of the completion widget for odd rows.
c.colors.completion.odd.bg = background

# Background color of the completion widget for even rows.
c.colors.completion.even.bg = background

# Foreground color of completion widget category headers.
c.colors.completion.category.fg = foreground

# Background color of the completion widget category headers.
c.colors.completion.category.bg = background

# Top border color of the completion widget category headers.
c.colors.completion.category.border.top = base00

# Bottom border color of the completion widget category headers.
c.colors.completion.category.border.bottom = base00

# Foreground color of the selected completion item.
c.colors.completion.item.selected.fg = foreground

# Background color of the selected completion item.
c.colors.completion.item.selected.bg = background

# Top border color of the completion widget category headers.
c.colors.completion.item.selected.border.top = base0A

# Bottom border color of the selected completion item.
c.colors.completion.item.selected.border.bottom = base0A

# Foreground color of the matched text in the selected completion item.
c.colors.completion.item.selected.match.fg = base06

# Foreground color of the matched text in the completion.
c.colors.completion.match.fg = base06

# Color of the scrollbar handle in the completion view.
c.colors.completion.scrollbar.fg = base05

# Color of the scrollbar in the completion view.
c.colors.completion.scrollbar.bg = base00

# Background color for the download bar.
c.colors.downloads.bar.bg = background

# Color gradient start for download text.
c.colors.downloads.start.fg = foreground

# Color gradient start for download backgrounds.
c.colors.downloads.start.bg = base0A

# Color gradient end for download text.
c.colors.downloads.stop.fg = foreground

# Color gradient stop for download backgrounds.
c.colors.downloads.stop.bg = base08

# Foreground color for downloads with errors.
c.colors.downloads.error.fg = foreground

# Background color for downloads with errors.
c.colors.downloads.error.bg = background

# Font color for hints.
c.colors.hints.fg = foreground

# Background color for hints. Note that you can use a `rgba(...)` value
# for transparency.
c.colors.hints.bg = background

# Font color for the matched part of hints.
c.colors.hints.match.fg = base05

# Text color for the keyhint widget.
c.colors.keyhint.fg = base05

# Highlight color for keys to complete the current keychain.
c.colors.keyhint.suffix.fg = base05

# Background color of the keyhint widget.
c.colors.keyhint.bg = base00

# Foreground color of an error message.
c.colors.messages.error.fg = foreground

# Background color of an error message.
c.colors.messages.error.bg = background

# Border color of an error message.
c.colors.messages.error.border = base08

# Foreground color of a warning message.
c.colors.messages.warning.fg = base00

# Background color of a warning message.
c.colors.messages.warning.bg = base0E

# Border color of a warning message.
c.colors.messages.warning.border = base0E

# Foreground color of an info message.
c.colors.messages.info.fg = foreground

# Background color of an info message.
c.colors.messages.info.bg = background

# Border color of an info message.
c.colors.messages.info.border = base00

# Foreground color for prompts.
c.colors.prompts.fg = base05

# Border used around UI elements in prompts.
c.colors.prompts.border = base00

# Background color for prompts.
c.colors.prompts.bg = base00

# Background color for the selected item in filename prompts.
c.colors.prompts.selected.bg = base0A

# Foreground color of the statusbar.
c.colors.statusbar.normal.fg = base0E

# Background color of the statusbar.
c.colors.statusbar.normal.bg = "#00000000"

# Foreground color of the statusbar in insert mode.
c.colors.statusbar.insert.fg = base00

# Background color of the statusbar in insert mode.
c.colors.statusbar.insert.bg = base0D

# Foreground color of the statusbar in passthrough mode.
c.colors.statusbar.passthrough.fg = base0E

# Background color of the statusbar in passthrough mode.
c.colors.statusbar.passthrough.bg = base0C

# Foreground color of the statusbar in private browsing mode.
c.colors.statusbar.private.fg = base00

# Background color of the statusbar in private browsing mode.
c.colors.statusbar.private.bg = base03

# Foreground color of the statusbar in command mode.
c.colors.statusbar.command.fg = foreground

# Background color of the statusbar in command mode.
c.colors.statusbar.command.bg = "#00000000"

# Foreground color of the statusbar in private browsing + command mode.
c.colors.statusbar.command.private.fg = base05

# Background color of the statusbar in private browsing + command mode.
c.colors.statusbar.command.private.bg = base00

# Foreground color of the statusbar in caret mode.
c.colors.statusbar.caret.fg = base00

# Background color of the statusbar in caret mode.
c.colors.statusbar.caret.bg = base0E

# Foreground color of the statusbar in caret mode with a selection.
c.colors.statusbar.caret.selection.fg = base00

# Background color of the statusbar in caret mode with a selection.
c.colors.statusbar.caret.selection.bg = base0D

# Background color of the progress bar.
c.colors.statusbar.progress.bg = base0D

# Default foreground color of the URL in the statusbar.
c.colors.statusbar.url.fg = base0D

# Foreground color of the URL in the statusbar on error.
c.colors.statusbar.url.error.fg = base08

# Foreground color of the URL in the statusbar for hovered links.
c.colors.statusbar.url.hover.fg = base0C

# Foreground color of the URL in the statusbar on successful load
# (http).
c.colors.statusbar.url.success.http.fg = base0C

# Foreground color of the URL in the statusbar on successful load
# (https).
c.colors.statusbar.url.success.https.fg = base0D

# Foreground color of the URL in the statusbar when there's a warning.
c.colors.statusbar.url.warn.fg = base0E

# Background color of the tab bar.
c.colors.tabs.bar.bg = "#00000000"

# Color gradient start for the tab indicator.
c.colors.tabs.indicator.start = base0A

# Color gradient end for the tab indicator.
c.colors.tabs.indicator.stop = base08

# Color for the tab indicator on errors.
c.colors.tabs.indicator.error = base08

# Foreground color of unselected odd tabs.
c.colors.tabs.odd.fg = foreground

# Background color of unselected odd tabs.
c.colors.tabs.odd.bg = "#00000000"

# Foreground color of unselected even tabs.
c.colors.tabs.even.fg = foreground

# Background color of unselected even tabs.
c.colors.tabs.even.bg = "#00000000"

# Foreground color of selected odd tabs.
c.colors.tabs.selected.odd.fg = background

# Background color of selected odd tabs.
c.colors.tabs.selected.odd.bg = foreground

# Foreground color of selected even tabs.
c.colors.tabs.selected.even.fg = background

# Background color of selected even tabs.
c.colors.tabs.selected.even.bg = foreground

# Background color of tooltips. If set to null, the Qt default is used.
c.colors.tooltip.bg = background

# Background color for webpages if unset (or empty to use the theme's
# color).
# c.colors.webpage.bg = base00
c.colors.webpage.bg = background

# CSS border value for hints.
c.hints.border = foreground
