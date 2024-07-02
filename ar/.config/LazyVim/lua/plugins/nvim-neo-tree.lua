local Util = require("lazyvim.util")
return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  cmd = "Neotree",
  opts = {},
  keys = {
    {
      "<C-n>",
      function()
        require("neo-tree.command").execute({ toggle = false })
      end,
      desc = "Focus Explorer NeoTree (root dir)",
    },
  },
}
