return {
	"HakonHarnes/img-clip.nvim",
	event = "VeryLazy",
	opts = {
		-- add options here
		-- or leave it empty to use the default settings
	},
	config = function(_, opts)
		require("img-clip").setup(opts)

		vim.keymap.set({ "n", "v", "i" }, "<M-i>", function()
			-- The image needs to be converted to the format I use, which usually is AVIF
			-- and it takes a few seconds, a lot of time I don't know if it's being pasted
			-- or not, so I like seeing this message to know I pressed the correct keymap
			print("PROCESSING IMAGE BEFORE PASTING...")
			-- I had to add a 100ms delay because the message above was not shown
			vim.defer_fn(function()
				-- Call the paste_image function from the Lua API
				-- Using the plugin's Lua API (require("img-clip").paste_image()) instead of the
				-- PasteImage command because the Lua API returns a boolean value indicating
				-- whether an image was pasted successfully or not.
				-- The PasteImage command does not
				-- https://github.com/HakonHarnes/img-clip.nvim/blob/main/README.md#api
				local pasted_image = require("img-clip").paste_image()
				if pasted_image then
					-- "Update" saves only if the buffer has been modified since the last save
					vim.cmd("update")
					print("Image pasted and file saved")
					-- Only if updated I'll refresh the images by clearing them first
					-- I'm using [[ ]] to escape the special characters in a command
					require("image").clear()
					-- vim.cmd([[lua require("image").clear()]])
					-- Switch to the line below
					vim.cmd("normal! o")
					-- Switch back to command mode or normal mode
					vim.cmd("startinsert")
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("- ", true, false, true), "i", true)
				-- Reloads the file to reflect the changes
				-- I commented this edit because I was getting error when pasting images:
				-- msg_show E5108: Error executing lua: vim/_editor.lua:0: nvim_exec2()..DiagnosticChanged
				-- Autocommands for "*": Vim(append):Error executing lua callback:
				-- ...vim-treesitter-context/lua/treesitter-context/render.lua:270: E565: Not allowed to change text or change window
				-- vim.cmd("edit!")
				else
					print("No image pasted. File not updated.")
				end
			end, 100)
		end, { desc = "Paste image from clipboard" })

		vim.keymap.set("n", "<leader>oi", function()
			local function get_image_path()
				-- Get the current line
				local line = vim.api.nvim_get_current_line()
				-- Pattern to match image path in Markdown
				local image_pattern = "%[.-%]%((.-)%)"
				-- Extract relative image path
				local _, _, image_path = string.find(line, image_pattern)
				return image_path
			end
			-- Get the image path
			local image_path = get_image_path()
			if image_path then
				-- Check if the image path starts with "http" or "https"
				if string.sub(image_path, 1, 4) == "http" then
					print("URL image, use 'gx' to open it in the default browser.")
				else
					-- Construct absolute image path
					local current_file_path = vim.fn.expand("%:p:h")
					local absolute_image_path = current_file_path .. "/" .. image_path
					-- Construct command to open image in Preview
					local command = "nsxiv -aiop " .. vim.fn.shellescape(absolute_image_path)
					-- Execute the command
					local success = os.execute(command)
					if success then
						print("Opened image: " .. absolute_image_path)
					else
						print("Failed to open image: " .. absolute_image_path)
					end
				end
			else
				print("No image found under the cursor")
			end
		end, { desc = "Open image under cursor" })

		vim.keymap.set("n", "<leader>di", function()
			local function get_image_path()
				local line = vim.api.nvim_get_current_line()
				local image_pattern = "%[.-%]%((.-)%)"
				local _, _, image_path = string.find(line, image_pattern)
				return image_path
			end
			local image_path = get_image_path()
			if not image_path then
				vim.api.nvim_echo({ { "No image found under the cursor", "WarningMsg" } }, false, {})
				return
			end
			if string.sub(image_path, 1, 4) == "http" then
				vim.api.nvim_echo({ { "URL image cannot be deleted from disk.", "WarningMsg" } }, false, {})
				return
			end
			local current_file_path = vim.fn.expand("%:p:h")
			local absolute_image_path = current_file_path .. "/" .. image_path
			-- Check if file exists
			if vim.fn.filereadable(absolute_image_path) == 0 then
				vim.api.nvim_echo(
					{ { "Image file does not exist:\n", "ErrorMsg" }, { absolute_image_path, "ErrorMsg" } },
					false,
					{}
				)
				return
			end
			if vim.fn.executable("trash") == 0 then
				vim.api.nvim_echo({
					{ "- Trash utility not installed. Make sure to install it first\n", "ErrorMsg" },
					{ "- Install `trash-cli`\n", nil },
				}, false, {})
				return
			end
			vim.ui.select({ "yes", "no" }, { prompt = "Delete image file? " }, function(choice)
				if choice == "yes" then
					local success, _ = pcall(function()
						vim.fn.system({ "trash", vim.fn.fnameescape(absolute_image_path) })
					end)
					-- Verify if file still exists after deletion attempt
					if success and vim.fn.filereadable(absolute_image_path) == 1 then
						-- Try with rm if trash deletion failed
						-- Keep in mind that if deleting with `rm` the images won't go to the
						-- macos trash app, they'll be gone
						-- This is useful in case trying to delete imaes mounted in a network
						-- drive, like for my blogpost lamw25wmal
						vim.ui.select(
							{ "yes", "no" },
							{ prompt = "Trash deletion failed. Try with rm command? " },
							function(rm_choice)
								if rm_choice == "yes" then
									local rm_success, _ = pcall(function()
										vim.fn.system({ "rm", vim.fn.fnameescape(absolute_image_path) })
									end)
									if rm_success and vim.fn.filereadable(absolute_image_path) == 0 then
										vim.api.nvim_echo({
											{ "Image file deleted from disk using rm:\n", "Normal" },
											{ absolute_image_path, "Normal" },
										}, false, {})
										require("image").clear()
										vim.cmd("edit!")
										vim.cmd("normal! dd")
									else
										vim.api.nvim_echo({
											{ "Failed to delete image file with rm:\n", "ErrorMsg" },
											{ absolute_image_path, "ErrorMsg" },
										}, false, {})
									end
								end
							end
						)
					elseif success and vim.fn.filereadable(absolute_image_path) == 0 then
						vim.api.nvim_echo({
							{ "Image file deleted from disk:\n", "Normal" },
							{ absolute_image_path, "Normal" },
						}, false, {})
						require("image").clear()
						vim.cmd("edit!")
						vim.cmd("normal! dd")
					else
						vim.api.nvim_echo({
							{ "Failed to delete image file:\n", "ErrorMsg" },
							{ absolute_image_path, "ErrorMsg" },
						}, false, {})
					end
				else
					vim.api.nvim_echo({ { "Image deletion canceled.", "Normal" } }, false, {})
				end
			end)
		end, { desc = "Delete image file under cursor" })

		-- Refresh the images in the current buffer
		-- Useful if you delete an actual image file and want to see the changes
		-- without having to re-open neovim
		vim.keymap.set("n", "<leader>ir", function()
			-- First I clear the images
			require("image").clear()
			-- I'm using [[ ]] to escape the special characters in a command
			-- vim.cmd([[lua require("image").clear()]])
			-- Reloads the file to reflect the changes
			vim.cmd("edit!")
			print("Images refreshed")
		end, { desc = "Refresh images" })

		-- Set up a keymap to clear all images in the current buffer
		vim.keymap.set("n", "<leader>ic", function()
			-- This is the command that clears the images
			require("image").clear()
			-- I'm using [[ ]] to escape the special characters in a command
			-- vim.cmd([[lua require("image").clear()]])
			print("Images cleared")
		end, { desc = "Clear images" })
	end,
	keys = {
		-- suggested keymap
		{ "<leader>pi", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
	},
}
