---@type MappingsTable
local M = {}
local opts = { noremap = false, expr = true, buffer = true }

M.disabled = {
  n = {
    ["<A-i>"] = "",
    ["<C-a>"] = "",
    ["<C-b>"] = "",
    ["<C-c>"] = "",
    ["<leader>b"] = "",
    ["<leader>ca"] = "",
    ["<leader>fm"] = "",
    ["<leader>n"] = "",
    ["<leader>rn"] = "",
    ["<leader>td"] = "",
    ["<tab>"] = "",
    ["<S-tab>"] = "",
  },

  t = {
    ["<A-i>"] = "",
  },
}

M.general = {
  i = {
    -- ESC
    ["jk"] = { "<ESC>", "Exit Insert Mode" },

    -- Navigation
    ["<C-i>"] = { "<ESC>^i", "Beginning Of Line" },

    -- Lines
    ["<C-a>"] = { "<ESC>o", "Next Line", opts = { nowait = true } },
    ["<C-b>"] = { "<ESC>O", "Previous Line", opts = { nowait = true } },
    ["<leader>ln"] = { "<cmd> set nu! <CR>", "Toggle Line Number" },
    ["<leader>lrn"] = { "<cmd> set rnu! <CR>", "Toggle Relative Number" },
  },

  n = {
    -- General
    ["<C-c>"] = { ":", "Enter Command Mode", opts = { nowait = true } },
    -- ["x"] = { "_x", "No Register x" },
    ["Q"] = { "<nop>", "Nothing" },

    -- Copy & Paste
    ["<leader>cpa"] = { "<cmd> %y+ <CR>", "Copy Whole File" },
    ["<leader>y"] = { '"+y', "yank in Vim" },
    ["<leader>Y"] = { '"+Y', "Yank in Clipboard" },
    -- ["<leader>s"] = { [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], "Replace char on cursor" },

    -- Formatting
    ["<leader>lfm"] = {
      function()
        vim.lsp.buf.format { async = true }
      end,
      "LSP Formatting",
    },

    -- Line
    -- ["<C-a>"] = { "o<ESC>", "Blank line after", opts = { nowait = true } },
    -- ["<C-b>"] = { "O<ESC>", "Blank line before", opts = { nowait = true } },

    -- Navigation
    ["J"] = { "mzJ`z", "Join A Line To Pre-line" },
    ["n"] = { "nzzzv", "Down Search with Mid Cursor" },
    ["N"] = { "Nzzzv", "Up Search with Mid Cursor" },
    ["<C-d>"] = { "<C-d>zz", "Jump 1/2 Page with Mid Cursor" },
    ["<C-u>"] = { "<C-u>zz", "Up 1/2 Page with Mid Cursor" },
    ["<C-f>"] = { "<C-f>zz", "Page Down with Mid Cursor" },
    ["<C-b>"] = { "<C-b>zz", "Page Up with Mid Cursor" },
    -- ["<C-k>"] = { "<cmd>cnext<CR>zz", "reset cursor" },
    -- ["<C-j>"] = { "<cmd>cprev<CR>zz", "reset cursor" },
    ["<C-h>"] = { "<cmd> TmuxNavigateLeft <CR>", "Window Left" },
    ["<C-l>"] = { "<cmd> TmuxNavigateRight <CR>", "Window Right" },
    ["<C-j>"] = { "<cmd> TmuxNavigateDown <CR>", "Window Down" },
    ["<C-k>"] = { "<cmd> TmuxNavigateUp <CR>", "Window Up" },
    ["<leader>tg"] = {
      function()
        require("base46").toggle_theme()
      end,
      "Theme Toggle",
    },

    -- New Buffer
    ["<leader>bf"] = { "<cmd> enew <CR>", "New Buffer" },

    -- Split
    ["<leader>sv"] = { "<C-w>v", "Split Vertically" },
    ["<leader>sh"] = { "<C-w>h", "Split Horizontally" },
    ["<leader>se"] = { "<C-w>=", "Equal Width" },
    ["<leader>sx"] = { "<cmd> close <CR>", "Close Split Window" },
  },
  v = {
    [";"] = { ":", "Enter Command Mode", opts = { nowait = true } },
    [">"] = { ">gv", "Indent" },
    ["<C-n>"] = { "<ESC> ", "Exit Visual Mode" },
    ["J"] = { ":m '>+1<CR>gv=gv", "Move A Line To Bottom" },
    ["K"] = { ":m '<-2<CR>gv=gv", "Move A Line To Up" },
    ["<leader>y"] = { '"+y', "yank in Vim" },
  },
}

-- more keybinds!
M.browse = {
  n = {
    ["<leader>bs"] = {
      function()
        require("browse").input_search()
      end,
      "Search Bookmarks",
    },

    ["<leader>bm"] = {
      function()
        require("browse").open_bookmarks()
      end,
      "Browse Bookmarks",
    },

    ["<leader>bb"] = {
      function()
        require("browse").browse()
      end,
      "Browse Bookmarks",
    },

    ["<leader>bd"] = {
      function()
        require("browse.devdocs").search()
      end,
      "Search Devdocs",
    },

    ["<leader>bn"] = {
      function()
        require("browse.mdn").search()
      end,
      "Search MDN",
    },
  },
}

M.chatgpt = {
  n = {
    ["<leader>cg<CR>"] = { "<cmd> ChatGPT <CR>", "ChatGPT" },
    ["<leader>cgc"] = { "<cmd> ChatGPTCompleteCode <CR>", "ChatGPT Complete Code" },
    ["<leader>cgt"] = { "<cmd> ChatGPTRun add_tests <CR>", "ChatGPT Add Test" },
    ["<leader>cgf"] = { "<cmd> ChatGPTRun fix_bugs <CR>", "ChatGPT Fix Bugs" },
    ["<leader>cga"] = { "<cmd> ChatGPTActAs <CR>", "ChatGPT Act As" },
    ["<leader>cgi"] = { "<cmd> ChatGPTEditWithInstructions <CR>", "ChatGPT Edit" },
  },

  v = {
    ["<leader>cge"] = { "<cmd> ChatGPTRun explain_code <CR>", "ChatGPT Explain Code" },
  },
}

M.dadbod = {
  n = {
    ["<leader>db"] = { "<cmd> DBUI <CR>", "DB UI" },
    ["<leader>du"] = { "<cmd> DBUIToggle <CR>", "Toggle UI" },
    ["<leader>da"] = { "<cmd> DBUIAddConnection <CR>", "Add Connection" },
    ["<leader>df"] = { "<cmd> DBUIFindBuffer <CR>", "Find buffer" },
    ["<leader>dr"] = { "<cmd> DBUIRenameBuffer <CR>", "Rename buffer" },
    ["<leader>dl"] = { "<cmd> DBUILastQueryInfo <CR>", "Last query info" },
  },
}

M.gitsigns = {
  n = {
    ["<leader>gd"] = {
      function()
        require("gitsigns").toggle_deleted()
      end,
      "Toggle Deleted",
    },
  },
}

M.harpoon = {
  n = {
    ["<leader>a"] = {
      function()
        require("harpoon.mark").add_file()
      end,
      "Harpoon Add File",
    },
    ["<leader>ta"] = { "<cmd> Telescope harpoon marks <CR>", "Toggle Quick Menu" },
    ["<leader><tab>"] = {
      function()
        require("harpoon.ui").toggle_quick_menu()
      end,
      "Harpoon Menu",
    },
    ["<leader>1"] = {
      function()
        require("harpoon.ui").nav_file(1)
      end,
      "Navigate to File 1",
    },
    ["<leader>2"] = {
      function()
        require("harpoon.ui").nav_file(2)
      end,
      "Navigate to File 2",
    },
    ["<leader>3"] = {
      function()
        require("harpoon.ui").nav_file(3)
      end,
      "Navigate to File 3",
    },
    ["<leader>4"] = {
      function()
        require("harpoon.ui").nav_file(4)
      end,
      "Navigate to File 4",
    },
  },
}

M.iron = {
  n = {
    ["<leader>ir"] = { "<cmd> IronRepl <CR>", "REPL" },
    ["<leader>iS"] = { "<cmd> IronRestart <CR>", "Restart" },
    ["<leader>iF"] = { "<cmd> IronFocus <CR>", "Focus" },
    ["<leader>iH"] = { "<cmd> IronHide <CR>", "Hide" },
    ["<leader>ism"] = {
      function()
        require("iron.core").run_motion "send_motion"
      end,
      "Send Motion",
    },
    ["<leader>isl"] = {
      function()
        require("iron.core").send_line()
      end,
      "Send Line",
    },
    ["<leader>ist"] = {
      function()
        require("iron.core").send_until_cursor()
      end,
      "Send Until Cursor",
    },
    ["<leader>isf"] = {
      function()
        require("iron.core").send_file()
      end,
      "Send File",
    },
    ["<leader>i<cr>"] = {
      function()
        require("iron.core").send(nil, string.char(13))
      end,
      "ENTER",
    },
    ["<leader>ii"] = {
      function()
        require("iron.core").send(nil, string.char(03))
      end,
      "Interrupt",
    },
    ["<leader>id"] = {
      function()
        require("iron.core").close_repl()
      end,
      "Close REPL",
    },
    ["<leader>ic"] = {
      function()
        require("iron.core").send(nil, string.char(12))
      end,
      "Clear",
    },
    ["<leader>ims"] = {
      function()
        require("iron.core").send_mark()
      end,
      "Send Mark",
    },
    ["<leader>imm"] = {
      function()
        require("iron.core").run_motion "mark_motion"
      end,
      "Mark Motion",
    },
    ["<leader>imr"] = {
      function()
        require("iron.marks").drop_last()
      end,
      "Remove Mark",
    },
    -- ["<leader>iar"] = {
    --   function() end,
    --   "+ REPL",
    -- },
    -- ["<leader>iam"] = {
    --   function() end,
    --   "+ Mark",
    -- },

    -- cell
    ["<leader>ca"] = {
      function()
        require("custom.configs.cell_marker").insert_cell_after()
      end,
      "Insert Cell After",
    },
    ["<leader>cb"] = {
      function()
        require("custom.configs.cell_marker").insert_cell_before()
      end,
      "Insert Cell Before",
    },
    ["<leader>cm"] = {
      function()
        require("custom.configs.cell_marker").insert_markdown_cell()
      end,
      "Insert Markdown Cell",
    },
    ["<leader>cd"] = {
      function()
        require("custom.configs.cell_marker").delete_cell()
      end,
      "Delete Cell",
    },
    ["<leader>cj"] = {
      function()
        require("custom.configs.cell_marker").navigate_cell()
      end,
      "Next Cell",
    },
    ["<leader>ck"] = {
      function()
        require("custom.configs.cell_marker").navigate_cell(true)
      end,
      "Previous Cell",
    },
    ["<leader>cr"] = {
      function()
        require("custom.configs.cell_marker").execute_cell()
      end,
      "Cell Run",
    },
  },

  v = {
    ["<leader>ihc"] = {
      function()
        require("iron.marks").clear_hl()
      end,
      "Clear Highlight",
    },
    ["<leader>imv"] = {
      function()
        require("iron.core").mark_visual()
      end,
      "Mark Visual",
    },
    ["<leader>is"] = {
      function()
        require("iron.core").visual_send()
      end,
      "Send",
    },
  },
}

M.lspconfig = {
  v = {
    ["<leader>ca"] = {
      function()
        vim.lsp.buf.code_action()
      end,
      "LSP code action",
    },
  },
}

M.markdown = {
  n = {
    ["<leader>mp"] = { "<cmd> MarkdownPreview <CR>", "Markdown Preview" },
    ["<leader>ms"] = { "<cmd> MarkdownPreviewStop <CR>", "Markdown Stop" },
    ["<leader>mt"] = { "<cmd> MarkdownPreviewToggle <CR>", "Markdown Toggle" },
  },
}

M.media = {
  n = {
    ["<leader>fm"] = { "<cmd> Telescope media_files <CR>", "Media Files" },
  },
}

M.nvterm = {
  t = {
    ["<A-t>"] = {
      function()
        require("nvterm.terminal").toggle "float"
      end,
      "Toggle Floating Term",
    },
  },
}

M.playground = {
  n = {
    ["<leader>pg"] = { "<cmd> TSPlaygroundToggle <CR>", "Toggle Playground" },
    ["<leader>pc"] = { "<cmd> TSHighlightCapturesUnderCurso <CR>", "Highlight Captures" },
    ["<leader>pn"] = { "<cmd> TSNodeUnderCursor <CR>", "Node Under Cursor" },
  },
}

M.portal = {
  n = {
    ["<leader>pj"] = { "<cmd> Portal jumplist backward <CR>", "Portal Jumplist" },
    ["<leader>ph"] = {
      function()
        require("portal.builtin").harpoon.tunnel()
      end,
      "Portal Harpoon",
    },
  },
}

M.project = {
  n = {
    ["<leader>fp"] = { "<cmd> Telescope projects <CR>", "Find Project" },
  },
}

M.refactoring = {
  n = {
    -- refactoring
    ["<leader>ri"] = { "<cmd> Refactor inline_var <CR>", "Refactor Inline Var" },
    ["<leader>rI"] = { "<cmd> Refactor inline_func <CR>", "Refactor Inline Function" },

    ["<leader>rb"] = { "<cmd> Refactor extract_block <CR>", "Refactor Extract Block" },
    ["<leader>rbf"] = { "<cmd> Refactor extract_block_to_file <CR>", "Refactor Extrack Block To File" },
  },

  x = {
    -- copy & paste
    -- ["<leader>p"] = { '"_dp', "preserve cut" },

    -- refactoring
    ["<leader>re"] = { "<cmd> Refactor extract <CR>", "Refactor Extract" },
    ["<leader>rf"] = { "<cmd> Refactor extract_to_file <CR>", "Refactor Extract To File" },
    ["<leader>rv"] = { "<cmd> Refactor extract_var <CR>", "Refactor Extract Var" },
    ["<leader>ri"] = { "<cmd> Refactor inline_var <CR>", "Refactor Inline Var" },
  },
}

M.sniprun = {
  n = {
    ["<leader>sr"] = {
      "<cmd>lua require('sniprun').run()<CR>",
      "Run Code",
    },

    ["<leader>ss"] = {
      "<cmd>lua require('sniprun').reset()<CR>",
      "Reset Code",
    },

    ["<leader>sc"] = {
      "<cmd>lua require('sniprun').clear_repl()<CR>",
      "Clean Repl Meomory",
    },

    ["<leader>sd"] = {
      "<cmd>lua require('sniprun.display').close_all()<CR>",
      "Close Display",
    },
  },

  v = {
    ["<C-,>"] = {
      "<cmd>lua require('sniprun').run('v')<CR>",
      "Run Code",
    },
  },
}

M.tagbar = {
  n = {
    ["<leader>tb"] = { "<cmd> TagbarToggle <CR>", "Toggle Tagbar" },
  },
}

M.telescope = {
  n = {
    ["<leader>u"] = {
      function()
        require("telescope").extensions.undo.undo()
      end,
      "Undo Tree",
    },

    ["<leader>fc"] = { "<Cmd> Telescope frecency <CR>", "Frequent Files" },
  },
}

M.todo = {
  n = {
    ["<leader>tdo"] = { "<cmd> Todo <CR>", "Todo" },
    ["<leader>tds"] = { "<cmd> TodoTelescope <CR>", "Todo Telescope" },
    ["<leader>tdt"] = { "<cmd> TodoTrouble <CR>", "Todo Trouble" },
    ["<leader>tdl"] = { "<cmd> TodoLocList <CR>", "Todo Loclist" },
    ["<leader>tdf"] = { "<cmd> TodoQuickFix <CR>", "Todo Fix" },
  },
}

M.treesitter = {
  n = {
    -- ["<leader>tc"] = { "<cmd> TSContextEnable <CR>", "Toggle treesitter context" },
    ["<leader>gc"] = {
      function()
        require("treesitter-context").go_to_context()
      end,
      "Go To Context",
    },
  },
}

M.trouble = {
  n = {
    ["<leader>trb"] = {
      function()
        require("trouble").toggle()
      end,
      "Trouble",
    },
    ["<leader>trw"] = {
      function()
        require("trouble").toggle "workspace_diagnostics"
      end,
      "Trouble Workspace Diagnostics",
    },
    ["<leader>trd"] = {
      function()
        require("trouble").toggle "document_diagnostics"
      end,
      "Trouble Document Diagnostics",
    },
    ["<leader>trq"] = {
      function()
        require("trouble").toggle "quickfix"
      end,
      "Trouble Quickfix",
    },
    ["<leader>trl"] = {
      function()
        require("trouble").toggle "loclist"
      end,
      "Trouble Loclist",
    },
    ["gR"] = {
      function()
        require("trouble").toggle "lsp_references"
      end,
      "Trouble Lsp References",
    },
    ["<leader>trc"] = {
      function()
        require("trouble").close()
      end,
      "Trouble Close",
    },
    ["<leader>tro"] = {
      function()
        require("trouble").next { skip_groups = true, jump = true }
      end,
      "Trouble Next",
    },
    ["<leader>tri"] = {
      function()
        require("trouble").previous { skip_groups = true, jump = true }
      end,
      "Trouble Previous",
    },
    ["<leader>trf"] = {
      function()
        require("trouble").first { skip_groups = true, jump = true }
      end,
      "Trouble First",
    },
    ["<leader>tre"] = {
      function()
        require("trouble").last { skip_groups = true, jump = true }
      end,
      "Trouble Last",
    },
    -- ["<leader>trt"] = {
    --   function()
    --     require("trouble.providers.telescope").open_with_trouble()
    --   end,
    --   "Trouble Telescope",
    -- },
  },
}

M.obsidian = {
  i = {
    ["gf"] = {
      function()
        require("obsidian").util.gf_passthrough()
      end,
      "gf",
      opts,
    },
  },

  n = {
    ["gf"] = {
      function()
        require("obsidian").util.gf_passthrough()
      end,
      "gf",
      opts,
    },
    ["<leader>op"] = {
      function()
        local query = vim.fn.input "Enter query: "
        if query and #query > 0 then
          vim.cmd("ObsidianOpen " .. query)
        end
      end,
      "Open Notes",
    },
    ["<leader>on"] = {
      function()
        local title = vim.fn.input "Enter title: "
        if title and #title > 0 then
          vim.cmd("ObsidianNew " .. title)
        end
      end,
      "New Notes",
    },
    ["<leader>ot"] = {
      function()
        local offset = vim.fn.input "Enter offset: "
        if offset and #offset > 0 then
          vim.cmd("ObsidianToday " .. offset)
        else
          vim.cmd "ObsidianToday"
        end
      end,
      "Today Note",
    },
    ["<leader>of"] = {
      function()
        local note = vim.fn.input "Enter note: "
        if note and #note > 0 then
          vim.cmd("ObsidianSearch " .. note)
        end
      end,
      "Search Note",
    },
    ["<leader>ow"] = {
      function()
        local name = vim.fn.input "Enter name: "
        if name and #name > 0 then
          vim.cmd("ObsidianWorkspace " .. name)
        end
      end,
      "Workspace Name",
    },
    ["<leader>oi"] = {
      function()
        local image = vim.fn.input "Enter image: "
        if image and #image > 0 then
          vim.cmd("ObsidianPasteImg " .. image)
        end
      end,
      "Paste Image",
    },
    ["<leader>or"] = {
      function()
        local name = vim.fn.input "Enter name: "
        if name and #name > 0 then
          vim.cmd("ObsidianRename " .. name)
        end
      end,
      "Rename",
    },
    ["<leader>o["] = { "<cmd> ObsidianBacklinks <CR>", "Back Link" },
    ["<leader>o]"] = { "<cmd> ObsidianFollowLink <CR>", "Follow Link" },
    ["<leader>os"] = { "<cmd> ObsidianQuickSwitch <CR>", "Quick Switch" },
    ["<leader>ol"] = { "<cmd> ObsidianTomorrow <CR>", "Tomorrow Note" },
    ["<leader>oh"] = { "<cmd> ObsidianYesterday <CR>", "Yesterday Note" },
  },

  v = {
    ["<leader>ol"] = {
      function()
        local query = vim.fn.input "Enter query: "
        if query and #query > 0 then
          vim.cmd("ObsidianLink " .. query)
        else
          vim.cmd "ObsidianLink"
        end
      end,
      "Link Query",
    },
    ["<leader>on"] = {
      function()
        local note = vim.fn.input "Enter note: "
        if note and #note > 0 then
          vim.cmd("ObsidianLinkNew " .. note)
        else
          vim.cmd "ObsidianLinkNew"
        end
      end,
      "New Link Note",
    },
  },
}

M.tabufline = {
  n = {
    ["L"] = {
      function()
        require("nvchad.tabufline").tabuflineNext()
      end,
      "Goto next buffer",
    },

    ["H"] = {
      function()
        require("nvchad.tabufline").tabuflinePrev()
      end,
      "Goto prev buffer",
    },
  },
}

return M
