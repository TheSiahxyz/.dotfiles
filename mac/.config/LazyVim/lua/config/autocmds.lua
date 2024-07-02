--------------------------------------------------------------
-- ######################################################## --
-- ##################      Custom      #################### --
-- ######################################################## --
--------------------------------------------------------------

-- Save file as sudo on files that require root permission
vim.api.nvim_create_user_command("SudoWrite", function()
  vim.cmd("write !sudo tee % >/dev/null")
  vim.cmd("edit!")
end, {})

-- Enable Goyo by default for mutt writing
local goyo_group = vim.api.nvim_create_augroup("GoyoForMutt", { clear = true })
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "/tmp/neomutt*",
  group = goyo_group,
  callback = function()
    vim.g.goyo_width = 80
    vim.cmd("Goyo")
    vim.cmd("set bg=light")
    vim.cmd("set linebreak")
    vim.cmd("set wrap")
    vim.cmd("set textwidth=0")
    vim.cmd("set wrapmargin=0")
    vim.cmd("colorscheme seoul256")
    vim.api.nvim_buf_set_keymap(
      0,
      "n",
      "<leader>gx",
      ":Goyo|x!<CR>",
      { noremap = true, silent = true, desc = "Goyo Quit" }
    )
    vim.api.nvim_buf_set_keymap(
      0,
      "n",
      "<leader>gq",
      ":Goyo|q!<CR>",
      { noremap = true, silent = true, desc = "Goyo Abort" }
    )
  end,
})

-- Vimwiki
-- Ensure files are read with the desired filetype
vim.g.vimwiki_ext2syntax = {
  [".Rmd"] = "markdown",
  [".rmd"] = "markdown",
  [".md"] = "markdown",
  [".markdown"] = "markdown",
  [".mdown"] = "markdown",
}
-- Set up Vimwiki list
vim.g.vimwiki_list = { {
  path = vim.fn.expand("~/.local/share/vimwiki"),
  syntax = "markdown",
  ext = ".md",
} }
-- Markdown for specific files and directories
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "/tmp/calcurse*", "~/.calcurse/notes/*" },
  command = "set filetype=markdown",
})

-- Groff for specific file extensions
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.ms", "*.me", "*.mom", "*.man" },
  command = "set filetype=groff",
})

-- TeX for .tex files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.tex" },
  command = "set filetype=tex",
})

-- When shortcut files are updated, renew bash and lf configs with new material:
local config_group = vim.api.nvim_create_augroup("ConfigUpdate", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "bm-files", "bm-dirs" },
  group = config_group,
  callback = function()
    -- Execute the 'shortcuts' shell command
    vim.fn.system("shortcuts")

    -- Check if the 'shortcuts' command was successful
    if vim.v.shell_error == 0 then
      -- Display a message in Neovim
      vim.api.nvim_echo({ { "shortcuts updated", "None" } }, true, {})
    else
      -- Optional: Display an error message if the 'shortcuts' command fails
      vim.api.nvim_echo({ { "failed to update shortcuts", "ErrorMsg" } }, true, {})
    end
  end,
})

-- Run xrdb whenever Xdefaults or Xresources are updated.
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "Xresources", "Xdefaults", "xresources", "xdefaults" },
  group = config_group,
  callback = function()
    vim.bo.filetype = "xdefaults"
  end,
})
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "Xresources", "Xdefaults", "xresources", "xdefaults" },
  group = config_group,
  callback = function()
    vim.cmd("!xrdb %")
  end,
})

-- Recompile dwmblocks on config edit.
local home = os.getenv("HOME") -- Gets the home directory
local dwmblocks_path = home .. "/.local/src/suckless/dwmblocks/config.h"
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = dwmblocks_path,
  group = vim.api.nvim_create_augroup("DwmblocksConfigGroup", { clear = true }),
  callback = function()
    vim.cmd(
      "!cd "
        .. home
        .. "/.local/src/suckless/dwmblocks/ && sudo make install && { killall -q dwmblocks; setsid -f dwmblocks; }"
    )
  end,
})

-- Autocommand group for DWM
vim.api.nvim_create_augroup("DwmConfigGroup", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = home .. "/.local/src/suckless/dwm/config.h",
  group = "DwmConfigGroup",
  callback = function()
    vim.cmd("!extractkeys")
  end,
})

-- Autocommand group for ST
vim.api.nvim_create_augroup("StConfigGroup", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = home .. "/.local/src/suckless/st/config.h",
  group = "StConfigGroup",
  callback = function()
    vim.cmd("!extractkeys")
  end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufEnter" }, {
  pattern = { "*.c", "*.cpp", "*.h", "*.hpp" },
  callback = function()
    local suckless_path = vim.fn.expand("~/.local/src"):gsub("/+$", "")
    local file_path = vim.fn.expand("%:p"):gsub("/+$", "")
    if file_path == suckless_path or file_path:find("^" .. suckless_path .. "/") then
      vim.b.autoformat = false
    end
  end,
})
