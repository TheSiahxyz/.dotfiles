return {
	"folke/persistence.nvim",
	event = "BufReadPre", -- this will only start session saving when an actual file was opened
	config = function()
		require("persistence").setup({
			dir = vim.fn.stdpath("state") .. "/sessions/", -- directory where session files are saved
			-- minimum number of file buffers that need to be open to save
			-- Set to 0 to always save
			need = 0,
			branch = true, -- use git branch to save session
		})

		vim.keymap.set("n", "<leader>qs", function()
			require("persistence").load()
		end, { desc = "Load session" })

		-- select a session to load
		vim.keymap.set("n", "<leader>fs", function()
			require("persistence").select()
		end, { desc = "Find session" })

		-- load the last session
		vim.keymap.set("n", "<leader>ql", function()
			require("persistence").load({ last = true })
		end, { desc = "Last session" })

		-- stop Persistence => session won't be saved on exit
		vim.keymap.set("n", "<leader>qx", function()
			require("persistence").stop()
		end, { desc = "Stop session" })
	end,
}
