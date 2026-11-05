return {
	"3rd/diagram.nvim",
	dependencies = {
		"3rd/image.nvim",
	},
	opts = {
		-- Disable automatic rendering for manual-only workflow
		events = {
			render_buffer = {}, -- Empty = no automatic rendering
			clear_buffer = { "BufLeave" },
		},
		renderer_options = {
			mermaid = {
				theme = "dark",
				scale = 2,
			},
		},
	},
	config = function()
		require("diagram").setup({
			integrations = {
				require("diagram.integrations.markdown"),
				require("diagram.integrations.neorg"),
			},
			renderer_options = {
				mermaid = {
					theme = "forest",
				},
				plantuml = {
					charset = "utf-8",
				},
				d2 = {
					theme_id = 1,
				},
				gnuplot = {
					theme = "dark",
					size = "800,600",
				},
			},
		})
	end,
	keys = {
		{
			"K", -- or any key you prefer
			function()
				require("diagram").show_diagram_hover()
			end,
			mode = "n",
			ft = { "markdown", "norg" }, -- Only in these filetypes
			desc = "Show diagram in new tab",
		},
	},
}
