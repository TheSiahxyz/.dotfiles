return {
  "stevearc/oil.nvim",
  opts = {},
  -- Optional dependencies
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = { "Oil" },
  config = function()
    require("oil").setup()
  end,
  keys = {
    vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" }),
  },
}
