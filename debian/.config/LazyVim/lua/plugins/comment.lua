return {
  "numToStr/Comment.nvim",
  lazy = "false",
  keys = {
    {
      mode = "n",
      "<leader>/",
      function()
        require("Comment.api").toggle.linewise.current()
      end,
      desc = "Toggle comment",
    },
    {
      mode = "v",
      "<leader>/",
      "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
      desc = "Toggle comment",
    },
  },
  config = function(_, opts)
    require("Comment").setup(opts)
  end,
}
