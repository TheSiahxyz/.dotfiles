local M = {}

M.blankline = {
  -- show_trailing_blankline_indent = true,
  -- show_first_indent_level = true,
  context_patterns = {
    "block",
    "else_clause",
    "catch_clause",
    "class",
    "function",
    "import_statement",
    "jsx_element",
    "jsx_self_closing_element",
    "method",
    "return",
    "try_statement",
    "^for",
    "^if",
    "^object",
    "^table",
    "^while",
  },
}

M.treesitter = {
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
    "nvim-treesitter/nvim-treesitter-context",
  },

  ensure_installed = {
    "bash",
    "c",
    "css",
    "html",
    "javascript",
    "julia",
    "latex",
    "lua",
    "markdown",
    "markdown_inline",
    "python",
    "query",
    -- "r",
    "scala",
    "tsx",
    "typescript",
    "vim",
    "vimdoc",
    "yaml",
  },

  highlight = { enable = true },

  indent = {
    enable = true,
    -- disable = {
    --   "python"
    -- },
  },
}

M.mason = {
  ensure_installed = {
    -- c/cpp stuff
    "clangd",
    "clang-format",

    -- julia
    "julia-lsp",

    -- lua stuff
    "lua-language-server",
    "stylua",

    -- markdown
    "markdownlint",
    "markdown-toc",
    "marksman",

    -- -- python
    "black",
    "debugpy",
    "mypy",
    "ruff",
    "pyright",
    "vulture",

    -- R
    -- "r-languageserver",

    -- -- solidity
    -- "solidity",

    -- SQL
    "sqlls",
    "sqlfluff",
    "sql-formatter",

    -- web dev stuff
    "css-lsp",
    "html-lsp",
    "typescript-language-server",
    "deno",
    "prettier",
  },
}

-- git support in nvimtree
M.nvimtree = {
  git = {
    enable = true,
  },

  renderer = {
    highlight_git = true,
    icons = {
      show = {
        git = true,
      },
    },
  },
}

M.cmp = {
  branch = "main",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp-signature-help",
    "hrsh7th/cmp-calc",
    "hrsh7th/cmp-emoji",
    "f3fora/cmp-spell",
    "ray-x/cmp-treesitter",
    "kdheepak/cmp-latex-symbols",
    "jmbuhr/cmp-pandoc-references",
    "rafamadriz/friendly-snippets",
    "onsails/lspkind-nvim",
  },
  config = function()
    local cmp = require "cmp"
    local luasnip = require "luasnip"
    local lspkind = require "lspkind"
    lspkind.init()

    local has_words_before = function()
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
    end

    cmp.setup {
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = {
        ["<C-f>"] = cmp.mapping.scroll_docs(-4),
        ["<C-b>"] = cmp.mapping.scroll_docs(4),
        ["<C-m>"] = cmp.mapping(function(fallback)
          if luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
            fallback()
          end
        end, { "i", "s" }),
        ["<C-p>"] = cmp.mapping(function(fallback)
          if luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm {
          select = true,
        },
        ["<Tab><Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab><S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          else
            fallback()
          end
        end, { "i", "s" }),
      },
      autocomplete = false,
      formatting = {
        format = lspkind.cmp_format {
          with_text = true,
          menu = {
            otter = "[🦦]",
            nvim_lsp = "[LSP]",
            luasnip = "[snip]",
            buffer = "[buf]",
            path = "[path]",
            spell = "[spell]",
            pandoc_references = "[ref]",
            tags = "[tag]",
            treesitter = "[TS]",
            calc = "[calc]",
            latex_symbols = "[tex]",
            emoji = "[emoji]",
          },
        },
      },
      sources = {
        { name = "otter" }, -- for code chunks in quarto
        { name = "path" },
        { name = "nvim_lsp" },
        { name = "nvim_lsp_signature_help" },
        { name = "luasnip", keyword_length = 3, max_item_count = 3 },
        { name = "pandoc_references" },
        { name = "buffer", keyword_length = 5, max_item_count = 3 },
        { name = "spell" },
        { name = "treesitter", keyword_length = 5, max_item_count = 3 },
        { name = "calc" },
        { name = "latex_symbols" },
        { name = "emoji" },
      },
      view = {
        entries = "native",
      },
      window = {
        documentation = {
          border = require("misc.style").border,
        },
      },
    }

    -- for friendly snippets
    require("luasnip.loaders.from_vscode").lazy_load()
    -- for custom snippets
    require("luasnip.loaders.from_vscode").lazy_load { paths = { vim.fn.stdpath "config" .. "/snips" } }
    -- link quarto and rmarkdown to markdown snippets
    luasnip.filetype_extend("quarto", { "markdown" })
    luasnip.filetype_extend("rmarkdown", { "markdown" })
  end,
}

return M
