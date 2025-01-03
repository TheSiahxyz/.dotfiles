return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	cmd = "WhichKey",
	dependencies = { "echasnovski/mini.icons", "nvim-tree/nvim-web-devicons" },
	opts = {},
	config = function()
		local wk = require("which-key")
		wk.setup({
			---@type false | "classic" | "modern" | "helix"
			preset = "classic",
			-- Delay before showing the popup. Can be a number or a function that returns a number.
			---@type number | fun(ctx: { keys: string, mode: string, plugin?: string }):number
			delay = function(ctx)
				return ctx.plugin and 0 or 200
			end,
			---@param mapping wk.Mapping
			filter = function(mapping)
				-- example to exclude mappings without a description
				-- return mapping.desc and mapping.desc ~= ""
				return true
			end,
			--- You can add any mappings here, or use `require('which-key').add()` later
			---@type wk.Spec
			spec = {},
			-- show a warning when issues were detected with your mappings
			notify = true,
			-- Which-key automatically sets up triggers for your mappings.
			-- But you can disable this and setup the triggers manually.
			-- Check the docs for more info.
			---@type wk.Spec
			triggers = {
				{ "<auto>", mode = "nxso" },
			},
			-- Start hidden and wait for a key to be pressed before showing the popup
			-- Only used by enabled xo mapping modes.
			---@param ctx { mode: string, operator: string }
			defer = function(ctx)
				return ctx.mode == "V" or ctx.mode == "<C-V>"
			end,
			plugins = {
				marks = true, -- shows a list of your marks on ' and `
				registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
				-- the presets plugin, adds help for a bunch of default keybindings in Neovim
				-- No actual key bindings are created
				spelling = {
					enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
					suggestions = 20, -- how many suggestions should be shown in the list?
				},
				presets = {
					operators = true, -- adds help for operators like d, y, ...
					motions = true, -- adds help for motions
					text_objects = true, -- help for text objects triggered after entering an operator
					windows = true, -- default bindings on <c-w>
					nav = true, -- misc bindings to work with windows
					z = true, -- bindings for folds, spelling and others prefixed with z
					g = true, -- bindings for prefixed with g
				},
			},
			---@type wk.Win.opts
			win = {
				-- don't allow the popup to overlap with the cursor
				no_overlap = true,
				-- width = 1,
				-- height = { min = 4, max = 25 },
				-- col = 0,
				-- row = math.huge,
				-- border = "none",
				padding = { 1, 2 }, -- extra window padding [top/bottom, right/left]
				title = true,
				title_pos = "center",
				zindex = 1000,
				-- Additional vim.wo and vim.bo options
				bo = {},
				wo = {
					-- winblend = 10, -- value between 0-100 0 for fully opaque and 100 for fully transparent
				},
			},
			layout = {
				width = { min = 20 }, -- min and max width of the columns
				spacing = 3, -- spacing between columns
			},
			keys = {
				scroll_down = "<c-e>",
				scroll_up = "<c-y>",
			},
			---@type (string|wk.Sorter)[]
			--- Mappings are sorted using configured sorters and natural sort of the keys
			--- Available sorters:
			--- * local: buffer-local mappings first
			--- * order: order of the items (Used by plugins like marks / registers)
			--- * group: groups last
			--- * alphanum: alpha-numerical first
			--- * mod: special modifier keys last
			--- * manual: the order the mappings were added
			--- * case: lower-case first
			sort = { "local", "order", "group", "alphanum", "mod" },
			---@type number|fun(node: wk.Node):boolean?
			expand = 0, -- expand groups when <= n mappings
			-- expand = function(node)
			--   return not node.desc -- expand all nodes without a description
			-- end,
			-- Functions/Lua Patterns for formatting the labels
			---@type table<string, ({[1]:string, [2]:string}|fun(str:string):string)[]>
			replace = {
				key = {
					function(key)
						return require("which-key.view").format(key)
					end,
					-- { "<Space>", "SPC" },
				},
				desc = {
					{ "<Plug>%(?(.*)%)?", "%1" },
					{ "^%+", "" },
					{ "<[cC]md>", "" },
					{ "<[cC][rR]>", "" },
					{ "<[sS]ilent>", "" },
					{ "^lua%s+", "" },
					{ "^call%s+", "" },
					{ "^:%s*", "" },
				},
			},
			icons = {
				breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
				separator = "➜", -- symbol used between a key and it's label
				group = "+", -- symbol prepended to a group
				ellipsis = "…",
				-- set to false to disable all mapping icons,
				-- both those explicitly added in a mapping
				-- and those from rules
				mappings = true,
				--- See `lua/which-key/icons.lua` for more details
				--- Set to `false` to disable keymap icons from rules
				---@type wk.IconRule[]|false
				rules = {},
				-- use the highlights from mini.icons
				-- When `false`, it will use `WhichKeyIcon` instead
				colors = true,
				-- used by key format
				keys = {
					Up = " ",
					Down = " ",
					Left = " ",
					Right = " ",
					C = "󰘴 ",
					M = "󰘵 ",
					D = "󰘳 ",
					S = "󰘶 ",
					CR = "󰌑 ",
					Esc = "󱊷 ",
					ScrollWheelDown = "󱕐 ",
					ScrollWheelUp = "󱕑 ",
					NL = "󰌑 ",
					BS = "󰁮",
					Space = "󱁐 ",
					Tab = "󰌒 ",
					F1 = "󱊫",
					F2 = "󱊬",
					F3 = "󱊭",
					F4 = "󱊮",
					F5 = "󱊯",
					F6 = "󱊰",
					F7 = "󱊱",
					F8 = "󱊲",
					F9 = "󱊳",
					F10 = "󱊴",
					F11 = "󱊵",
					F12 = "󱊶",
				},
			},
			show_help = true, -- show a help message in the command line for using WhichKey
			show_keys = true, -- show the currently pressed key and its label as a message in the command line
			-- disable WhichKey for certain buf types and file types.
			disable = {
				ft = {},
				bt = {},
			},
			debug = false, -- enable wk.log in the current directory
		})

		wk.add({
			{
				mode = { "n", "v" },
				{ "g", group = "Goto" },
				{ "g`", group = "Marks" },
				{ "g'", group = "Marks" },
				{ "gs", group = "Search/Surround" },
				{ "s", group = "Surround/Search & replace on line" },
				{ "S", group = "Surround/Search & replace in file" },
				{ "z", group = "Fold" },
				{ "`", group = "Marks" },
				{ "'", group = "Marks" },
				{ '"', group = "Registers" },
				{ "]", group = "Next" },
				{ "]]", group = "Next" },
				{ "[", group = "Prev" },
				{ "[[", group = "Prev" },
				{ "=", group = "Line paste" },
				{ "gx", desc = "Open with system app" },
				{ "<C-w>", group = "Windows" },
				{ "<leader>", group = "Leader" },
				{ "<leader>a", group = "Ascii" },
				{
					"<leader>b",
					group = "Buffer",
					expand = function()
						return require("which-key.extras").expand.buf()
					end,
				},
				{ "<leader>B", group = "Buffer (force)" },
				{ "<leader>C", group = "Goto realpath" },
				{ "<leader>d", group = "Delete" },
				{ "<leader>D", group = "Delete (blackhole)" },
				{ "<leader>e", group = "Explorer" },
				{ "<leader>i", group = "Inspect" },
				{ "<leader>l", group = "Location" },
				{ "<leader>L", group = "Lazy" },
				{ "<leader>M", group = "Mason" },
				{ "<leader>o", group = "Open" },
				{ "<leader>p", group = "Paste" },
				{ "<leader>P", group = "Paste" },
				{ "<leader>q", group = "Quit" },
				{ "<leader>sk", group = "Keys" },
				{ "<leader>S", group = "Save/Source" },
				{ "<leader>T", group = "TODO" },
				{ "<leader>w", group = "Which-key" },
				{ "<leader>W", group = "Save all" },
				{ "<leader><tab>", group = "Tabs" },
				{ "<localleader>", group = "Local Leader (bookmarks)" },
				{ "<localleader><leader>", group = "Bookmarks (explorer)" },
				{ "<localleader><localleader>", group = "Bookmarks (mini)" },
				{ "<localleader>t", group = "Task" },
			},
			{
				mode = { "n", "v", "x" },
				{ "gw", desc = "Visible in window" },
				{ "g%", desc = "Match backward" },
				{ "g;", desc = "Last change" },
				{ "<leader>Q", group = "Quit all" },
			},
		})
	end,
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer local keymaps (which-key)",
		},
		{
			"<leader>wk",
			function()
				vim.cmd("WhichKey " .. vim.fn.input("WhichKey: "))
			end,
			desc = "Which-key query lookup",
		},
		{
			mode = { "n", "v", "x" },
			"<leader>wK",
			"<cmd>WhichKey<CR>",
			desc = "Which-key all key",
		},
	},
}
