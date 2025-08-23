-- Updated pattern to match what Echasnovski has in the documentation
-- https://github.com/echasnovski/mini.nvim/blob/c6eede272cfdb9b804e40dc43bb9bff53f38ed8a/doc/mini-files.txt#L508-L529

-- Define a function to update MiniJump highlight based on Search
local function update_mini_jump_highlight()
	local search_hl = vim.api.nvim_get_hl(0, { name = "Search" })
	vim.api.nvim_set_hl(0, "MiniJump", {
		fg = search_hl.fg,
		bg = search_hl.bg,
		bold = search_hl.bold or false,
	})
end

return {
	{
		"echasnovski/mini.ai",
		version = false,
		config = function()
			require("mini.ai").setup({
				-- Table with textobject id as fields, textobject specification as values.
				-- Also use this to disable builtin textobjects. See |MiniAi.config|.
				custom_textobjects = nil,

				-- Module mappings. Use `''` (empty string) to disable one.
				mappings = {
					-- Main textobject prefixes
					around = "a",
					inside = "i",

					-- Next/last variants
					around_next = "an",
					inside_next = "in",
					around_last = "al",
					inside_last = "il",

					-- Move cursor to corresponding edge of `a` textobject
					goto_left = "g[",
					goto_right = "g]",
				},

				-- Number of lines within which textobject is searched
				n_lines = 50,

				-- How to search for object (first inside current line, then inside
				-- neighborhood). One of 'cover', 'cover_or_next', 'cover_or_prev',
				-- 'cover_or_nearest', 'next', 'previous', 'nearest'.
				search_method = "cover_or_next",

				-- Whether to disable showing non-error feedback
				-- This also affects (purely informational) helper messages shown after
				-- idle time if user input is required.
				silent = false,
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
			vim.keymap.set("n", "<leader>w0", "<Cmd>lua MiniBracketed.window('first')<cr>", { desc = "Window first" })
			vim.keymap.set(
				"n",
				"<leader>w[",
				"<Cmd>lua MiniBracketed.window('backward')<cr>",
				{ desc = "Window backward" }
			)
			vim.keymap.set(
				"n",
				"<leader>w]",
				"<Cmd>lua MiniBracketed.window('forward')<cr>",
				{ desc = "Window forward" }
			)
			vim.keymap.set("n", "<leader>w$", "<Cmd>lua MiniBracketed.window('last')<cr>", { desc = "Window last" })
			vim.keymap.set("n", "<leader>[Y", "<Cmd>lua MiniBracketed.yank('first')<cr>", { desc = "Yank first" })
			vim.keymap.set("n", "<leader>[y", "<Cmd>lua MiniBracketed.yank('backward')<cr>", { desc = "Yank backward" })
			vim.keymap.set("n", "<leader>]y", "<Cmd>lua MiniBracketed.yank('forward')<cr>", { desc = "Yank forward" })
			vim.keymap.set("n", "<leader>]Y", "<Cmd>lua MiniBracketed.yank('last')<cr>", { desc = "Yank last" })
		end,
	},
	{
		"echasnovski/mini.files",
		opts = {
			-- I didn't like the default mappings, so I modified them
			-- Module mappings created only inside explorer.
			-- Use `''` (empty string) to not create one.
			mappings = {
				close = "q",
				-- Use this if you want to open several files
				go_in = "l",
				-- This opens the file, but quits out of mini.files (default L)
				go_in_plus = "<CR>",
				-- I swapped the following 2 (default go_out: h)
				-- go_out_plus: when you go out, it shows you only 1 item to the right
				-- go_out: shows you all the items to the right
				go_out = "H",
				go_out_plus = "h",
				-- Default <BS>
				reset = ",",
				-- Default @
				reveal_cwd = ".",
				show_help = "g?",
				-- Default =
				synchronize = "s",
				trim_left = "<",
				trim_right = ">",
				toggle_hidden = nil,
				change_cwd = nil,
				go_in_horizontal = nil,
				go_in_vertical = nil,
				go_in_horizontal_plus = nil,
				go_in_vertical_plus = nil,
			},
			options = {
				use_as_default_explorer = true,
				permanent_delete = false,
			},
			windows = {
				preview = true,
				width_focus = 25,
				width_preview = 40,
			},
		},
		keys = {
			{
				"<leader>ee",
				function()
					if not MiniFiles.close() then
						require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
					end
				end,
				desc = "Open mini.files",
			},
			{
				"<leader>eE",
				function()
					require("mini.files").open(vim.uv.cwd(), true)
				end,
				desc = "Open mini.files (cwd)",
			},
		},
		config = function(_, opts)
			require("mini.files").setup(opts)

			local show_dotfiles = true
			local filter_show = function(fs_entry)
				return true
			end
			local filter_hide = function(fs_entry)
				return not vim.startswith(fs_entry.name, ".")
			end

			local toggle_dotfiles = function()
				show_dotfiles = not show_dotfiles
				local new_filter = show_dotfiles and filter_show or filter_hide
				require("mini.files").refresh({ content = { filter = new_filter } })
			end

			local map_split = function(buf_id, lhs, direction, close_on_file)
				local rhs = function()
					local new_target_window
					local cur_target_window = require("mini.files").get_explorer_state().arget_window

					if cur_target_window ~= nil then
						vim.api.nvim_win_call(cur_target_window, function()
							vim.cmd("belowright " .. direction .. " split")
							new_target_window = vim.api.nvim_get_current_win()
						end)

						require("mini.files").set_target_window(new_target_window)
						require("mini.files").go_in({ close_on_file = close_on_file })
					end
				end

				local desc = "Open in " .. direction .. " split"
				if close_on_file then
					desc = desc .. " and close"
				end
				vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
			end

			local files_set_cwd = function()
				local cur_entry_path = MiniFiles.get_fs_entry().path
				local cur_directory = vim.fs.dirname(cur_entry_path)
				if cur_directory ~= nil then
					vim.fn.chdir(cur_directory)
				end
			end

			local mini_files = require("mini.files")
			local tmux_pane_function = require("TheSiahxyz.utils.tmux").tmux_pane_function

			local open_tmux_pane = function()
				local curr_entry = mini_files.get_fs_entry()
				if curr_entry then
					if curr_entry.fs_type == "directory" then
						tmux_pane_function(curr_entry.path)
					elseif curr_entry.fs_type == "file" then
						local parent_dir = vim.fn.fnamemodify(curr_entry.path, ":h")
						tmux_pane_function(parent_dir)
					elseif curr_entry.fs_type == "link" then
						local resolved_path = vim.fn.resolve(curr_entry.path)
						if vim.fn.isdirectory(resolved_path) == 1 then
							tmux_pane_function(resolved_path)
						else
							local parent_dir = vim.fn.fnamemodify(resolved_path, ":h")
							tmux_pane_function(parent_dir)
						end
					else
						vim.notify("Unsupported file system entry type", vim.log.levels.WARN)
					end
				else
					vim.notify("No entry selected", vim.log.levels.WARN)
				end
			end

			local copy_to_clipboard = function()
				local curr_entry = mini_files.get_fs_entry()
				if curr_entry then
					local path = curr_entry.path
					-- Escape the path for shell command
					local escaped_path = vim.fn.fnameescape(path)
					local cmd = vim.fn.has("mac") == 1
							and string.format([[osascript -e 'set the clipboard to POSIX file "%s"']], escaped_path)
						or string.format([[echo -n %s | xclip -selection clipboard]], escaped_path)
					local result = vim.fn.system(cmd)
					if vim.v.shell_error ~= 0 then
						vim.notify("Copy failed: " .. result, vim.log.levels.ERROR)
					else
						vim.notify(vim.fn.fnamemodify(path, ":t"), vim.log.levels.INFO)
						vim.notify("Copied to system clipboard", vim.log.levels.INFO)
					end
				else
					vim.notify("No file or directory selected", vim.log.levels.WARN)
				end
			end

			local zip_and_copy_to_clipboard = function()
				local curr_entry = require("mini.files").get_fs_entry()
				if curr_entry then
					local path = curr_entry.path
					local name = vim.fn.fnamemodify(path, ":t") -- Extract the file or directory name
					local parent_dir = vim.fn.fnamemodify(path, ":h") -- Get the parent directory
					local timestamp = os.date("%y%m%d%H%M%S") -- Append timestamp to avoid duplicates
					local zip_path = string.format("/tmp/%s_%s.zip", name, timestamp) -- Path in macOS's tmp directory
					-- Create the zip file
					local zip_cmd = string.format(
						"cd %s && zip -r %s %s",
						vim.fn.shellescape(parent_dir),
						vim.fn.shellescape(zip_path),
						vim.fn.shellescape(name)
					)
					local result = vim.fn.system(zip_cmd)
					if vim.v.shell_error ~= 0 then
						vim.notify("Failed to create zip file: " .. result, vim.log.levels.ERROR)
						return
					end
					-- Copy the zip file to the system clipboard
					local copy_cmd = vim.fn.has("mac") == 1
							and string.format([[osascript -e 'set the clipboard to POSIX file "%s"']], zip_path)
						or string.format([[echo -n %s | xclip -selection clipboard]], zip_path)
					local copy_result = vim.fn.system(copy_cmd)
					if vim.v.shell_error ~= 0 then
						vim.notify("Failed to copy zip file to clipboard: " .. copy_result, vim.log.levels.ERROR)
						return
					end
					vim.notify(zip_path, vim.log.levels.INFO)
					vim.notify("Zipped and copied to clipboard: ", vim.log.levels.INFO)
				else
					vim.notify("No file or directory selected", vim.log.levels.WARN)
				end
			end

			local paste_from_clipboard = function()
				-- vim.notify("Starting the paste operation...", vim.log.levels.INFO)
				if not mini_files then
					vim.notify("mini.files module not loaded.", vim.log.levels.ERROR)
					return
				end
				local curr_entry = mini_files.get_fs_entry() -- Get the current file system entry
				if not curr_entry then
					vim.notify("Failed to retrieve current entry in mini.files.", vim.log.levels.ERROR)
					return
				end
				local curr_dir = curr_entry.fs_type == "directory" and curr_entry.path
					or vim.fn.fnamemodify(curr_entry.path, ":h") -- Use parent directory if entry is a file
				-- vim.notify("Current directory: " .. curr_dir, vim.log.levels.INFO)
				local script = [[
            tell application "System Events"
              try
                set theFile to the clipboard as alias
                set posixPath to POSIX path of theFile
                return posixPath
              on error
                return "error"
              end try
            end tell
            ]]
				local output = vim.fn.has("mac") == 1 and vim.fn.system("osascript -e " .. vim.fn.shellescape(script))
					or vim.fn.system("xclip -o -selection clipboard")
				if vim.v.shell_error ~= 0 or output:find("error") then
					vim.notify("Clipboard does not contain a valid file or directory.", vim.log.levels.WARN)
					return
				end
				local source_path = output:gsub("%s+$", "") -- Trim whitespace from clipboard output
				if source_path == "" then
					vim.notify("Clipboard is empty or invalid.", vim.log.levels.WARN)
					return
				end
				local dest_path = curr_dir .. "/" .. vim.fn.fnamemodify(source_path, ":t") -- Destination path in current directory
				local copy_cmd = vim.fn.isdirectory(source_path) == 1 and { "cp", "-R", source_path, dest_path }
					or { "cp", source_path, dest_path } -- Construct copy command
				local result = vim.fn.system(copy_cmd) -- Execute the copy command
				if vim.v.shell_error ~= 0 then
					vim.notify("Paste operation failed: " .. result, vim.log.levels.ERROR)
					return
				end
				-- vim.notify("Pasted " .. source_path .. " to " .. dest_path, vim.log.levels.INFO)
				mini_files.synchronize() -- Refresh mini.files to show updated directory content
				vim.notify("Pasted successfully.", vim.log.levels.INFO)
			end

			local copy_path_to_clipboard = function()
				-- Get the current entry (file or directory)
				local curr_entry = mini_files.get_fs_entry()
				if curr_entry then
					-- Convert path to be relative to home directory
					local home_dir = vim.fn.expand("~")
					local relative_path = curr_entry.path:gsub("^" .. home_dir, "~")
					vim.fn.setreg("+", relative_path) -- Copy the relative path to the clipboard register
					vim.notify(vim.fn.fnamemodify(relative_path, ":t"), vim.log.levels.INFO)
					vim.notify("Path copied to clipboard: ", vim.log.levels.INFO)
				else
					vim.notify("No file or directory selected", vim.log.levels.WARN)
				end
			end

			local preview_image = function()
				local curr_entry = mini_files.get_fs_entry()
				if curr_entry then
					-- Preview the file using Quick Look
					if vim.fn.has("mac") == 1 then
						vim.system({ "qlmanage", "-p", curr_entry.path }, {
							stdout = false,
							stderr = false,
						})
						vim.defer_fn(function()
							vim.system({ "osascript", "-e", 'tell application "qlmanage" to activate' })
						end, 200)
					else
						-- TODO: add previewer for linux
						vim.notify("Preview not supported on Linux.", vim.log.levels.WARN)
					end
				else
					vim.notify("No file selected", vim.log.levels.WARN)
				end
			end

			local preview_image_popup = function()
				-- Clear any existing images before rendering the new one
				require("image").clear()
				local curr_entry = mini_files.get_fs_entry()
				if curr_entry and curr_entry.fs_type == "file" then
					local ext = vim.fn.fnamemodify(curr_entry.path, ":e"):lower()
					local supported_image_exts = { "png", "jpg", "jpeg", "gif", "bmp", "webp", "avif" }
					-- Check if the file has a supported image extension
					if vim.tbl_contains(supported_image_exts, ext) then
						-- Save mini.files state (current path and focused entry)
						local current_dir = vim.fn.fnamemodify(curr_entry.path, ":h")
						local focused_entry = vim.fn.fnamemodify(curr_entry.path, ":t") -- Extract filename
						-- Create a floating window for the image preview
						local popup_width = math.floor(vim.o.columns * 0.6)
						local popup_height = math.floor(vim.o.lines * 0.6)
						local col = math.floor((vim.o.columns - popup_width) / 2)
						local row = math.floor((vim.o.lines - popup_height) / 2)
						local buf = vim.api.nvim_create_buf(false, true) -- Create a scratch buffer
						local win = vim.api.nvim_open_win(buf, true, {
							relative = "editor",
							row = row,
							col = col,
							width = popup_width,
							height = popup_height,
							style = "minimal",
							border = "rounded",
						})
						-- Declare img_width and img_height at the top
						local img_width, img_height
						-- Get image dimensions using ImageMagick's identify command
						local dimensions = vim.fn.systemlist(
							string.format("identify -format '%%w %%h' %s", vim.fn.shellescape(curr_entry.path))
						)
						if #dimensions > 0 then
							img_width, img_height = dimensions[1]:match("(%d+) (%d+)")
							img_width = tonumber(img_width)
							img_height = tonumber(img_height)
						end
						-- Calculate image display size while maintaining aspect ratio
						local display_width = popup_width
						local display_height = popup_height
						if img_width and img_height then
							local aspect_ratio = img_width / img_height
							if aspect_ratio > (popup_width / popup_height) then
								-- Image is wider than the popup window
								display_height = math.floor(popup_width / aspect_ratio)
							else
								-- Image is taller than the popup window
								display_width = math.floor(popup_height * aspect_ratio)
							end
						end
						-- Center the image within the popup window
						local image_x = math.floor((popup_width - display_width) / 2)
						local image_y = math.floor((popup_height - display_height) / 2)
						-- Use image.nvim to render the image
						local img = require("image").from_file(curr_entry.path, {
							id = curr_entry.path, -- Unique ID
							window = win, -- Bind the image to the popup window
							buffer = buf, -- Bind the image to the popup buffer
							x = image_x,
							y = image_y,
							width = display_width,
							height = display_height,
							with_virtual_padding = true,
						})
						-- Render the image
						if img ~= nil then
							img:render()
						end
						-- Use `stat` or `ls` to get the file size in bytes
						local file_size_bytes = ""
						if vim.fn.has("mac") == 1 or vim.fn.has("unix") == 1 then
							-- For macOS or Linux systems
							local handle = io.popen(
								"stat -f%z "
									.. vim.fn.shellescape(curr_entry.path)
									.. " || ls -l "
									.. vim.fn.shellescape(curr_entry.path)
									.. " | awk '{print $5}'"
							)
							if handle then
								file_size_bytes = handle:read("*a"):gsub("%s+$", "") -- Trim trailing whitespace
								handle:close()
							end
						else
							-- Fallback message if the command isn't available
							file_size_bytes = "0"
						end
						-- Convert the size to MB (if valid)
						local file_size_mb = tonumber(file_size_bytes) and tonumber(file_size_bytes) / (1024 * 1024)
							or 0
						local file_size_mb_str = string.format("%.2f", file_size_mb) -- Format to 2 decimal places as a string
						-- Add image information (filename, size, resolution)
						local image_info = {}
						table.insert(image_info, "Image File: " .. focused_entry) -- Add only the filename
						if tonumber(file_size_bytes) > 0 then
							table.insert(image_info, "Size: " .. file_size_mb_str .. " MB") -- Use the formatted string
						else
							table.insert(image_info, "Size: Unable to detect") -- Fallback if size isn't found
						end
						if img_width and img_height then
							table.insert(image_info, "Resolution: " .. img_width .. " x " .. img_height)
						else
							table.insert(image_info, "Resolution: Unable to detect")
						end
						-- Append the image information after the image
						local line_count = vim.api.nvim_buf_line_count(buf)
						vim.api.nvim_buf_set_lines(buf, line_count, -1, false, { "", "", "" }) -- Add 3 empty lines
						vim.api.nvim_buf_set_lines(buf, -1, -1, false, image_info)
						-- Keymap for closing the popup and reopening mini.files
						local function reopen_mini_files()
							if img ~= nil then
								img:clear()
							end
							vim.api.nvim_win_close(win, true)
							-- Reopen mini.files in the same directory
							require("mini.files").open(current_dir, true)
							vim.defer_fn(function()
								-- Simulate navigation to the file by searching for the line matching the file
								local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false) -- Get all lines in the buffer
								for i, line in ipairs(lines) do
									if line:match(focused_entry) then
										vim.api.nvim_win_set_cursor(0, { i, 0 }) -- Move cursor to the matching line
										break
									end
								end
							end, 50) -- Small delay to ensure mini.files is initialized
						end
						vim.keymap.set("n", "<esc>", reopen_mini_files, { buffer = buf, noremap = true, silent = true })
					else
						vim.notify("Not an image file.", vim.log.levels.WARN)
					end
				else
					vim.notify("No file selected or not a file.", vim.log.levels.WARN)
				end
			end

			local follow_symlink = function()
				local curr_entry = mini_files.get_fs_entry()
				if curr_entry and curr_entry.fs_type == "file" then
					local resolved_path = vim.fn.resolve(curr_entry.path) -- Resolve symlink to original file
					if resolved_path ~= curr_entry.path then
						vim.notify("Following symlink to: " .. resolved_path, vim.log.levels.INFO)
						mini_files.open(resolved_path, true) -- Open the original file in mini.files
					else
						vim.notify("The file is not a symlink.", vim.log.levels.WARN)
					end
				else
					vim.notify("No file selected or not a valid file.", vim.log.levels.WARN)
				end
			end

			vim.api.nvim_create_autocmd("User", {
				pattern = "MiniFilesBufferCreate",
				callback = function()
					local buf_id = vim.api.nvim_get_current_buf()

					vim.keymap.set(
						"n",
						opts.mappings and opts.mappings.toggle_hidden or "g.",
						toggle_dotfiles,
						{ buffer = buf_id, desc = "Toggle hidden files" }
					)

					vim.keymap.set(
						"n",
						opts.mappings and opts.mappings.change_cwd or "gc",
						files_set_cwd,
						{ buffer = buf_id, desc = "Set cwd" }
					)

					map_split(buf_id, opts.mappings and opts.mappings.go_in_horizontal or "<C-w>s", "horizontal", false)
					map_split(buf_id, opts.mappings and opts.mappings.go_in_vertical or "<C-w>v", "vertical", false)
					map_split(
						buf_id,
						opts.mappings and opts.mappings.go_in_horizontal_plus or "<C-w>S",
						"horizontal",
						true
					)
					map_split(buf_id, opts.mappings and opts.mappings.go_in_vertical_plus or "<C-w>V", "vertical", true)

					vim.keymap.set(
						"n",
						"zt",
						open_tmux_pane,
						{ buffer = buf_id, noremap = true, silent = true, desc = "Open tmux pane" }
					)
					vim.keymap.set(
						"n",
						"zy",
						copy_to_clipboard,
						{ buffer = buf_id, noremap = true, silent = true, desc = "Copy to clipboard" }
					)
					vim.keymap.set(
						"n",
						"zY",
						copy_path_to_clipboard,
						{ buffer = buf_id, desc = "Copy path to clipboard" }
					)
					vim.keymap.set(
						"n",
						"zc",
						zip_and_copy_to_clipboard,
						{ buffer = buf_id, noremap = true, silent = true, desc = "Zip and copy" }
					)
					vim.keymap.set(
						"n",
						"zp",
						paste_from_clipboard,
						{ buffer = buf_id, noremap = true, silent = true, desc = "Paste from clipboard" }
					)
					vim.keymap.set(
						"n",
						"zi",
						preview_image,
						{ buffer = buf_id, noremap = true, silent = true, desc = "Preview image" }
					)
					vim.keymap.set(
						"n",
						"zI",
						preview_image_popup,
						{ buffer = buf_id, noremap = true, silent = true, desc = "Pop-up preview image" }
					)
					vim.keymap.set(
						"n",
						"gl",
						follow_symlink,
						{ buffer = buf_id, noremap = true, silent = true, desc = "Follow link" }
					)
				end,
			})

			-- Git status
			local nsMiniFiles = vim.api.nvim_create_namespace("mini_files_git")
			local autocmd = vim.api.nvim_create_autocmd
			local _, MiniFiles = pcall(require, "mini.files")

			-- Cache for git status
			local gitStatusCache = {}
			local cacheTimeout = 2000 -- Cache timeout in milliseconds

			---@type table<string, {symbol: string, hlGroup: string}>
			---@param status string
			---@return string symbol, string hlGroup
			local function mapSymbols(status)
				local statusMap = {
                    -- stylua: ignore start
                    [" M"] = { symbol = "•", hlGroup  = "GitSignsChange"}, -- Modified in the working directory
                    ["M "] = { symbol = "✹", hlGroup  = "GitSignsChange"}, -- modified in index
                    ["MM"] = { symbol = "≠", hlGroup  = "GitSignsChange"}, -- modified in both working tree and index
                    ["A "] = { symbol = "+", hlGroup  = "GitSignsAdd"   }, -- Added to the staging area, new file
                    ["AA"] = { symbol = "≈", hlGroup  = "GitSignsAdd"   }, -- file is added in both working tree and index
                    ["D "] = { symbol = "-", hlGroup  = "GitSignsDelete"}, -- Deleted from the staging area
                    ["AM"] = { symbol = "⊕", hlGroup  = "GitSignsChange"}, -- added in working tree, modified in index
                    ["AD"] = { symbol = "-•", hlGroup = "GitSignsChange"}, -- Added in the index and deleted in the working directory
                    ["R "] = { symbol = "→", hlGroup  = "GitSignsChange"}, -- Renamed in the index
                    ["U "] = { symbol = "‖", hlGroup  = "GitSignsChange"}, -- Unmerged path
                    ["UU"] = { symbol = "⇄", hlGroup  = "GitSignsAdd"   }, -- file is unmerged
                    ["UA"] = { symbol = "⊕", hlGroup  = "GitSignsAdd"   }, -- file is unmerged and added in working tree
                    ["??"] = { symbol = "?", hlGroup  = "GitSignsDelete"}, -- Untracked files
                    ["!!"] = { symbol = "!", hlGroup  = "GitSignsChange"}, -- Ignored files
					-- stylua: ignore end
				}

				local result = statusMap[status] or { symbol = "?", hlGroup = "NonText" }
				return result.symbol, result.hlGroup
			end

			---@param cwd string
			---@param callback function
			---@return nil
			local function fetchGitStatus(cwd, callback)
				local function on_exit(content)
					if content.code == 0 then
						callback(content.stdout)
						vim.g.content = content.stdout
					end
				end
				vim.system({ "git", "status", "--ignored", "--porcelain" }, { text = true, cwd = cwd }, on_exit)
			end

			---@param str string?
			local function escapePattern(str)
				return str:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
			end

			---@param buf_id integer
			---@param gitStatusMap table
			---@return nil
			local function updateMiniWithGit(buf_id, gitStatusMap)
				vim.schedule(function()
					local nlines = vim.api.nvim_buf_line_count(buf_id)
					local cwd = vim.fs.root(buf_id, ".git")
					local escapedcwd = escapePattern(cwd)
					if vim.fn.has("win32") == 1 then
						escapedcwd = escapedcwd:gsub("\\", "/")
					end

					for i = 1, nlines do
						local entry = MiniFiles.get_fs_entry(buf_id, i)
						if not entry then
							break
						end
						local relativePath = entry.path:gsub("^" .. escapedcwd .. "/", "")
						local status = gitStatusMap[relativePath]

						if status then
							local symbol, hlGroup = mapSymbols(status)
							vim.api.nvim_buf_set_extmark(buf_id, nsMiniFiles, i - 1, 0, {
								-- NOTE: if you want the signs on the right uncomment those and comment
								-- the 3 lines after
								-- virt_text = { { symbol, hlGroup } },
								-- virt_text_pos = "right_align",
								sign_text = symbol,
								sign_hl_group = hlGroup,
								priority = 2,
							})
						else
						end
					end
				end)
			end

			-- Thanks for the idea of gettings https://github.com/refractalize/oil-git-status.nvim signs for dirs
			---@param content string
			---@return table
			local function parseGitStatus(content)
				local gitStatusMap = {}
				-- lua match is faster than vim.split (in my experience )
				for line in content:gmatch("[^\r\n]+") do
					local status, filePath = string.match(line, "^(..)%s+(.*)")
					-- Split the file path into parts
					local parts = {}
					for part in filePath:gmatch("[^/]+") do
						table.insert(parts, part)
					end
					-- Start with the root directory
					local currentKey = ""
					for i, part in ipairs(parts) do
						if i > 1 then
							-- Concatenate parts with a separator to create a unique key
							currentKey = currentKey .. "/" .. part
						else
							currentKey = part
						end
						-- If it's the last part, it's a file, so add it with its status
						if i == #parts then
							gitStatusMap[currentKey] = status
						else
							-- If it's not the last part, it's a directory. Check if it exists, if not, add it.
							if not gitStatusMap[currentKey] then
								gitStatusMap[currentKey] = status
							end
						end
					end
				end
				return gitStatusMap
			end

			---@param buf_id integer
			---@return nil
			local function updateGitStatus(buf_id)
				if not vim.fs.root(vim.uv.cwd(), ".git") then
					return
				end

				local cwd = vim.fn.expand("%:p:h")
				local currentTime = os.time()
				if gitStatusCache[cwd] and currentTime - gitStatusCache[cwd].time < cacheTimeout then
					updateMiniWithGit(buf_id, gitStatusCache[cwd].statusMap)
				else
					fetchGitStatus(cwd, function(content)
						local gitStatusMap = parseGitStatus(content)
						gitStatusCache[cwd] = {
							time = currentTime,
							statusMap = gitStatusMap,
						}
						updateMiniWithGit(buf_id, gitStatusMap)
					end)
				end
			end

			---@return nil
			local function clearCache()
				gitStatusCache = {}
			end

			local function augroup(name)
				return vim.api.nvim_create_augroup("MiniFiles_" .. name, { clear = true })
			end

			autocmd("User", {
				group = augroup("start"),
				pattern = "MiniFilesExplorerOpen",
				callback = function()
					local bufnr = vim.api.nvim_get_current_buf()
					local path = vim.api.nvim_buf_get_name(bufnr)
					if path:match("^minifiles://") then
						return
					end
					updateGitStatus(bufnr)
				end,
			})

			autocmd("User", {
				group = augroup("close"),
				pattern = "MiniFilesExplorerClose",
				callback = function()
					clearCache()
				end,
			})

			autocmd("User", {
				group = augroup("update"),
				pattern = "MiniFilesBufferUpdate",
				callback = function(sii)
					local bufnr = sii.data.buf_id
					local cwd = vim.fn.expand("%:p:h")
					if gitStatusCache[cwd] then
						updateMiniWithGit(bufnr, gitStatusCache[cwd].statusMap)
					end
				end,
			})
		end,
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
				goto_top = "g,",
				goto_bottom = "g;",
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
		"echasnovski/mini.map",
		version = false,
		config = function()
			require("mini.map").setup(
				-- No need to copy this inside `setup()`. Will be used automatically.
				{
					-- Highlight integrations (none by default)
					integrations = nil,

					-- Symbols used to display data
					symbols = {
						-- Encode symbols. See `:h MiniMap.config` for specification and
						-- `:h MiniMap.gen_encode_symbols` for pre-built ones.
						-- Default: solid blocks with 3x2 resolution.
						encode = nil,

						-- Scrollbar parts for view and line. Use empty string to disable any.
						scroll_line = "█",
						scroll_view = "┃",
					},

					-- Window options
					window = {
						-- Whether window is focusable in normal way (with `wincmd` or mouse)
						focusable = true,

						-- Side to stick ('left' or 'right')
						side = "right",

						-- Whether to show count of multiple integration highlights
						show_integration_count = true,

						-- Total width
						width = 10,

						-- Value of 'winblend' option
						winblend = 25,

						-- Z-index
						zindex = 10,
					},
				}
			)
		end,
		init = function()
			local wk = require("which-key")
			wk.add({
				mode = { "n", "v" },
				{ "<leader>m", group = "Markdown/Map" },
				{ "<leader>mt", group = "Toggle" },
			})
		end,
		keys = {
			{ "<leader>mo", "<Cmd>lua MiniMap.open()<cr>", desc = "Open map" },
			{ "<leader>mm", "<Cmd>lua MiniMap.refresh()<cr>", desc = "Refresh map" },
			{ "<leader>mc", "<Cmd>lua MiniMap.close()<cr>", desc = "Close map" },
			{ "<leader>mtm", "<Cmd>lua MiniMap.toggle()<cr>", desc = "Toggle map" },
			{ "<leader>mts", "<Cmd>lua MiniMap.toggle_side()<cr>", desc = "Toggle side map" },
		},
	},
	{
		"echasnovski/mini.move",
		version = false,
		config = function()
			-- No need to copy this inside `setup()`. Will be used automatically.
			require("mini.move").setup({
				-- Module mappings. Use `''` (empty string) to disable one.
				mappings = {
					-- Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
					left = "<M-m>",
					right = "<M-/>",
					down = "<M-,>",
					up = "<M-.>",

					-- Move current line in Normal mode
					line_left = "<M-m>",
					line_right = "<M-/>",
					line_down = "<M-,>",
					line_up = "<M-.>",
				},

				-- Options which control moving behavior
				options = {
					-- Automatically reindent selection during linewise vertical move
					reindent_linewise = true,
				},
			})
		end,
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
				"<leader>zp",
				function()
					vim.g.minipairs_disable = not vim.g.minipairs_disable
				end,
				desc = "Toggle auto pairs",
			},
		},
	},
	{
		"echasnovski/mini.splitjoin",
		version = false,
		config = function()
			require("mini.splitjoin").setup()

			vim.keymap.set(
				"n",
				"<leader>zj",
				":lua MiniSplitjoin.toggle()<cr>",
				{ noremap = true, silent = true, desc = "Toggle split-join" }
			)
			vim.keymap.set(
				"n",
				"<leader>J",
				":lua MiniSplitjoin.join()<cr>",
				{ noremap = true, silent = true, desc = "Join" }
			)
			vim.keymap.set(
				"n",
				"<leader><cr>",
				":lua MiniSplitjoin.split()<cr>",
				{ noremap = true, silent = true, desc = "Split" }
			)
		end,
	},
	{
		"echasnovski/mini.trailspace",
		version = false,
		config = function()
			require("mini.trailspace").setup()
			vim.keymap.set(
				"n",
				"<leader>zt",
				":lua MiniTrailspace.trim()<cr>",
				{ noremap = true, silent = true, desc = "Trim trailing whitespace" }
			)
			vim.keymap.set(
				"n",
				"<leader>zl",
				":lua MiniTrailspace.trim_last_lines()<cr>",
				{ noremap = true, silent = true, desc = "Trim trailing empty lines" }
			)
		end,
	},
}
