return {
  "vimwiki/vimwiki",
  cmd = { "VimwikiIndex", "Vimwiki2HTML", "VimwikiAll2HTML" },
  keys = {
    vim.api.nvim_set_keymap("n", "<leader>|", ":VimwikiSplitLink<CR>", { silent = true, desc = "Horizontal Split" }),
    vim.api.nvim_set_keymap("n", "<leader>-", ":VimwikiVSplitLink<CR>", { silent = true, desc = "Vertical Split" }),
    vim.api.nvim_set_keymap("n", "<leader>va", ":VimwikiAll2HTML<CR>", { silent = true, desc = "All Vimwiki to HTML" }),
    vim.api.nvim_set_keymap(
      "n",
      "<leader>vc",
      ":VimwikiColorize<CR>",
      { silent = true, desc = "Colorize line or selection" }
    ),
    vim.api.nvim_set_keymap("n", "<leader>vd", ":VimwikiDeleteFile<CR>", { silent = true, desc = "Delete Wiki Page" }),
    vim.api.nvim_set_keymap("n", "<leader>vh", ":Vimwiki2HTML<CR>", { silent = true, desc = "Vimwiki to HTML" }),
    vim.api.nvim_set_keymap(
      "n",
      "<leader>vH",
      ":Vimwiki2HTMLBrowse<CR>",
      { silent = true, desc = "Convert current wiki to HTML" }
    ),
    vim.api.nvim_set_keymap("n", "<leader>vw", ":VimwikiIndex<CR>", { silent = true, desc = "Vimwiki Index" }),
    vim.api.nvim_set_keymap(
      "n",
      "<leader>vn",
      ":VimwikiGoto<CR>",
      { silent = true, desc = "Goto or Create New Wiki Page" }
    ),
    vim.api.nvim_set_keymap("n", "<leader>vr", ":VimwikiRenameFile<CR>", { silent = true, desc = "Rename Wiki Page" }),
    vim.api.nvim_set_keymap(
      "n",
      "<leader>vu",
      ":VimwikiDiaryGenerateLinks<CR>",
      { silent = true, desc = "Update Diary" }
    ),
  },
}
