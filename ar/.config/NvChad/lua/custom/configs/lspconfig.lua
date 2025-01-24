local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local lspconfig = require "lspconfig"

-- if you just want default config for the servers then put them in a table
local servers = { "clangd", "cssls", "emmet_language_server", "html", "julials", "sqlls", "tsserver" }

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

--
-- lspconfig.pyright.setup { blabla}
local on_attach_qmd = function(client, bufnr)
  local function buf_set_keymap(...)
    vim.api.nvim_buf_set_keymap(bufnr, ...)
  end
  local function buf_set_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end

  buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
  local opts = { noremap = true, silent = true }
end

local lsp_flags = {
  allow_incremental_sync = true,
  debounce_text_changes = 150,
}

local cmp_nvim_lsp = require "cmp_nvim_lsp"
local util = require "lspconfig.util"

lspconfig.marksman.setup {
  on_attach = on_attach_qmd,
  capabilities = capabilities,
  filetypes = { "markdown", "quarto" },
  root_dir = util.root_pattern(".git", ".marksman.toml", "_quarto.yml"),
}

-- lspconfig.r_language_server.setup {
--   on_attach = on_attach,
--   capabilities = capabilities,
--   flags = lsp_flags,
--   settings = {
--     r = {
--       lsp = {
--         rich_documentation = false,
--       },
--     },
--   },
-- }

lspconfig.yamlls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  flags = lsp_flags,
  settings = {
    yaml = {
      schemas = {
        -- add custom schemas here
        -- e.g.
        ["https://raw.githubusercontent.com/hits-mbm-dev/kimmdy/main/src/kimmdy/kimmdy-yaml-schema.json"] = "kimmdy.yml",
      },
    },
  },
}
