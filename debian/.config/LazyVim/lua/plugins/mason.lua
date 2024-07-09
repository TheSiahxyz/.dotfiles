local options = {
  ensure_installed = {
    "black",
    "clangd",
    "codelldb",
    "debugpy",
    "docker-compose-language-service",
    "dockerfile-language-server",
    "eslint-lsp",
    "hadolint",
    "java-debug-adapter",
    "java-test",
    "jdtls",
    "json-lsp",
    "lua-language-server",
    "markdownlint",
    "marksman",
    "prettier",
    "pyright",
    "ruff",
    "shfmt",
    "stylua",
    "yaml-language-server",
  },

  max_concurrent_installers = 10,
}

return {
  "williamboman/mason.nvim",
  cmd = { "Mason", "MasonInstall", "MasonInstallAll", "MasonUpdate" },
  opts = function()
    return options
  end,
  build = ":MasonUpdate",
  ---@param opts MasonSettings | {ensure_installed: string[]}
  config = function(_, opts)
    require("mason").setup(opts)
    local mr = require("mason-registry")
    mr:on("package:install:success", function()
      vim.defer_fn(function()
        -- trigger FileType event to possibly load this newly installed LSP server
        require("lazy.core.handler.event").trigger({
          event = "FileType",
          buf = vim.api.nvim_get_current_buf(),
        })
      end, 100)
    end)
    local function ensure_installed()
      for _, tool in ipairs(opts.ensure_installed) do
        local p = mr.get_package(tool)
        if not p:is_installed() then
          p:install()
        end
      end
    end
    if mr.refresh then
      mr.refresh(ensure_installed)
    else
      ensure_installed()
    end
    require("mason").setup(opts)
    vim.api.nvim_create_user_command("MasonInstallAll", function()
      if opts.ensure_installed and #opts.ensure_installed > 0 then
        vim.cmd("MasonInstall " .. table.concat(opts.ensure_installed, " "))
      end
    end, {})

    vim.g.mason_binaries_list = opts.ensure_installed
  end,
  keys = {
    { "<leader>cm", false },
    {
      mode = "n",
      "<leader>ms",
      "<cmd>Mason<cr>",
      desc = "Mason",
    },
    {
      mode = "n",
      "<leader>mu",
      "<cmd>MasonUpdate<cr>",
      desc = "Mason Update",
    },
    {
      mode = "n",
      "<leader>mi",
      "<cmd>MasonInstallAll<cr>",
      desc = "Mason Install All",
    },
  },
}
