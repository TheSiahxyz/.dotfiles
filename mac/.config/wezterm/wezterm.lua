local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

-- Shell / env
config.default_prog = { "/bin/zsh", "-l" }
config.term = "xterm-256color"

-- Chrome: no tab bar. tmux owns multiplexing.
-- window_decorations is left at its default; wezterm has no equivalent of
-- alacritty's "Buttonless" (title bar kept, traffic lights hidden).
config.enable_tab_bar = false
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

-- Window
config.window_background_opacity = 0.95
-- Set to a value like 20 if you want a frosted-glass backdrop instead of plain transparency.
config.macos_window_background_blur = 0
-- These are physical pixels, not DPI-scaled ones. wezterm drops the leftover sub-cell
-- height into the bottom padding and has no equivalent of alacritty's dynamic_padding,
-- so alacritty's y = 1 leaves a 1px top against a 9px bottom and the tmux status line
-- on row 0 reads as clipped. At this window height the cell is 30px and the leftover
-- is 19px, so top = 20 balances exactly against bottom = 1 + 19; top = 16 sits a little
-- tighter at 16 vs 24. Retune if the window height changes:
-- bottom gap = bottom + ((usable_height - top - bottom) % cell_height).
config.window_padding = { left = 1, right = 1, top = 16, bottom = 1 }
config.initial_cols = 80
config.initial_rows = 24
config.adjust_window_size_when_changing_font_size = false
config.window_close_confirmation = "NeverPrompt"
config.audible_bell = "Disabled"

-- Required for the Alt bindings below; mirrors alacritty's option_as_alt = "OnlyLeft".
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = true

-- Font
config.font = wezterm.font("FiraCode Nerd Font Mono")
config.font_size = 12.0

-- Cursor: constant easing gives alacritty's hard blink instead of a fade.
config.default_cursor_style = "BlinkingBlock"
config.cursor_blink_rate = 800
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"

-- Scrollback
config.scrollback_lines = 10000
config.enable_scroll_bar = false

-- Selection
config.selection_word_boundary = " `'\"()[]{}"

-- Gruvbox dark, mirrored from alacritty/themes/gruvbox_dark.toml
config.colors = {
  foreground = "#ebdbb2",
  background = "#282828",
  cursor_bg = "#add8e6",
  cursor_fg = "#282828",
  cursor_border = "#add8e6",
  ansi = {
    "#282828", -- black
    "#cc241d", -- red
    "#939e45", -- green
    "#d79921", -- yellow
    "#458588", -- blue
    "#b16286", -- magenta
    "#689d6a", -- cyan
    "#a89984", -- white
  },
  brights = {
    "#928374",
    "#fb4934",
    "#b8bb26",
    "#fabd2f",
    "#83a598",
    "#d3869b",
    "#8ec07c",
    "#ebdbb2",
  },
}

config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Alt+c/v intentionally unbound: tmux owns M- in its root table.
config.keys = {
  -- Tabs are off; keep the default tab bindings from spawning invisible tabs.
  { key = "T",        mods = "CTRL|SHIFT", action = act.DisableDefaultAssignment },

  { key = "c",        mods = "CMD",        action = act.CopyTo("Clipboard") },
  { key = "v",        mods = "CMD",        action = act.PasteFrom("Clipboard") },
  { key = "C",        mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
  { key = "V",        mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },
  { key = "Insert",   mods = "SHIFT",      action = act.PasteFrom("PrimarySelection") },

  { key = "PageUp",   mods = "SHIFT",      action = act.ScrollByPage(-1) },
  { key = "PageDown", mods = "SHIFT",      action = act.ScrollByPage(1) },

  { key = "Space",    mods = "SHIFT",      action = act.ActivateCopyMode },
  { key = "F",        mods = "CTRL|SHIFT", action = act.Search({ CaseSensitiveString = "" }) },
  { key = "B",        mods = "CTRL|SHIFT", action = act.Search({ CaseInSensitiveString = "" }) },

  -- Alacritty's hint binding: pick a URL on screen and hand it to `open`.
  {
    key = "U",
    mods = "CTRL|SHIFT",
    action = act.QuickSelectArgs({
      label = "open url",
      patterns = { "(https?://|file://|git://|ssh://|ftp://|mailto:)\\S+" },
      action = wezterm.action_callback(function(window, pane)
        local url = window:get_selection_text_for_pane(pane)
        wezterm.open_with(url)
      end),
    }),
  },
}

-- Ctrl+click opens links, matching alacritty's hints mouse binding.
config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "CTRL",
    action = act.OpenLinkAtMouseCursor,
  },
  {
    event = { Down = { streak = 1, button = "Left" } },
    mods = "CTRL",
    action = act.Nop,
  },
}

-- ---------------------------------------------------------------------------
-- Same keys as st (~/.local/src/suckless/st/config.def.h), with CMD standing
-- in for st's Alt. kitty.conf and alacritty.toml carry the identical set.
-- (AeroSpace owns Option, exactly as dwm owns Super on Linux.)
-- Not available in wezterm: copy last command output (st Alt+o).
-- ---------------------------------------------------------------------------
local url_patterns = { "(https?://|file://|git://|ssh://|ftp://|mailto:)\\S+" }

local function change_opacity(delta)
  return wezterm.action_callback(function(window)
    local overrides = window:get_config_overrides() or {}
    if delta == 0 then
      overrides.window_background_opacity = nil
    else
      local current = overrides.window_background_opacity or config.window_background_opacity
      overrides.window_background_opacity = math.max(0.1, math.min(1.0, current + delta))
    end
    window:set_config_overrides(overrides)
  end)
end

local open_url = act.QuickSelectArgs({
  label = "open url",
  patterns = url_patterns,
  action = wezterm.action_callback(function(window, pane)
    wezterm.open_with(window:get_selection_text_for_pane(pane))
  end),
})
local copy_url = act.QuickSelectArgs({ label = "copy url", patterns = url_patterns })

local st_keys = {
  -- clipboard                            st: Alt+c / Alt+v / Alt+Shift+v
  { key = "V", mods = "CMD|SHIFT", action = act.PasteFrom("PrimarySelection") },
  -- font size                            st: Alt+Shift+k / j / +
  { key = "K", mods = "CMD|SHIFT", action = act.IncreaseFontSize },
  { key = "J", mods = "CMD|SHIFT", action = act.DecreaseFontSize },
  { key = "+", mods = "CMD|SHIFT", action = act.ResetFontSize },
  -- fullscreen, new terminal             st: Alt+f, F11, Alt+Shift+Return
  { key = "f", mods = "CMD", action = act.ToggleFullScreen },
  { key = "F11", mods = "NONE", action = act.ToggleFullScreen },
  { key = "Return", mods = "CMD|SHIFT", action = act.SpawnWindow },
  -- scrollback                           st: Alt+y/e line, Alt+u/d page
  { key = "y", mods = "CMD", action = act.ScrollByLine(-1) },
  { key = "e", mods = "CMD", action = act.ScrollByLine(1) },
  { key = "u", mods = "CMD", action = act.ScrollByPage(-1) },
  { key = "d", mods = "CMD", action = act.ScrollByPage(1) },
  { key = "PageUp", mods = "CMD", action = act.ScrollByLine(-1) },
  { key = "PageDown", mods = "CMD", action = act.ScrollByLine(1) },
  { key = "PageUp", mods = "CMD|SHIFT", action = act.ScrollByPage(-1) },
  { key = "PageDown", mods = "CMD|SHIFT", action = act.ScrollByPage(1) },
  -- opacity                              st: Alt+a / Alt+s / Alt+=
  { key = "a", mods = "CMD", action = change_opacity(-0.025) },
  { key = "s", mods = "CMD", action = change_opacity(0.025) },
  { key = "=", mods = "CMD", action = change_opacity(0) },
  -- URLs                                 st: Alt+r, Alt+Shift+c, Alt+Ctrl+o
  { key = "r", mods = "CMD", action = copy_url },
  { key = "C", mods = "CMD|SHIFT", action = copy_url },
  { key = "o", mods = "CMD|CTRL", action = open_url },
  -- keyboard selection                   st: Ctrl+Shift+Escape
  { key = "Escape", mods = "CTRL|SHIFT", action = act.ActivateCopyMode },
}

-- Every other CMD+key reaches the program as Alt+key, like st passes on every
-- Alt+key it has no shortcut for. tmux (M-h/j/k/l, M-g, M-t) and nvim
-- (<M-...>) rely on this.
for c in ("bghijklmnpqtwxz0123456789/.,;\\'-`"):gmatch(".") do
  table.insert(st_keys, { key = c, mods = "CMD", action = act.SendString("\x1b" .. c) })
end
table.insert(st_keys, { key = "Backspace", mods = "CMD", action = act.SendString("\x1b\x7f") })
for c in ("BEGHILMNPQTUWXYZ<>"):gmatch(".") do
  table.insert(st_keys, { key = c, mods = "CMD|SHIFT", action = act.SendString("\x1b" .. c) })
end

for _, key in ipairs(st_keys) do
  table.insert(config.keys, key)
end

return config
