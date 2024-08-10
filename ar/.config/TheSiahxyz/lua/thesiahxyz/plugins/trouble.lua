return {
	"folke/trouble.nvim",
	opts = { use_diagnostic_signs = true },
	config = function()
		require("trouble").setup({
			icons = false,
		})
		vim.keymap.set("n", "<leader>tt", function()
			require("trouble").toggle()
		end, { desc = "Toggle Trouble" })
		vim.keymap.set("n", "<leader>tw", function()
			require("trouble").toggle("workspace_diagnostics")
		end, { desc = "Toggle Workspace Diagnostics" })
		vim.keymap.set("n", "<leader>td", function()
			require("trouble").toggle("document_diagnostics")
		end, { desc = "Toggle Document Diagnostics" })
		vim.keymap.set("n", "<leader>tq", function()
			require("trouble").toggle("quickfix")
		end, { desc = "Toggle Quickfix List" })
		vim.keymap.set("n", "<leader>tl", function()
			require("trouble").toggle("loclist")
		end, { desc = "Toggle Location List" })
		vim.keymap.set("n", "<leader>tr", function()
			require("trouble").toggle("lsp_references")
		end, { desc = "Toggle Lsp References" })
		vim.keymap.set("n", "[t", function()
			if require("trouble").is_open() then
				require("trouble").previous({ skip_groups = true, jump = true })
			end
		end, { desc = "Go to Previous Trouble" })
		vim.keymap.set("n", "]t", function()
			if require("trouble").is_open() then
				require("trouble").next({ skip_groups = true, jump = true })
			end
		end, { desc = "Go to Next Trouble" })
	end,
}
