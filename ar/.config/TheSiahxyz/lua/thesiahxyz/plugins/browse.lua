return {
	"lalitmee/browse.nvim",
	dependencies = "nvim-telescope/telescope-ui-select.nvim",
	config = function()
		require("browse").setup({
			-- search provider you want to use
			provider = "duckduckgo", -- duckduckgo, bing

			-- either pass it here or just pass the table to the functions
			-- see below for more
			bookmarks = {
				["github"] = {
					["name"] = "search github from neovim",
					["code_search"] = "https://github.com/search?q=%s&type=code",
					["repo_search"] = "https://github.com/search?q=%s&type=repositories",
					["issues_search"] = "https://github.com/search?q=%s&type=issues",
					["pulls_search"] = "https://github.com/search?q=%s&type=pullrequests",
				},
			},
		})
	end,
	keys = {
		{
			"<leader>bb",
			function()
				require("browse").browse()
			end,
			desc = "Browse Bookmarks",
		},
		{
			"<leader>bc",
			function()
				require("browse.devdocs").search()
			end,
			desc = "Search Devdocs",
		},
		{
			"<leader>bm",
			function()
				require("browse.mdn").search()
			end,
			desc = "Search MDN",
		},
		{
			"<leader>bo",
			function()
				require("browse").open_bookmarks()
			end,
			desc = "Browse Bookmarks",
		},
		{
			"<leader>bs",
			function()
				require("browse").input_search()
			end,
			desc = "Search Bookmarks",
		},
	},
}
