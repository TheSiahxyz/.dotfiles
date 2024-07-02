local opts = { noremap = true, silent = true }
return {
  "danymat/neogen",
  dependencies = "nvim-treesitter/nvim-treesitter",
  config = true,
  version = "*",
  keys = {
    vim.api.nvim_set_keymap(
      "n",
      "<Leader>nf",
      ":lua require('neogen').generate({type = 'file'})<CR>",
      { desc = "generate file", noremap = true, silent = true }
    ),
    vim.api.nvim_set_keymap(
      "n",
      "<Leader>nn",
      ":lua require('neogen').generate({type = 'func'})<CR>",
      { desc = "generate function", noremap = true, silent = true }
    ),
    vim.api.nvim_set_keymap(
      "n",
      "<Leader>nc",
      ":lua require('neogen').generate({ type = 'class' })<CR>",
      { desc = "generate class", noremap = true, silent = true }
    ),
    vim.api.nvim_set_keymap(
      "n",
      "<Leader>nt",
      ":lua require('neogen').generate({ type = 'type' })<CR>",
      { desc = "generate type", noremap = true, silent = true }
    ),
  },
}
