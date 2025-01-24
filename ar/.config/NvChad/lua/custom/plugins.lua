local overrides = require "custom.configs.overrides"

---@type NvPluginSpec[]
local plugins = {

  -- Override plugin definition options

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- format & linting
      {
        "jose-elias-alvarez/null-ls.nvim",
        config = function()
          require "custom.configs.null-ls"
        end,
      },
    },
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end, -- Override to setup mason-lspconfig
  },

  -- override plugin configs
  {
    "lukas-reineke/indent-blankline.nvim",
    opts = overrides.blankline,
  },
  {
    "williamboman/mason.nvim",
    opts = overrides.mason,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = overrides.treesitter,
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = overrides.nvimtree,
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-calc",
      "hrsh7th/cmp-cmdline",
      "rafamadriz/friendly-snippets",
      "honza/vim-snippets",
      "jmbuhr/otter.nvim",
    },
    opts = function(_, opts)
      -- -@param opts cmp.ConfigSchema
      local cmp = require "cmp"
      opts.sources = cmp.config.sources(vim.list_extend(opts.sources, { { name = "otter" } }))
    end,
  },

  ----------------------
  -- Install a plugin
  ----------------------

  -- better-escape
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require("better_escape").setup()
    end,
  },

  -- better quick fix
  {
    "kevinhwang91/nvim-bqf",
    config = function()
      require("bqf").setup()
    end,
  },

  -- browse
  {
    "lalitmee/browse.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("browse").setup {
        -- search provider you want to use
        provider = "google", -- duckduckgo, bing

        -- either pass it here or just pass the table to the functions
        -- see below for more
        bookmarks = {
          ["github"] = {
            ["name"] = "search github from neovim",
            ["code_search"] = "https://github.com/search?q=%s&type=code",
            ["repo_search"] = "https://github.com/search?q=%s&type=repositories",
            ["issues_search"] = "https://github.com/search?q=%s&type=issues",
            ["pulls_search"] = "https://github.com/search?q=%s&type=pullrequests",
          },
        },
      }
    end,
  },

  -- bullets
  {
    "dkarter/bullets.vim",
  },

  -- chafa
  {
    "princejoogie/chafa.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "m00qek/baleia.nvim",
    },
    cmd = "ViewImage",
    config = function()
      require("chafa").setup {
        render = {
          min_padding = 5,
          show_label = true,
        },
        events = {
          update_on_nvim_resize = true,
        },
      }
    end,
  },

  -- chatGPT
  {
    "dreamsofcode-io/ChatGPT.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("chatgpt").setup {
        async_api_key_cmd = "pass show api/chatGPT/nvim",
      }
    end,
  },

  -- cinnamon
  {
    "declancm/cinnamon.nvim",
    config = function()
      require("cinnamon").setup()
    end,
  },

  -- diff
  {
    "sindrets/diffview.nvim",
    dependencies = "nvim-lua/plenary.nvim",
  },

  -- doge
  {
    "kkoomen/vim-doge",
  },

  -- fzf
  {
    "junegunn/fzf",
  },

  -- hardhat-vscode
  {
    "NomicFoundation/hardhat-vscode",
  },

  -- harpoon
  {
    "ThePrimeagen/harpoon",
    cmd = "Harpoon",
  },

  -- hologram
  {
    "edluffy/hologram.nvim",
    config = function()
      require("hologram").setup {
        auto_display = true,
      }
    end,
  },

  -- impatient
  {
    "lewis6991/impatient.nvim",
    config = function()
      require "impatient"
    end,
  },

  -- iron
  {
    "hkupty/iron.nvim",
    event = "VeryLazy",
    opts = function()
      return {
        config = {
          scratch_repl = true,
          repl_definition = {
            sh = { command = { "zsh" } },
            python = require("iron.fts.python").ipython,
          },
          repl_open_cmd = require("iron.view").right "40%",
        },
        highlight = {
          italic = true,
        },
        ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
      }
    end,
    config = function(_, opts)
      local iron = require "iron.core"
      iron.setup(opts)
    end,
  },

  -- glow
  {
    "ellisonleao/glow.nvim",
    config = true,
    cmd = "Glow",
  },

  -- -- jukit
  -- {
  --   "luk400/vim-jukit",
  --   config = function()
  --     require("jukit").setup()
  --     -- vim.cmd "source /Users/si/.local/nvim/lazy/vim-jukit/autoload/jukit.vim"
  --   end,
  -- },

  -- jupytext
  {
    "GCBallesteros/jupytext.nvim",
    config = true,
    lazy = false,
    -- event = "VeryLazy",
  },

  -- jupytext
  {
    "goerz/jupytext.vim",
    build = "pip3 install jupytext",
    -- lazy = false,
    event = "VeryLazy",
    dependencies = { "neovim/nvim-lspconfig" },
    opts = {},
    config = function()
      vim.g.jupytext_fmt = "py:percent"

      -- Autocmd to set cell markers
      vim.api.nvim_create_autocmd({ "BufEnter" }, { -- "BufWriteCmd"
        group = vim.api.nvim_create_augroup("au_show_cell_markers", { clear = true }),
        pattern = { "*.py", "*.r", "*.ipynb", "*.jl", "*.scala", "*.lua", "*.fnl" },
        callback = function(event)
          require("custom.configs.cell_marker").show_cell_markers()
        end,
      })
    end,
  },

  -- latex
  {
    "lervag/vimtex",
    ft = { "tex" },
    opts = { patterns = { "*.tex" } },
    config = function(_, opts)
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = opts.patterns,
        callback = function()
          vim.cmd [[VimtexCompile]]
        end,
      })

      -- Live compilation
      vim.g.vimtex_compiler_latexmk = {
        build_dir = ".out",
        options = {
          "-shell-escape",
          "-verbose",
          "-file-line-error",
          "-interaction=nonstopmode",
          "-synctex=1",
        },
      }
      vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_fold_enabled = true
      vim.g.vimtex_syntax_conceal = {
        accents = 1,
        ligatures = 1,
        cites = 1,
        fancy = 1,
        spacing = 0, -- default: 1
        greek = 1,
        math_bounds = 1,
        math_delimiters = 1,
        math_fracs = 1,
        math_super_sub = 1,
        math_symbols = 1,
        sections = 0,
        styles = 1,
      }
    end,
  },

  -- leap
  {
    "ggandor/leap.nvim",
    config = function()
      require("leap").add_default_mappings()
    end,
  },

  -- markdown
  {
    "preservim/vim-markdown",
    branch = "master",
    dependencies = { "godlygeek/tabular" },
    config = function()
      vim.g.vim_markdown_folding_style_pythonic = 1
      vim.g.vim_markdown_folding_level = 6
    end,
  },

  -- markdown preview
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && yarn install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
  },

  -- marksman
  -- {
  --   "artempyanykh/marksman",
  -- },

  -- magma
  -- {
  --   "dccsillag/magma-nvim",
  -- },

  -- media
  {
    "nvim-telescope/telescope-media-files.nvim",
    dependencies = {
      "nvim-lua/popup.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-telescope/telescope-media-files.nvim",
    },
    config = function()
      require("telescope").setup {
        extensions = {
          media_files = {
            filetypes = { "png", "webp", "jpg", "jpeg" },
            find_cmd = "rg",
          },
        },
      }
    end,
  },

  -- metals
  {
    "scalameta/nvim-metals",
    dependencies = { "nvim-lua/plenary.nvim" },
    ft = { "scala" },
    opts = {},
    config = function(_, opts)
      local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
        pattern = { "*.scala", "*.sbt", "*.sc" },
        callback = function()
          local metals_config = require("metals").bare_config()
          metals_config.on_attach = function(client, bufnr)
            require("metals").setup_dap()
          end
          metals_config.init_options.statusBarProvider = "on"
          metals_config.settings = {
            showImplicitArguments = false,
            showInferredType = true,
            excludedPackages = {},
          }
          require("metals").initialize_or_attach(metals_config)
        end,
        group = nvim_metals_group,
      })
    end,
  },

  -- mini
  { "echasnovski/mini.nvim" },

  -- mini ai
  {
    "echasnovski/mini.ai",
    opts = function(_, opts)
      opts.custom_textobjects =
        vim.tbl_extend("force", opts.custom_textobjects, { h = require("custom.configs.cell_marker").miniai_spec })
    end,
  },

  -- neotest
  {
    "nvim-neotest/neotest",
    dependencies = {
      "stevanmilic/neotest-scala",
    },
    opts = function(_, opts)
      vim.list_extend(opts.adapters, {
        require "neotest-scala",
      })
    end,
  },

  -- obisidian
  {
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
      "nvim-telescope/telescope.nvim",
      "epwalsh/pomo.nvim",
    },
    config = function()
      require("obsidian").setup {
        workspaces = {
          {
            name = "SI",
            path = "~/Obsidian/SI",
          },
        },
        detect_cwd = false,
        notes_subdir = "Area/Journal",
        log_level = vim.log.levels.INFO,
        daily_notes = {
          folder = "Area/Journal/Daily",
          date_format = "%Y-%m-%d",
          alias_format = "%B %-d, %Y",
          template = nil,
        },
        completion = {
          nvim_cmp = true,
          min_chars = 2,
          new_notes_location = "current_dir",
          prepend_note_id = true,
          prepend_note_path = false,
          use_path_only = false,
        },
        note_id_func = function(title)
          local suffix = ""
          if title ~= nil then
            suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
          else
            for _ = 1, 4 do
              suffix = suffix .. string.char(math.random(65, 90))
            end
          end
          return tostring(os.time()) .. "-" .. suffix
        end,
        disable_frontmatter = false,
        note_frontmatter_func = function(note)
          local out = { id = note.id, aliases = note.aliases, tags = note.tags }
          if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
            for k, v in pairs(note.metadata) do
              out[k] = v
            end
          end
          return out
        end,
        templates = {
          subdir = "templates",
          date_format = "%Y-%m-%d",
          time_format = "%H:%M",
          substitutions = {},
        },
        backlinks = {
          height = 10,
          wrap = true,
        },
        follow_url_func = function(url)
          vim.fn.jobstart { "open", url } -- Mac OS
          -- vim.fn.jobstart({"xdg-open", url})  -- linux
        end,
        use_advanced_uri = false,
        open_app_foreground = false,
        finder = "telescope.nvim",
        sort_by = "modified",
        sort_reversed = true,
        open_notes_in = "current",
        ui = {
          enable = true, -- set to false to disable all additional syntax features
          update_debounce = 200, -- update delay after a text change (in milliseconds)
          checkboxes = {
            [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
            ["x"] = { char = "", hl_group = "ObsidianDone" },
            [">"] = { char = "", hl_group = "ObsidianRightArrow" },
            ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
          },
          external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
          reference_text = { hl_group = "ObsidianRefText" },
          highlight_text = { hl_group = "ObsidianHighlightText" },
          tags = { hl_group = "ObsidianTag" },
          hl_groups = {
            ObsidianTodo = { bold = true, fg = "#f78c6c" },
            ObsidianDone = { bold = true, fg = "#89ddff" },
            ObsidianRightArrow = { bold = true, fg = "#f78c6c" },
            ObsidianTilde = { bold = true, fg = "#ff5370" },
            ObsidianRefText = { underline = true, fg = "#c792ea" },
            ObsidianExtLinkIcon = { fg = "#c792ea" },
            ObsidianTag = { italic = true, fg = "#89ddff" },
            ObsidianHighlightText = { bg = "#75662e" },
          },
        },
        attachments = {
          img_folder = "assets/imgs", -- This is the default
          ---@param client obsidian.Client
          ---@param path Path the absolute path to the image file
          ---@return string
          img_text_func = function(client, path)
            local link_path
            local vault_relative_path = client:vault_relative_path(path)
            if vault_relative_path ~= nil then
              link_path = vault_relative_path
            else
              link_path = tostring(path)
            end
            local display_name = vim.fs.basename(link_path)
            return string.format("![%s](%s)", display_name, link_path)
          end,
        },
        yaml_parser = "native",
      }
    end,
  },

  -- otter
  {
    "jmbuhr/otter.nvim",
    opts = {
      buffers = {
        set_filetype = true,
      },
    },
  },

  -- playground
  {
    "nvim-treesitter/playground",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    cmd = { "TSPlaygroundToggle" },
    config = function()
      require("nvim-treesitter.configs").setup {
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
      }
    end,
  },

  -- portal
  -- {
  --   "cbochs/portal.nvim",
  --   keys = { "<leader>pj", "<leader>ph" },
  -- },

  -- project
  {
    "ahmedkhalf/project.nvim",
    config = function()
      require("project_nvim").setup()
      require("nvim-tree").setup {
        sync_root_with_cwd = true,
        respect_buf_cwd = true,
        update_focused_file = {
          enable = true,
          update_root = true,
        },
      }
    end,
  },

  -- refactoring
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("refactoring").setup()
    end,
  },

  -- slime
  -- {
  --   "jpalardy/vim-slime",
  --   init = function()
  --     vim.b["quarto_is_" .. "python" .. "_chunk"] = false
  --     Quarto_is_in_python_chunk = function()
  --       require("otter.tools.functions").is_otter_language_context "python"
  --     end
  --
  --     vim.cmd [[
  --     let g:slime_dispatch_ipython_pause = 100
  --     function SlimeOverride_EscapeText_quarto(text)
  --     call v:lua.Quarto_is_in_python_chunk()
  --     if exists('g:slime_python_ipython') && len(split(a:text,"\n")) > 1 && b:quarto_is_python_chunk
  --     return ["%cpaste -q\n", g:slime_dispatch_ipython_pause, a:text, "--", "\n"]
  --     else
  --     return a:text
  --     end
  --     endfunction
  --     ]]
  --
  --     local function mark_terminal()
  --       vim.g.slime_last_channel = vim.b.terminal_job_id
  --       vim.print(vim.g.slime_last_channel)
  --     end
  --
  --     local function set_terminal()
  --       vim.b.slime_config = { jobid = vim.g.slime_last_channel }
  --     end
  --
  --     -- slime, neovvim terminal
  --     vim.g.slime_target = "neovim"
  --     vim.g.slime_python_ipython = 1
  --
  --     require("which-key").register {
  --       ["<leader>cm"] = { mark_terminal, "mark terminal" },
  --       ["<leader>cs"] = { set_terminal, "set terminal" },
  --     }
  --   end,
  -- },

  -- sniprun
  {
    "michaelb/sniprun",
    -- run = "sh ./install.sh 1",
    config = function()
      require("sniprun").setup {
        -- repl_enable = { "Python3_original" }, --# enable REPL-like behavior for the given interpreters
        -- repl_disable = {}, --# disable REPL-like behavior for the given interpretersepl_enable = { "Python3_original" },
        -- interpreter_options = { --# interpreter-specific options, see doc / :SnipInfo <name>
        --
        --   --# use the interpreter name as key
        --   GFM_original = {
        --     use_on_filetypes = { "markdown.pandoc" }, --# the 'use_on_filetypes' configuration key is
        --     --# available for every interpreter
        --   },
        --   Python3_original = {
        --     error_truncate = "auto", --# Truncate runtime errors 'long', 'short' or 'auto' # the hint is available for every interpreter # but may not be always respected
        --     interpreter = "python3.9",
        --     venv = { "" },
        --   },
        -- },
        borders = "single",
      }
    end,
  },

  -- surround
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup {
        -- Configuration here, or leave empty to use defaults
      }
    end,
  },

  -- SQL
  {
    "tpope/vim-dadbod",
    lazy = true,
    dependencies = {
      "kristijanhusak/vim-dadbod-ui",
      { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
    },
    opts = {},
    config = function()
      require("custom.configs.dadbod").setup()
    end,
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer", "DBUIRenameBuffer", "DBUILastQueryInfo" },
  },
  -- {
  --   "kristijanhusak/vim-dadbod-ui",
  --   dependencies = {
  --     { "tpope/vim-dadbod", lazy = true },
  --     { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
  --   },
  --   cmd = {
  --     "DBUI",
  --     "DBUIToggle",
  --     "DBUIAddConnection",
  --     "DBUIFindBuffer",
  --   },
  --   init = function()
  --     -- Your DBUI configuration
  --     vim.g.db_ui_use_nerd_fonts = 1
  --   end,
  -- },

  -- tagbar
  {
    "preservim/tagbar",
    dependencies = { "nvim-telescope/telescope.nvim" },
    cmd = "TagbarToggle",
  },

  -- telescope-frecency
  {
    "nvim-telescope/telescope-frecency.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("telescope").load_extension "frecency"
    end,
  },

  -- telescope-fzf-native
  -- {
  --   "nvim-telescope/telescope-fzf-native.nvim",
  --   build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
  -- },

  -- telescope-undo
  {
    "debugloop/telescope-undo.nvim",
    dependencies = { -- note how they're inverted to above example
      {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
      },
    },
    keys = {
      { -- lazy style key map
        "<leader>u",
        "<cmd>Telescope undo<cr>",
        desc = "undo history",
      },
    },
    opts = {
      -- don't use `defaults = { }` here, do this in the main telescope spec
      extensions = {
        undo = {
          -- telescope-undo.nvim config, see below
        },
        -- no other extensions here, they can have their own spec too
      },
    },
    config = function(_, opts)
      -- Calling telescope's setup from multiple specs does not hurt, it will happily merge the
      -- configs for us. We won't use data, as everything is in it's own namespace (telescope
      -- defaults, as well as each extension).
      require("telescope").setup(opts)
      require("telescope").load_extension "undo"
    end,
  },

  -- tmux
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
  },

  -- todo
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    config = function()
      require("todo-comments").setup()
    end,
    cmd = {
      "Todo",
      "TodoTrouble",
      "TodoTelescope",
      "TodoLocList",
      "TodoQuickFix",
    },
  },

  -- trouble
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
    config = function()
      require("trouble").setup()
    end,
  },

  -- visual multi
  { "mg979/vim-visual-multi" },

  -- quarto
  -- {
  --   "quarto-dev/quarto-nvim",
  --   dependencies = {
  --     "jmbuhr/otter.nvim",
  --     "neovim/nvim-lspconfig",
  --   },
  --   opts = {
  --     lspFeatures = {
  --       languages = { "r", "python", "julia", "bash", "html", "lua" },
  --     },
  --   },
  --   ft = "quarto",
  --   cmd = {
  --     "QuartoPreview",
  --     "QuartoClosePreview",
  --     "QuartoActivate",
  --     "QuartoHelp",
  --     "QuartoHover",
  --   },
  -- },
}

return plugins
