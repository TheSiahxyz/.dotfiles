-- Configuration for handling markdown format with Jupytext in Neovim

local CELL_MARKER_COLOR = "#999999"
local CELL_MARKER = "^```"
local CELL_MARKER_SIGN = "cell_marker_sign"

-- Set highlight for cell markers
vim.api.nvim_set_hl(0, "cell_marker_hl", { bg = CELL_MARKER_COLOR })
vim.fn.sign_define(CELL_MARKER_SIGN, { linehl = "cell_marker_hl" })

-- Highlight a cell marker in the buffer
local function highlight_cell_marker(bufnr, line)
	local sign_name = CELL_MARKER_SIGN
	local sign_text = "%%"
	vim.fn.sign_place(line, CELL_MARKER_SIGN, sign_name, bufnr, {
		lnum = line,
		priority = 10,
		text = sign_text,
	})
end

-- Show all cell markers in the current buffer
local function show_cell_markers()
	local bufnr = vim.api.nvim_get_current_buf()
	vim.fn.sign_unplace(CELL_MARKER_SIGN, { buffer = bufnr })
	local total_lines = vim.api.nvim_buf_line_count(bufnr)
	for line = 1, total_lines do
		local line_content = vim.api.nvim_buf_get_lines(bufnr, line - 1, line, false)[1]
		if line_content ~= "" and line_content:find(CELL_MARKER) then
			highlight_cell_marker(bufnr, line)
		end
	end
end

-- Check and show a specific cell marker based on cursor position
local function check_and_show_cell_marker()
	local bufnr = vim.api.nvim_get_current_buf()
	local line = vim.api.nvim_win_get_cursor(0)[1]
	local line_content = vim.api.nvim_buf_get_lines(bufnr, line - 1, line, false)[1]
	if line_content ~= "" and line_content:find(CELL_MARKER) then
		highlight_cell_marker(bufnr, line)
	else
		vim.fn.sign_unplace(CELL_MARKER_SIGN, { buffer = bufnr, id = line })
	end
end

-- Select the current cell
local function select_cell()
	local bufnr = vim.api.nvim_get_current_buf()
	local current_row = vim.api.nvim_win_get_cursor(0)[1]
	local current_col = vim.api.nvim_win_get_cursor(0)[2]

	local start_line = nil
	local end_line = nil
	local line_count = vim.api.nvim_buf_line_count(bufnr)

	-- Find the start of the cell
	for line = current_row, 1, -1 do
		local line_content = vim.api.nvim_buf_get_lines(bufnr, line - 1, line, false)[1]
		if line_content:match("^```%s*[%w_%-]*") or line_content:match("^%s*#+%s") then
			start_line = line
			break
		end
	end

	-- If no start line is found, assume start of the file
	if not start_line then
		start_line = 1
	else
		-- Include the previous empty line if it exists
		if start_line > 1 then
			local prev_line_content = vim.api.nvim_buf_get_lines(bufnr, start_line - 2, start_line - 1, false)[1]
			if prev_line_content:match("^%s*$") then
				start_line = start_line - 1
			end
		end
	end

	-- Find the end of the cell
	for line = start_line + 1, line_count do
		local line_content = vim.api.nvim_buf_get_lines(bufnr, line - 1, line, false)[1]
		if line_content:match("^```%s*$") then -- Match the closing marker of a code block
			end_line = line
			break
		elseif line_content:match("^%s*#+%s") and line > start_line then -- Match the next markdown header
			end_line = line - 1
			break
		end
	end

	-- If no end line is found, assume end of the file
	if not end_line then
		end_line = line_count
	else
		-- Only include the next empty line if there was no previous empty line included
		if end_line < line_count then
			local next_line_content = vim.api.nvim_buf_get_lines(bufnr, end_line, end_line + 1, false)[1]
			if next_line_content:match("^%s*$") and not (start_line < current_row and current_row < end_line) then
				end_line = end_line + 1
			end
		end
	end

	return current_row, current_col, start_line, end_line
end

-- Delete the current cell
local function delete_cell()
	local _, _, start_line, end_line = select_cell() -- Use select_cell to get start and end lines of the cell
	if start_line and end_line then
		local bufnr = vim.api.nvim_get_current_buf()
		-- Move cursor to the start of the cell
		vim.api.nvim_win_set_cursor(0, { start_line, 0 })

		-- Enter visual line mode to select the cell
		vim.cmd("normal! V")
		-- Move cursor to the end of the cell to extend selection
		vim.api.nvim_win_set_cursor(0, { end_line, 0 })

		-- Delete the selected lines
		vim.cmd("normal! d")
	end
end

-- Navigate to the next or previous cell
local function navigate_cell(up)
	local bufnr = vim.api.nvim_get_current_buf()
	local current_row = vim.api.nvim_win_get_cursor(0)[1]
	local line_count = vim.api.nvim_buf_line_count(bufnr)
	local step = up and -1 or 1
	local found = false

	-- Function to check if a line is a code block start or a markdown header
	local function is_cell_marker(line_content)
		-- Match code block start (e.g., ```python, ```javascript, etc.)
		if line_content:match("^```%s*[%w_%-]+") then
			return true
		end
		-- Match Markdown headers (#, ##, ###, etc.)
		if line_content:match("^%s*#+%s") then
			return true
		end
		return false
	end

	-- Start searching from the current line and move in the specified direction
	for line = current_row + step, (up and 1 or line_count), step do
		local line_content = vim.api.nvim_buf_get_lines(bufnr, line - 1, line, false)[1]
		if is_cell_marker(line_content) then
			vim.api.nvim_win_set_cursor(0, { line, 0 })
			found = true
			break
		end
	end

	-- If no block is found, go to the end or start of the file depending on direction
	if not found and not up then
		vim.api.nvim_win_set_cursor(0, { line_count, 0 })
	elseif not found and up then
		vim.api.nvim_win_set_cursor(0, { 1, 0 })
	end
end

-- Insert a new cell with specific content
local function insert_cell(content)
	local _, _, _, end_line = select_cell()
	local bufnr = vim.api.nvim_get_current_buf()
	local line = end_line
	if end_line ~= 1 then
		line = end_line - 1
		vim.api.nvim_win_set_cursor(0, { end_line - 1, 0 })
	else
		line = end_line
		vim.api.nvim_win_set_cursor(0, { end_line, 0 })
	end

	vim.cmd("normal!2o")
	vim.api.nvim_buf_set_lines(bufnr, line, line + 1, false, { content })
	local current_line = vim.api.nvim_win_get_cursor(0)[1]
	highlight_cell_marker(bufnr, current_line - 1)
	vim.cmd("normal!2o")
	vim.cmd("normal!k")
end

-- Insert a new code cell
local function insert_code_cell()
	insert_cell("```python") -- For regular code cells
end

return {
	{
		"ixru/nvim-markdown",
		config = function()
			vim.g.vim_markdown_no_default_key_mappings = 1
		end,
	},
	{
		-- Install markdown preview, use npx if available.
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		build = function(plugin)
			if vim.fn.executable("npx") then
				vim.cmd("!cd " .. plugin.dir .. " && cd app && npx --yes yarn install")
			else
				vim.cmd([[Lazy load markdown-preview.nvim]])
				vim.fn["mkdp#util#install"]()
			end
		end,
		init = function()
			if vim.fn.executable("npx") then
				vim.g.mkdp_filetypes = { "markdown" }
			end
		end,
	},
	{
		"dhruvasagar/vim-open-url",
	},
	{
		"AckslD/nvim-FeMaco.lua",
		config = function()
			require("femaco").setup()
		end,
	},
	{
		"goerz/jupytext.vim",
		lazy = false,
		build = "pip install jupytext",
		dependencies = { "neovim/nvim-lspconfig" },
		config = function()
			-- The destination format: 'ipynb', 'markdown' or 'script', or a file extension: 'md', 'Rmd', 'jl', 'py', 'R', ..., 'auto' (script
			-- extension matching the notebook language), or a combination of an extension and a format name, e.g. md:markdown, md:pandoc,
			-- md:myst or py:percent, py:light, py:nomarker, py:hydrogen, py:sphinx. The default format for scripts is the 'light' format,
			-- which uses few cell markers (none when possible). Alternatively, a format compatible with many editors is the 'percent' format,
			-- which uses '# %%' as cell markers. The main formats (markdown, light, percent) preserve notebooks and text documents in a
			-- roundtrip. Use the --test and and --test-strict commands to test the roundtrip on your files. Read more about the available
			-- formats at https://jupytext.readthedocs.io/en/latest/formats.html (default: None)
			vim.g.jupytext_fmt = "markdown"

			-- Autocommand group to ensure no duplication
			vim.api.nvim_create_augroup("CellMarkerHighlighting", { clear = true })

			-- Autocommand to show cell markers when reading, entering, or editing a buffer
			vim.api.nvim_create_autocmd({ "BufReadPost", "BufWinEnter", "TextChanged", "TextChangedI" }, {
				group = "CellMarkerHighlighting",
				pattern = "*.py,*.ipynb,*.md,*.r,*.jl,*.scala", -- Adjust your file patterns as needed
				callback = function()
					vim.schedule(show_cell_markers)
				end,
			})

			-- Autocommand to check and show a specific cell marker when cursor is idle
			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				group = "CellMarkerHighlighting",
				pattern = "*.py,*.ipynb,*.md,*.r,*.jl,*.scala", -- Adjust your file patterns as needed
				callback = function()
					vim.schedule(check_and_show_cell_marker)
				end,
			})
		end,
		keys = {
			{ "<A-i>", insert_code_cell, desc = "Insert Code Cell" },
			{ "<A-x>", delete_cell, desc = "Delete Cell" },
			{ "<A-=>", navigate_cell, desc = "Next Cell" },
			{
				"<A-->",
				function()
					navigate_cell(true)
				end,
				desc = "Previous Cell",
			},
		},
	},
	{
		"vhyrro/luarocks.nvim",
		priority = 1001, -- this plugin needs to run before anything else
		opts = {
			rocks = { "magick" },
		},
	},
	{ "benlubas/image-save.nvim", dev = true, cmd = "SaveImage" },
	{
		"3rd/image.nvim",
		dependencies = { "leafo/magick" },
		config = function()
			require("image").setup({
				backend = "ueberzug", -- whatever backend you would like to use
				integrations = {
					markdown = {
						enabled = true,
						clear_in_insert_mode = false,
						download_remote_images = false,
						only_render_image_at_cursor = false,
						filetypes = { "markdown", "quarto" }, -- markdown extensions (ie. quarto) can go here
					},
					neorg = {
						enabled = true,
						clear_in_insert_mode = false,
						download_remote_images = false,
						only_render_image_at_cursor = false,
						filetypes = { "norg" },
					},
				},
				max_width = 100,
				max_height = 8,
				max_height_window_percentage = math.huge,
				max_width_window_percentage = math.huge,
				window_overlap_clear_enabled = true, -- toggles images when windows are overlapped
				editor_only_render_when_focused = true, -- auto show/hide images when the editor gains/looses focus
				tmux_show_only_in_active_window = true, -- auto show/hide images in the correct Tmux window (needs visual-activity off)
				window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "fidget", "" },
			})
		end,
	},
	{
		"quarto-dev/quarto-nvim",
		dependencies = {
			{
				"jmbuhr/otter.nvim",
				lazy = false,
				dependencies = {
					"nvim-treesitter/nvim-treesitter",
				},
				opts = {},
				config = function()
					require("otter").setup()
				end,
			},
			"nvim-cmp",
			"neovim/nvim-lspconfig",
			"nvim-treesitter/nvim-treesitter",
			"otter.nvim",
		},
		ft = { "quarto", "markdown" },
		command = "QuartoActivate",
		config = function()
			require("quarto").setup({
				lspFeatures = {
					languages = { "r", "python", "rust", "lua" },
					chunks = "all",
					diagnostics = {
						enabled = true,
						triggers = { "BufWritePost" },
					},
					completion = {
						enabled = true,
					},
				},
				keymap = {
					hover = "H",
					definition = "gd",
					rename = "<leader>rn",
					references = "gr",
					format = "<leader>gf",
				},
				codeRunner = {
					enabled = true,
					default_method = "molten",
					ft_runners = {
						bash = "slime",
						python = "molten",
					},
					never_run = { "yaml" }, -- filetypes which are never sent to a code runner
				},
			})
			local runner = require("quarto.runner")
			vim.keymap.set("n", "<leader>jc", runner.run_cell, { silent = true, desc = "Run cell" })
			vim.keymap.set("n", "<leader>jC", runner.run_above, { silent = true, desc = "Run above cell" })
			vim.keymap.set("n", "<leader>jl", runner.run_line, { silent = true, desc = "Run line" })
			vim.keymap.set("v", "<leader>jv", runner.run_range, { silent = true, desc = "Run block" })
			vim.keymap.set("n", "<leader>jA", runner.run_all, { silent = true, desc = "Run all" })
			vim.keymap.set(
				"n",
				"<leader>qp",
				require("quarto").quartoPreview,
				{ noremap = true, silent = true, desc = "Preview the quarto document" }
			)
			-- to create a cell in insert mode, I have the ` snippet
			vim.keymap.set(
				"n",
				"<leader>cc",
				"i```python\n```<Esc>O",
				{ silent = true, desc = "Create a new code cell" }
			)
			vim.keymap.set(
				"n",
				"<leader>cs",
				"i```\r\r```{}<left>",
				{ noremap = true, silent = true, desc = "Split code cell" }
			)
		end,
	},
	{
		"benlubas/molten-nvim",
		version = "^1.0.0", -- use version <2.0.0 to avoid breaking changes
		dependencies = { "3rd/image.nvim" },
		build = ":UpdateRemotePlugins",
		init = function()
			vim.g.molten_auto_image_popup = true
			vim.g.molten_auto_init_behavior = "raise"
			vim.g.molten_auto_open_html_in_browser = false
			-- I find auto open annoying, keep in mind setting this option will require setting
			-- a keybind for `:noautocmd MoltenEnterOutput` to open the output again
			vim.g.molten_auto_open_output = true
			vim.g.molten_cover_empty_lines = false
			vim.g.molten_cover_lines_starting_with = {}
			vim.g.molten_copy_output = false
			vim.g.molten_enter_output_behavior = "open_then_enter"
			-- this guide will be using image.nvim
			-- Don't forget to setup and install the plugin if you want to view image outputs
			vim.g.molten_image_provider = "image.nvim"
			vim.g.molten_output_show_more = false
			vim.g.molten_output_win_max_height = 30
			vim.g.molten_output_win_style = "minimal"
			-- this will make it so the output shows up below the \`\`\` cell delimiter
			vim.g.molten_virt_lines_off_by_1 = true
			-- Output as virtual text. Allows outputs to always be shown, works with images, but can
			-- be buggy with longer images
			vim.g.molten_virt_text_output = true
			-- optional, works for virt text and the output window
			vim.g.molten_wrap_output = true
			vim.g.molten_virt_text_max_lines = 20
		end,
		config = function()
			-- image nvim options table. Pass to `require('image').setup`
			vim.keymap.set("n", "<leader>jJ", ":MoltenInit<CR>", { silent = true, desc = "Init molten" })
			vim.keymap.set(
				"n",
				"<leader>jo",
				":MoltenEvaluateOperator<CR>",
				{ silent = true, desc = "Evaluate operator" }
			)
			vim.keymap.set("n", "<leader>jL", ":MoltenEvaluateLine<CR>", { silent = true, desc = "Evaluate line" })
			vim.keymap.set("n", "<leader>jr", ":MoltenReevaluateCell<CR>", { silent = true, desc = "Re-evaluate cell" })
			vim.keymap.set(
				"v",
				"<leader>jV",
				":<C-u>MoltenEvaluateVisual<CR>gv<Esc>",
				{ silent = true, desc = "Evaluate visual block" }
			)
			vim.keymap.set("n", "<leader>jd", ":MoltenDelete<CR>", { silent = true, desc = "Delete molten" })
			vim.keymap.set("n", "<leader>jh", ":MoltenHideOutput<CR>", { silent = true, desc = "Hide output" })
			vim.keymap.set(
				"n",
				"<leader>jm",
				":noautocmd MoltenEnterOutput<CR>",
				{ silent = true, desc = "Enter output" }
			)
			vim.api.nvim_create_autocmd("User", {
				pattern = "MoltenInitPost",
				callback = function()
					require("quarto").activate()
				end,
			})
			vim.keymap.set("n", "<leader>ji", ":MoltenImagePopup<CR>", { silent = true, desc = "Pop-up image" })
			vim.keymap.set("n", "<leader>jw", ":MoltenOpenInBrowser<CR>", { silent = true, desc = "Open in browser" })
			vim.keymap.set("n", "<leader>jj", function()
				local venv = os.getenv("VIRTUAL_ENV")
				if venv ~= nil then
					-- in the form of /home/benlubas/.virtualenvs/VENV_NAME
					venv = string.match(venv, "/.+/(.+)")
					vim.cmd(("MoltenInit %s"):format(venv))
				else
					vim.cmd("MoltenInit python3")
				end
			end, { desc = "Init default molten" })
		end,
	},
}