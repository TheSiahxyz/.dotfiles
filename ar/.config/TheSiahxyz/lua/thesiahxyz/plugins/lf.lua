return {
	"lmburns/lf.nvim",
	dependencies = {
		{
			"akinsho/toggleterm.nvim",
			version = "*",
			config = function()
				require("toggleterm").setup({
					open_mapping = [[<leader><c-s>]], -- or { [[<c-\>]], [[<c-¥>]] } if you also use a Japanese keyboard.
				})
				vim.keymap.set(
					"n",
					"<leader><C-\\>",
					"<cmd>ToggleTerm direction=float name=Terminal<cr>",
					{ desc = "Toggle float terminal" }
				)
				vim.keymap.set(
					"n",
					"<leader><C-t>",
					"<cmd>ToggleTermToggleAll<cr>",
					{ desc = "Toggle all float terminals" }
				)
				vim.keymap.set("n", "<leader><C-u>", "<cmd>TermSelect<cr>", { desc = "Select float terminal" })

				local function set_opfunc(opfunc)
					_G._opfunc = opfunc -- Define the function globally
					vim.go.operatorfunc = "v:lua._opfunc" -- Assign the global function
				end

				local trim_spaces = false
				vim.keymap.set("v", "<leader><C-l>", function()
					require("toggleterm").send_lines_to_terminal("single_line", trim_spaces, { args = vim.v.count })
				end, { desc = "Send line to terminal" })
				-- Replace with these for the other two options
				-- require("toggleterm").send_lines_to_terminal("visual_lines", trim_spaces, { args = vim.v.count })
				-- require("toggleterm").send_lines_to_terminal("visual_selection", trim_spaces, { args = vim.v.count })

				-- For use as an operator map:
				-- Send motion to terminal
				vim.keymap.set("n", "<leader><C-l>", function()
					set_opfunc(function(motion_type)
						require("toggleterm").send_lines_to_terminal(motion_type, false, { args = vim.v.count })
					end)
					vim.api.nvim_feedkeys("g@", "n", false)
				end, { desc = "Send motions to terminal" })
				-- Double the command to send line to terminal
				vim.keymap.set("n", "<leader><C-a>", function()
					set_opfunc(function(motion_type)
						require("toggleterm").send_lines_to_terminal(motion_type, false, { args = vim.v.count })
					end)
					vim.api.nvim_feedkeys("g@_", "n", false)
				end, { desc = "Send double command to terminal" })
				-- Send whole file
				vim.keymap.set("n", "<leader><C-g>", function()
					set_opfunc(function(motion_type)
						require("toggleterm").send_lines_to_terminal(motion_type, false, { args = vim.v.count })
					end)
					vim.api.nvim_feedkeys("ggg@G''", "n", false)
				end, { desc = "Send whole file to terminal (clipboard)" })
			end,
		},
	},
	config = function()
		vim.g.lf_netrw = 1
		local fn = vim.fn

		-- Defaults
		require("lf").setup({
			default_action = "drop", -- Default action when `Lf` opens a file
			default_actions = {
				["e"] = "tabedit",
				["<C-t>"] = "tab drop",
				["<C-v>"] = "vsplit",
				["<C-x>"] = "split",
			},
			winblend = 0, -- Pseudotransparency level
			direction = "float", -- Window type
			border = "rounded", -- Border kind
			height = fn.float2nr(fn.round(0.75 * vim.o.lines)), -- Height of the *floating* window
			width = fn.float2nr(fn.round(0.75 * vim.o.columns)), -- Width of the *floating* window
			escape_quit = true, -- Map escape to the quit command
			focus_on_open = true, -- Focus the current file when opening Lf
			mappings = true, -- Enable terminal buffer mapping
			tmux = true, -- Tmux statusline can be disabled
			disable_netrw_warning = true, -- Don't display a message when opening a directory
			highlights = {
				Normal = { link = "Normal" }, -- Use normal highlighting
				NormalFloat = { link = "NormalFloat" }, -- Use float highlighting
				FloatBorder = { link = "@constant" }, -- Use constant highlighting
			},

			-- Layout configurations
			layout_mapping = "<M-r>", -- Resize window with this key
			views = {
				{ width = 0.800, height = 0.800 },
				{ width = 0.600, height = 0.600 },
				{ width = 0.950, height = 0.950 },
				{ width = 0.500, height = 0.500, col = 0, row = 0 },
				{ width = 0.500, height = 0.500, col = 0, row = 0.5 },
				{ width = 0.500, height = 0.500, col = 0.5, row = 0 },
				{ width = 0.500, height = 0.500, col = 0.5, row = 0.5 },
			},
		})

		vim.keymap.set("n", "<leader>el", "<Cmd>Lf<CR>")

		-- Autocommand to set key mapping in terminal buffer
		vim.api.nvim_create_autocmd("User", {
			pattern = "LfTermEnter",
			callback = function(a)
				vim.api.nvim_buf_set_keymap(
					a.buf,
					"t",
					"q",
					"<cmd>q<CR>",
					{ nowait = true, noremap = true, silent = true }
				)
			end,
		})
	end,
}
