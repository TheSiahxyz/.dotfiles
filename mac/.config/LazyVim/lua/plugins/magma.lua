return {
  "dccsillag/magma-nvim",
  build = ":UpdateRemotePlugins",
  keys = {
    {
      "<LocalLeader>r",
      ":MagmaEvaluateOperator<CR>",
      expr = true,
      silent = true,
      desc = "Evaluate Operator",
      mode = "n",
    },
    { "<LocalLeader>rr", ":MagmaEvaluateLine<CR>", silent = true, desc = "Evaluate Line", mode = "n" },
    { "<LocalLeader>rv", ":<C-u>MagmaEvaluateVisual<CR>", silent = true, desc = "Evaluate Visual", mode = "x" },
    { "<LocalLeader>rc", ":MagmaReevaluateCell<CR>", silent = true, desc = "Reevaluate Cell", mode = "n" },
    { "<LocalLeader>rd", ":MagmaDelete<CR>", silent = true, desc = "Delete", mode = "n" },
    { "<LocalLeader>ro", ":MagmaShowOutput<CR>", silent = true, desc = "Show Output", mode = "n" },
    { "<LocalLeader>ri", ":MagmaInit python3<CR>", silent = true, desc = "Init", mode = "n" },
    -- let g:magma_automatically_open_output = v:false
    -- let g:magma_image_provider = "ueberzug"
    -- let g:magma_image_provider = "kitty"
  },
}
