return {
  "kristijanhusak/vim-dadbod-ui",
  dependencies = {
    { "tpope/vim-dadbod", lazy = true },
    { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
  },
  cmd = {
    "DBUI",
    "DBUIToggle",
    "DBUIAddConnection",
    "DBUIFindBuffer",
  },
  init = function()
    -- Your DBUI configuration
    vim.g.db_ui_use_nerd_fonts = 1
  end,
  keys = {
    { "<leader>ddb", "<cmd>DBUI<cr>", desc = "DB UI" },
    { "<leader>ddu", "<cmd>DBUIToggle<cr>", desc = "Toggle DB UI" },
    { "<leader>dda", "<cmd>DBUIAddConnection<cr>", desc = "Add Connection" },
    { "<leader>ddf", "<cmd>DBUIFindBuffer<cr>", desc = "Find buffer" },
    { "<leader>ddr", "<cmd>DBUIRenameBuffer<cr>", desc = "Rename buffer" },
    { "<leader>ddl", "<cmd>DBUILastQueryInfo<cr>", desc = "Last query info" },
  },
}
