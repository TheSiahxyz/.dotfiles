return {
  "ThePrimeagen/refactoring.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("refactoring").setup()
  end,
  keys = {
    vim.keymap.set("x", "<leader>re", function()
      require("refactoring").refactor("Extract Function")
    end, { desc = "Extract Function" }),
    vim.keymap.set({ "x", "n" }, "<leader>rf", function()
      require("refactoring").refactor("Extract Function To File")
    end, { desc = "Extract Function To File" }),
    -- Extract function supports only visual mode
    vim.keymap.set("x", "<leader>rv", function()
      require("refactoring").refactor("Extract Variable")
    end, { desc = "Extract Variable" }),
    -- Extract variable supports only visual mode
    vim.keymap.set("n", "<leader>rI", function()
      require("refactoring").refactor("Inline Function")
    end, { desc = "Inline Function" }),
    -- Inline func supports only normal
    vim.keymap.set({ "n", "x" }, "<leader>ri", function()
      require("refactoring").refactor("Inline Variable")
    end, { desc = "Inline Variable" }),
    -- Inline var supports both normal and visual mode

    vim.keymap.set("n", "<leader>rb", function()
      require("refactoring").refactor("Extract Block")
    end, { desc = "Extract Block" }),
  },
}
