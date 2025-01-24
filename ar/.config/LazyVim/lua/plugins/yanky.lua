return {
  {
    "gbprod/yanky.nvim",
    dependencies = not jit.os:find("Windows") and { "kkharji/sqlite.lua" } or {},
    opts = {
      highlight = { timer = 250 },
      ring = { storage = jit.os:find("Windows") and "shada" or "sqlite" },
    },
    keys = {
        -- stylua: ignore
      { "<leader>h", function() require("telescope").extensions.yank_history.yank_history({ }) end, desc = "Open Yank History" },
      { "<leader>y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank text" },
      { "<leader>p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put yanked text after cursor" },
      { "<leader>P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put yanked text before cursor" },
      { "<leader>gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "Put yanked text after selection" },
      { "<leader>gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "Put yanked text before selection" },
      { "<leader>[y", "<Plug>(YankyCycleForward)", desc = "Cycle forward through yank history" },
      { "<leader>]y", "<Plug>(YankyCycleBackward)", desc = "Cycle backward through yank history" },
      { "<leader>]p", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put indented after cursor (linewise)" },
      { "<leader>[p", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put indented before cursor (linewise)" },
      { "<leader>]P", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put indented after cursor (linewise)" },
      { "<leader>[P", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put indented before cursor (linewise)" },
      { "<leader>>p", "<Plug>(YankyPutIndentAfterShiftRight)", desc = "Put and indent right" },
      { "<leader><p", "<Plug>(YankyPutIndentAfterShiftLeft)", desc = "Put and indent left" },
      { "<leader>>P", "<Plug>(YankyPutIndentBeforeShiftRight)", desc = "Put before and indent right" },
      { "<leader><P", "<Plug>(YankyPutIndentBeforeShiftLeft)", desc = "Put before and indent left" },
      { "<leader>=p", "<Plug>(YankyPutAfterFilter)", desc = "Put after applying a filter" },
      { "<leader>=P", "<Plug>(YankyPutBeforeFilter)", desc = "Put before applying a filter" },
    },
  },
}
