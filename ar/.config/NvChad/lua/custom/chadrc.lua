---@type ChadrcConfig
local M = {}

-- Path to overriding theme and highlights files
local highlights = require "custom.highlights"

M.ui = {
  -- theme
  theme = "catppuccin",
  theme_toggle = { "catppuccin", "everblush" },
  transparency = true,

  -- highlights
  hl_override = highlights.override,
  hl_add = highlights.add,

  -- Nvdash
  nvdash = {
    load_on_startup = false,

    header = {
      "                                   ",
      "  ██████╗ ██████╗ ██████╗ ███████  ",
      " ██╔════╝██╔═══██╗██╔══██╗██╔════╝ ",
      " ██║     ██║   ██║██║  ██║█████╗   ",
      " ██║     ██║   ██║██║  ██║██╔══╝   ",
      " ╚██████╗╚██████╔╝██████╔╝███████╗ ",
      "  ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝ ",
    },

    buttons = {
      { "󰺯 Find File", "Spc f f", "Telescope find_files" },
      { "󱋡 Recent Files", "Spc f o", "Telescope oldfiles" },
      { "󱩾 Find Word", "Spc f w", "Telescope live_grep" },
      { "󰃀 Bookmarks", "Spc m a", "Telescope marks" },
      { "󰏘 Themes", "Spc t h", "Telescope themes" },
      { "󰌌 Mappings", "Spc c h", "NvCheatsheet" },
    },
  },

  -- status line
  statusline = {
    theme = "minimal",
    separator_style = "block",
    overriden_modules = nil,
  },
}

M.plugins = "custom.plugins"

-- check core.mappings for table structure
M.mappings = require "custom.mappings"

return M
