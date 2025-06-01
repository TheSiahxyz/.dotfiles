-- Select the current cell
local function select_cell()
	local bufnr = vim.api.nvim_get_current_buf()
	local current_row = vim.api.nvim_win_get_cursor(0)[1]
	local current_col = vim.api.nvim_win_get_cursor(0)[2]

	local start_line = nil
	local end_line = nil
	local line_count = vim.api.nvim_buf_line_count(bufnr)

	-- Find the start of the cell (looking for opening markers or headers)
	for line = current_row, 1, -1 do
		local line_content = vim.api.nvim_buf_get_lines(bufnr, line - 1, line, false)[1]
		if line_content:match("^```%s*[%w_%-]+") or line_content:match("^%s*#+%s") then
			start_line = line
			break
		end
	end

	-- If no start line is found, assume start of the file
	if not start_line then
		start_line = 1
	end

	-- Find the end of the cell (looking for the next opening marker or header)
	for line = start_line + 1, line_count do
		local line_content = vim.api.nvim_buf_get_lines(bufnr, line - 1, line, false)[1]
		if line_content:match("^```%s*[%w_%-]+") or line_content:match("^%s*#+%s") then
			end_line = line - 1
			break
		end
	end

	-- If no end line is found, assume end of the file
	if not end_line then
		end_line = line_count
	end

	return current_row, current_col, start_line, end_line
end

-- Delete the current cell
local function delete_cell()
	local _, _, start_line, end_line = select_cell() -- Use select_cell to get start and end lines of the cell
	if start_line and end_line then
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
	local line_count = vim.api.nvim_buf_line_count(bufnr)
	local _, _, start_line, end_line = select_cell() -- Get the start and end lines of the current cell

	local target_line = nil

	if up then
		-- Find the previous cell start, skipping any closing markers
		for line = start_line - 1, 1, -1 do
			local line_content = vim.api.nvim_buf_get_lines(bufnr, line - 1, line, false)[1]
			if line_content:match("^```%s*[%w_%-]+") or line_content:match("^%s*#+%s") then
				target_line = line
				break
			end
		end
	else
		-- Find the next cell start, skipping any closing markers
		for line = end_line + 1, line_count do
			local line_content = vim.api.nvim_buf_get_lines(bufnr, line - 1, line, false)[1]
			if line_content:match("^```%s*[%w_%-]+") or line_content:match("^%s*#+%s") then
				target_line = line
				break
			end
		end
	end

	-- Navigate to the target line if found, otherwise stay at the current position
	if target_line then
		-- If the target is a code block, move cursor to the line right after the opening marker
		local target_line_content = vim.api.nvim_buf_get_lines(bufnr, target_line - 1, target_line, false)[1]
		if target_line_content:match("^```%s*[%w_%-]+") then
			vim.api.nvim_win_set_cursor(0, { target_line + 1, 0 }) -- Move inside the code block
		else
			vim.api.nvim_win_set_cursor(0, { target_line, 0 }) -- Move to the markdown header line
		end
	else
		if up then
			vim.api.nvim_win_set_cursor(0, { 1, 0 }) -- Move to start of file if no previous cell found
		else
			vim.api.nvim_win_set_cursor(0, { line_count, 0 }) -- Move to end of file if no next cell found
		end
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
	vim.cmd("normal!2o")
	vim.cmd("normal!k")
end

-- Insert a new code cell
local function insert_code_cell()
	insert_cell("```python") -- For regular code cells
end

return {
	-- {
	-- 	"ixru/nvim-markdown",
	-- 	config = function()
	-- 		vim.g.vim_markdown_no_default_key_mappings = 1
	-- 	end,
	-- },
	{
		"meanderingprogrammer/render-markdown.nvim",
		enabled = true,
		-- dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
		dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" }, -- if you use standalone mini plugins
		-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
		---@module 'render-markdown'
		---@type render.md.UserConfig
		opts = {},
		config = function()
			local filename = vim.api.nvim_buf_get_name(0)
			local is_ipynb = filename:sub(-6) == ".ipynb"

			-- require("obsidian").get_client().opts.ui.enable = false
			-- vim.api.nvim_buf_clear_namespace(0, vim.api.nvim_get_namespaces()["ObsidianUI"], 0, -1)
			require("render-markdown").setup({
				bullet = {
					-- Turn on / off list bullet rendering
					enabled = true,
				},
				code = {
					enabled = not is_ipynb, -- disable code rendering for .ipynb files
					sign = not is_ipynb,
				},
				heading = {
					sign = false,
					icons = { "󰎤 ", "󰎧 ", "󰎪 ", "󰎭 ", "󰎱 ", "󰎳 " },
				},
				file_types = { "markdown", "vimwiki" },
			})
			vim.treesitter.language.register("markdown", "vimwiki")
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
			local wk = require("which-key")
			wk.add({
				mode = { "n", "v" },
				{ "<leader>m", group = "Markdown/Map" },
			})
		end,
		keys = {
			{ "<leader>mp", "<cmd>MarkdownPreview<CR>", desc = "Markdown preview" },
			{ "<leader>mx", "<cmd>MarkdownPreviewStop<CR>", desc = "Markdown stop" },
			{ "<leader>md", "<cmd>MarkdownPreviewToggle<CR>", desc = "Markdown toggle" },
		},
	},
	{
		"brianhuster/live-preview.nvim",
		dependencies = {
			-- You can choose one of the following pickers
			"nvim-telescope/telescope.nvim",
			-- "ibhagwan/fzf-lua",
			-- "echasnovski/mini.pick",
		},
		cmd = { "LivePreview start", "LivePreview close", "LivePreview pick", "LivePreview help" },
		init = function()
			if vim.fn.executable("npx") then
				vim.g.mkdp_filetypes = { "markdown" }
			end
			local wk = require("which-key")
			wk.add({
				mode = { "n", "v" },
				{ "<leader>ml", group = "Markdown live" },
			})
		end,
		keys = {
			{ "<leader>mlp", "<cmd>LivePreview start<CR>", desc = "Markdown live preview" },
			{ "<leader>mlx", "<cmd>LivePreview close<CR>", desc = "Markdown live close" },
			{ "<leader>mlc", "<cmd>LivePreview pick<CR>", desc = "Markdown live pick" },
			{ "<leader>mlh", "<cmd>LivePreview help<CR>", desc = "Markdown live help" },
		},
	},
	{
		"dhruvasagar/vim-open-url",
		init = function()
			local wk = require("which-key")
			wk.add({
				mode = { "n", "v" },
				{ "g<CR>", group = "Search word under curosr" },
				{ "gB", group = "Open url in browser" },
				{ "gG", group = "Google search word under cursor" },
				{ "gW", group = "Wikipedia search word under cursor" },
			})
		end,
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
		end,
		keys = {
			{ "<A-i>", insert_code_cell, desc = "Insert Code Cell" },
			{ "<A-x>", delete_cell, desc = "Delete Cell" },
			{
				"<S-Tab>",
				function()
					navigate_cell(true)
				end,
				desc = "Previous Cell",
			},
			{ "<Tab>", navigate_cell, desc = "Next Cell" },
		},
	},
	{
		"vhyrro/luarocks.nvim",
		priority = 1001, -- this plugin needs to run before anything else
		init = function()
			package.path = package.path
				.. ";"
				.. vim.fn.expand("$HOME")
				.. "/.config/luarocks/share/lua/5.1/magick/init.lua;"
		end,
		opt = {
			rocks = { "magick" },
		},
	},
	{ "benlubas/image-save.nvim", cmd = "SaveImage" },
	{
		"3rd/image.nvim",
		dependencies = { "leafo/magick", "vhyrro/luarocks.nvim" },
		config = function()
			require("image").setup({
				backend = "ueberzug", -- or "kitty", whatever backend you would like to use
				processor = "magick_rock", -- or "magick_cli"
				integrations = {
					markdown = {
						enabled = true,
						clear_in_insert_mode = false,
						download_remote_images = false,
						only_render_image_at_cursor = false,
						floating_windows = false, -- if true, images will be rendered in floating markdown windows
						filetypes = { "markdown", "quarto" }, -- markdown extensions (ie. quarto) can go here
					},
					neorg = {
						enabled = true,
						filetypes = { "norg" },
					},
					typst = {
						enabled = true,
						filetypes = { "typst" },
					},
					html = {
						enabled = false,
					},
					css = {
						enabled = false,
					},
				},
				max_width = 100,
				max_height = 8,
				max_height_window_percentage = math.huge,
				max_width_window_percentage = math.huge,
				window_overlap_clear_enabled = true, -- toggles images when windows are overlapped
				window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "fidget", "" },
				editor_only_render_when_focused = true, -- auto show/hide images when the editor gains/looses focus
				tmux_show_only_in_active_window = true, -- auto show/hide images in the correct Tmux window (needs visual-activity off)
				hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" }, -- render image files as images when opened
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
				debug = false,
				closePreviewOnExit = true,
				lspFeatures = {
					languages = { "r", "python", "rust" },
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
			vim.keymap.set("n", "<leader>ja", runner.run_all, { silent = true, desc = "Run all" })
			vim.keymap.set("n", "<leader>jA", function()
				runner.run_all(true)
			end, { desc = "run all cells of all languages", silent = true })
			vim.keymap.set(
				"n",
				"<leader>jp",
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
			vim.g.molten_auto_open_output = false
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

			local wk = require("which-key")
			wk.add({
				mode = { "n", "v", "x" },
				{ "<leader>j", group = "Molten (Jupyter)" },
			})
		end,
		config = function()
			-- image nvim options table. Pass to `require('image').setup`
			vim.keymap.set("n", "<leader>jJ", ":MoltenInit<CR>", { silent = true, desc = "Init molten" })
			vim.keymap.set("n", "<leader>j[", ":MoltenNext<CR>", { silent = true, desc = "Go to next code cell" })
			vim.keymap.set("n", "<leader>j]", ":MoltenPrev<CR>", { silent = true, desc = "Go to prev code cell" })
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
			vim.keymap.set("n", "<leader>js", ":MoltenShowOutput<CR>", { silent = true, desc = "Show output" })
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
				local venv_path = os.getenv("VIRTUAL_ENV")
				if venv_path then
					local venv_name = vim.fn.fnamemodify(venv_path, ":t")
					vim.cmd(("MoltenInit %s"):format(venv_name))
				else
					vim.cmd("MoltenInit python3")
				end
			end, { desc = "Init default molten" })
		end,
	},
	{
		"mipmip/vim-scimark",
		config = function()
			vim.keymap.set("n", "<leader>si", ":OpenInScim<cr>", { desc = "Sc-im" })
		end,
	},
}
