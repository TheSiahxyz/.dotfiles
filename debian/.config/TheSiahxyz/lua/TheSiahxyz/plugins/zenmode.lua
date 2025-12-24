return {
	"folke/zen-mode.nvim",
	opts = {},
	config = function()
		_G.ZenWinbar = function()
			local bt = vim.bo.buftype
			if bt ~= "" then
				return "" -- scratch, terminal, help, quickfix 등은 숨김
			end
			local name = vim.api.nvim_buf_get_name(0)
			if name == nil or name == "" then
				return "" -- 이름 없는 새 버퍼도 숨김
			end
			return vim.fn.fnamemodify(name, ":t") -- 파일명만
		end
		local function apply_winbar_for_current()
			vim.wo.winbar = "%{%v:lua.ZenWinbar()%}"
		end
		local function apply_winbar_for_all()
			for _, win in ipairs(vim.api.nvim_list_wins()) do
				vim.api.nvim_set_option_value("winbar", "%{%v:lua.ZenWinbar()%}", { win = win })
			end
		end
		local function clear_winbar_for_all()
			for _, win in ipairs(vim.api.nvim_list_wins()) do
				vim.api.nvim_set_option_value("winbar", nil, { win = win })
			end
		end
		local aug = vim.api.nvim_create_augroup("ZenWinbar", { clear = true })

		vim.keymap.set("n", "<leader>zz", function()
			require("zen-mode").toggle({
				window = {
					width = 90,
				},
				-- callback where you can add custom code when the Zen window opens
				on_open = function()
					vim.wo.wrap = true
					vim.wo.number = true
					vim.wo.rnu = true
					apply_winbar_for_all()
					vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
						group = aug,
						callback = apply_winbar_for_current,
					})
				end,
				-- callback where you can add custom code when the Zen window closes
				on_close = function()
					vim.wo.wrap = false
					vim.wo.number = true
					vim.wo.rnu = true
					vim.api.nvim_clear_autocmds({ group = aug })
					clear_winbar_for_all()
					ColorMyPencils()
				end,
			})
		end, { desc = "Toggle zenmode" })

		vim.keymap.set("n", "<leader>zZ", function()
			require("zen-mode").toggle({
				window = {
					width = 90,
				},
				-- callback where you can add custom code when the Zen window opens
				on_open = function()
					vim.wo.wrap = true
					vim.wo.number = false
					vim.wo.rnu = false
					vim.opt.colorcolumn = "0"
					ColorMyPencils("seoul256")
				end,
				-- callback where you can add custom code when the Zen window closes
				on_close = function()
					vim.wo.wrap = false
					vim.wo.number = true
					vim.wo.rnu = true
					ColorMyPencils()
				end,
			})
		end, { desc = "Toggle zenmode (goyo)" })
	end,
}
