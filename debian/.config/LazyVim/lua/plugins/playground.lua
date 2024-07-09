return {
  "nvim-treesitter/playground",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  cmd = { "TSPlaygroundToggle" },
  config = function()
    require("nvim-treesitter.configs").setup({
      playground = {
        enable = true,
        disable = {},
        updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
        persist_queries = false, -- Whether the query persists across vim sessions
        keybindings = {
          toggle_query_editor = "o",
          toggle_hl_groups = "i",
          toggle_injected_languages = "t",
          toggle_anonymous_nodes = "a",
          toggle_language_display = "I",
          focus_language = "f",
          unfocus_language = "F",
          update = "R",
          goto_node = "<cr>",
          show_help = "?",
        },
      },

      query_linter = {
        enable = true,
        use_virtual_text = true,
        lint_events = { "BufWrite", "CursorHold" },
      },
    })
  end,
  keys = {
    { mode = "n", "<leader>pg", "<cmd> TSPlaygroundToggle <cr>", desc = "Toggle Playground" },
    { mode = "n", "<leader>pc", "<cmd> TSHighlightCapturesUnderCurso <cr>", desc = "Highlight Captures" },
    { mode = "n", "<leader>pn", "<cmd> TSNodeUnderCursor <cr>", desc = "Node Under Cursor" },
  },
}
