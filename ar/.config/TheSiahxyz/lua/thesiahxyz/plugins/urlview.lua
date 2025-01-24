return {
	"axieax/urlview.nvim",
	dependencies = "nvim-telescope/telescope.nvim",
	init = function()
		local wk = require("which-key")
		wk.add({
			mode = { "n", "v" },
			{ "<leader>u", group = "URLs" },
			{ "<leader>uc", group = "Copy URLs" },
		})
	end,
	config = function()
		-- Load urlview
		require("urlview").setup({})

		-- Define custom search for thesiah_urls
		local thesiah = require("urlview.search")
		thesiah["thesiah_urls"] = function()
			local urls = {}
			local files = {
				vim.fn.expand("~/.local/share/thesiah/urls"),
				vim.fn.expand("~/.local/share/thesiah/snippets"),
			}

			-- Check if the file exists and read each file
			for _, filepath in ipairs(files) do
				if vim.fn.filereadable(filepath) == 1 then
					local file = io.open(filepath, "r")
					if file then
						for line in file:lines() do
							-- Match and capture URLs
							for url in line:gmatch("https?://[%w%./%-_%%]+") do
								table.insert(urls, url)
							end
						end
						file:close()
					else
						vim.notify("Unable to open " .. filepath, vim.log.levels.ERROR)
					end
				else
					vim.notify("File not found: " .. filepath, vim.log.levels.WARN)
				end
			end

			return urls
		end

		local search = require("urlview.search")
		local search_helpers = require("urlview.search.helpers")

		-- Custom search function for Tmux plugins
		search["tmux_plugins"] = function()
			local urls = {}
			local filepath = vim.fn.expand("~/.config/tmux/tmux.conf")

			-- Check if the tmux.conf file exists
			if vim.fn.filereadable(filepath) == 1 then
				local file = io.open(filepath, "r")
				if file then
					for line in file:lines() do
						-- Match lines that contain Tmux plugin URLs (TPM syntax)
						-- Example: set -g @plugin 'tmux-plugins/tpm'
						local url = line:match("@plugin%s+'([^']+)'")
						if url then
							-- Convert to full GitHub URL if not already a full URL
							if not url:match("^https?://") then
								url = "https://github.com/" .. url
							end
							table.insert(urls, url)
						end
					end
					file:close()
				else
					vim.notify("Unable to open " .. filepath, vim.log.levels.ERROR)
				end
			else
				vim.notify("File not found: " .. filepath, vim.log.levels.WARN)
			end

			return urls
		end

		-- Add a keymap for the Tmux plugins search context
		vim.keymap.set("n", "<leader>ub", "<cmd>UrlView thesiah_urls<cr>", { desc = "Bookmarks URLs" })
		vim.keymap.set("n", "<leader>ul", "<cmd>UrlView lazy<cr>", { desc = "Lazy plugin URLs" })
		vim.keymap.set("n", "<leader>ur", "<cmd>UrlView<cr>", { desc = "Buffer URLs" })
		vim.keymap.set("n", "<leader>ut", "<cmd>UrlView tmux_plugins<cr>", { desc = "Tmux plugin URLs" })
		vim.keymap.set(
			"n",
			"<leader>ucb",
			"<cmd>UrlView thesiah_urls action=clipboard<cr>",
			{ desc = "clipboard bookmarks URLs" }
		)
		vim.keymap.set("n", "<leader>ucl", "<cmd>UrlView lazy action=clipboard<cr>", { desc = "Copy Lazy plugin URLs" })
		vim.keymap.set("n", "<leader>ucr", "<cmd>UrlView action=clipboard<cr>", { desc = "Copy buffer URLs" })
		vim.keymap.set(
			"n",
			"<leader>uct",
			"<cmd>UrlView tmux_plugins action=clipboard<cr>",
			{ desc = "clipboard tmux plugin URLs" }
		)
	end,
}
