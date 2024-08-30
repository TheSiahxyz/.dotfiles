return {
	{
		"echasnovski/mini.files",
		version = false,
		config = function()
			require("mini.files").setup()
		end,
		keys = {
			{
				"<leader>E",
				"<cmd>lua MiniFiles.open()<cr>",
				desc = "Open mini files",
			},
		},
	},
	{
		"echasnovski/mini.pairs",
		version = false,
		event = "VeryLazy",
		config = function()
			require("mini.pairs").setup()
		end,
		keys = {
			{
				"<leader>tp",
				function()
					vim.g.minipairs_disable = not vim.g.minipairs_disable
				end,
				desc = "Toggle auto pairs",
			},
		},
	},
	{
		"echasnovski/mini.indentscope",
		version = false, -- wait till new 0.7.0 release to put it back on semver
		event = "VeryLazy",
		opts = {
			mappings = {
				-- Textobjects
				object_scope = "i-",
				object_scope_with_border = "a-",

				-- Motions (jump to respective border line; if not present - body line)
				goto_top = "<leader>[-",
				goto_bottom = "<leader>]-",
			},
			draw = {
				animation = function()
					return 0
				end,
			},
			options = { try_as_border = true },
			symbol = "│",
		},
		init = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = {
					"help",
					"Trouble",
					"trouble",
					"lazy",
					"mason",
				},
				callback = function()
					vim.b.miniindentscope_disable = true
				end,
			})
		end,
	},
	{
		"echasnovski/mini.bracketed",
		version = false,
		config = function()
			require("mini.bracketed").setup({
				buffer = { suffix = "", options = {} },
				comment = { suffix = "", options = {} },
				conflict = { suffix = "", options = {} },
				diagnostic = { suffix = "", options = {} },
				file = { suffix = "", options = {} },
				indent = { suffix = "", options = {} },
				jump = { suffix = "", options = {} },
				location = { suffix = "", options = {} },
				oldfile = { suffix = "", options = {} },
				quickfix = { suffix = "", options = {} },
				treesitter = { suffix = "", options = {} },
				undo = { suffix = "", options = {} },
				window = { suffix = "", options = {} },
				yank = { suffix = "", options = {} },
			})

			vim.keymap.set("n", "<leader>[B", "<Cmd>lua MiniBracketed.buffer('first')<cr>", { desc = "Buffer first" })
			vim.keymap.set(
				"n",
				"<leader>[b",
				"<Cmd>lua MiniBracketed.buffer('backward')<cr>",
				{ desc = "Buffer backward" }
			)
			vim.keymap.set(
				"n",
				"<leader>]b",
				"<Cmd>lua MiniBracketed.buffer('forward')<cr>",
				{ desc = "Buffer forward" }
			)
			vim.keymap.set("n", "<leader>]B", "<Cmd>lua MiniBracketed.buffer('last')<cr>", { desc = "Buffer last" })
			vim.keymap.set("n", "<leader>[C", "<Cmd>lua MiniBracketed.comment('first')<cr>", { desc = "Comment first" })
			vim.keymap.set(
				"n",
				"<leader>[c",
				"<Cmd>lua MiniBracketed.comment('backward')<cr>",
				{ desc = "Comment backward" }
			)
			vim.keymap.set(
				"n",
				"<leader>]c",
				"<Cmd>lua MiniBracketed.comment('forward')<cr>",
				{ desc = "Comment forward" }
			)
			vim.keymap.set("n", "<leader>]C", "<Cmd>lua MiniBracketed.comment('last')<cr>", { desc = "Comment last" })
			vim.keymap.set(
				"n",
				"<leader>[X",
				"<Cmd>lua MiniBracketed.conflict('first')<cr>",
				{ desc = "Conflict first" }
			)
			vim.keymap.set(
				"n",
				"<leader>[x",
				"<Cmd>lua MiniBracketed.conflict('backward')<cr>",
				{ desc = "Conflict backward" }
			)
			vim.keymap.set(
				"n",
				"<leader>]x",
				"<Cmd>lua MiniBracketed.conflict('forward')<cr>",
				{ desc = "Conflict forward" }
			)
			vim.keymap.set("n", "<leader>]X", "<Cmd>lua MiniBracketed.conflict('last')<cr>", { desc = "Conflict last" })
			vim.keymap.set(
				"n",
				"<leader>[D",
				"<Cmd>lua MiniBracketed.diagnostic('first')<cr>",
				{ desc = "Diagnostic first" }
			)
			vim.keymap.set(
				"n",
				"<leader>[d",
				"<Cmd>lua MiniBracketed.diagnostic('backward')<cr>",
				{ desc = "Diagnostic backward" }
			)
			vim.keymap.set(
				"n",
				"<leader>]d",
				"<Cmd>lua MiniBracketed.diagnostic('forward')<cr>",
				{ desc = "Diagnostic forward" }
			)
			vim.keymap.set(
				"n",
				"<leader>]D",
				"<Cmd>lua MiniBracketed.diagnostic('last')<cr>",
				{ desc = "Diagnostic last" }
			)
			vim.keymap.set("n", "<leader>[F", "<Cmd>lua MiniBracketed.file('first')<cr>", { desc = "File first" })
			vim.keymap.set("n", "<leader>[f", "<Cmd>lua MiniBracketed.file('backward')<cr>", { desc = "File backward" })
			vim.keymap.set("n", "<leader>]f", "<Cmd>lua MiniBracketed.file('forward')<cr>", { desc = "File forward" })
			vim.keymap.set("n", "<leader>]F", "<Cmd>lua MiniBracketed.file('last')<cr>", { desc = "File last" })
			vim.keymap.set("n", "<leader>[I", "<Cmd>lua MiniBracketed.indent('first')<cr>", { desc = "Indent first" })
			vim.keymap.set(
				"n",
				"<leader>[i",
				"<Cmd>lua MiniBracketed.indent('backward')<cr>",
				{ desc = "Indent backward" }
			)
			vim.keymap.set(
				"n",
				"<leader>]i",
				"<Cmd>lua MiniBracketed.indent('forward')<cr>",
				{ desc = "Indent forward" }
			)
			vim.keymap.set("n", "<leader>]I", "<Cmd>lua MiniBracketed.indent('last')<cr>", { desc = "Indent last" })
			vim.keymap.set("n", "<leader>[J", "<Cmd>lua MiniBracketed.jump('first')<cr>", { desc = "Jump first" })
			vim.keymap.set("n", "<leader>[j", "<Cmd>lua MiniBracketed.jump('backward')<cr>", { desc = "Jump backward" })
			vim.keymap.set("n", "<leader>]j", "<Cmd>lua MiniBracketed.jump('forward')<cr>", { desc = "Jump forward" })
			vim.keymap.set("n", "<leader>]J", "<Cmd>lua MiniBracketed.jump('last')<cr>", { desc = "Jump last" })
			vim.keymap.set(
				"n",
				"<leader>[L",
				"<Cmd>lua MiniBracketed.location('first')<cr>",
				{ desc = "Location first" }
			)
			vim.keymap.set(
				"n",
				"<leader>[l",
				"<Cmd>lua MiniBracketed.location('backward')<cr>",
				{ desc = "Location backward" }
			)
			vim.keymap.set(
				"n",
				"<leader>]l",
				"<Cmd>lua MiniBracketed.location('forward')<cr>",
				{ desc = "Location forward" }
			)
			vim.keymap.set("n", "<leader>]L", "<Cmd>lua MiniBracketed.location('last')<cr>", { desc = "Location last" })
			vim.keymap.set("n", "<leader>[O", "<Cmd>lua MiniBracketed.oldfile('first')<cr>", { desc = "Oldfile first" })
			vim.keymap.set(
				"n",
				"<leader>[o",
				"<Cmd>lua MiniBracketed.oldfile('backward')<cr>",
				{ desc = "Oldfile backward" }
			)
			vim.keymap.set(
				"n",
				"<leader>]o",
				"<Cmd>lua MiniBracketed.oldfile('forward')<cr>",
				{ desc = "Oldfile forward" }
			)
			vim.keymap.set("n", "<leader>]O", "<Cmd>lua MiniBracketed.oldfile('last')<cr>", { desc = "Oldfile last" })
			vim.keymap.set(
				"n",
				"<leader>[Q",
				"<Cmd>lua MiniBracketed.quickfix('first')<cr>",
				{ desc = "Quickfix first" }
			)
			vim.keymap.set(
				"n",
				"<leader>[q",
				"<Cmd>lua MiniBracketed.quickfix('backward')<cr>",
				{ desc = "Quickfix backward" }
			)
			vim.keymap.set(
				"n",
				"<leader>]q",
				"<Cmd>lua MiniBracketed.quickfix('forward')<cr>",
				{ desc = "Quickfix forward" }
			)
			vim.keymap.set("n", "<leader>]Q", "<Cmd>lua MiniBracketed.quickfix('last')<cr>", { desc = "Quickfix last" })
			vim.keymap.set(
				"n",
				"<leader>[T",
				"<Cmd>lua MiniBracketed.treesitter('first')<cr>",
				{ desc = "Treesitter first" }
			)
			vim.keymap.set(
				"n",
				"<leader>[t",
				"<Cmd>lua MiniBracketed.treesitter('backward')<cr>",
				{ desc = "Treesitter backward" }
			)
			vim.keymap.set(
				"n",
				"<leader>]t",
				"<Cmd>lua MiniBracketed.treesitter('forward')<cr>",
				{ desc = "Treesitter forward" }
			)
			vim.keymap.set(
				"n",
				"<leader>]T",
				"<Cmd>lua MiniBracketed.treesitter('last')<cr>",
				{ desc = "Treesitter last" }
			)
			vim.keymap.set("n", "<leader>[U", "<Cmd>lua MiniBracketed.undo('first')<cr>", { desc = "Undo first" })
			vim.keymap.set("n", "<leader>[u", "<Cmd>lua MiniBracketed.undo('backward')<cr>", { desc = "Undo backward" })
			vim.keymap.set("n", "<leader>]u", "<Cmd>lua MiniBracketed.undo('forward')<cr>", { desc = "Undo forward" })
			vim.keymap.set("n", "<leader>]U", "<Cmd>lua MiniBracketed.undo('last')<cr>", { desc = "Undo last" })
			vim.keymap.set("n", "<leader>wH", "<Cmd>lua MiniBracketed.window('first')<cr>", { desc = "Window first" })
			vim.keymap.set(
				"n",
				"<leader>wh",
				"<Cmd>lua MiniBracketed.window('backward')<cr>",
				{ desc = "Window backward" }
			)
			vim.keymap.set(
				"n",
				"<leader>wl",
				"<Cmd>lua MiniBracketed.window('forward')<cr>",
				{ desc = "Window forward" }
			)
			vim.keymap.set("n", "<leader>wL", "<Cmd>lua MiniBracketed.window('last')<cr>", { desc = "Window last" })
			vim.keymap.set("n", "<leader>[Y", "<Cmd>lua MiniBracketed.yank('first')<cr>", { desc = "Yank first" })
			vim.keymap.set("n", "<leader>[y", "<Cmd>lua MiniBracketed.yank('backward')<cr>", { desc = "Yank backward" })
			vim.keymap.set("n", "<leader>]y", "<Cmd>lua MiniBracketed.yank('forward')<cr>", { desc = "Yank forward" })
			vim.keymap.set("n", "<leader>]Y", "<Cmd>lua MiniBracketed.yank('last')<cr>", { desc = "Yank last" })
		end,
	},
}
