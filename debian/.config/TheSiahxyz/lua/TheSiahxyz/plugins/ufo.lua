return {
	"kevinhwang91/nvim-ufo",
	dependencies = { "kevinhwang91/promise-async" },
	cmd = {
		"UfoEnable",
		"UfoDisable",
		"UfoInspect",
		"UfoAttach",
		"UfoDetach",
		"UfoEnableFold",
		"UfoDisableFold",
	},
	config = function()
		vim.o.foldcolumn = "1"
		vim.o.foldlevel = 99
		vim.o.foldlevelstart = 99
		vim.o.foldenable = true

		local caps = vim.lsp.protocol.make_client_capabilities()
		caps.textDocument.foldingRange = { dynamicRegistration = false, lineFoldingOnly = true }
		local ok_cmp, cmp = pcall(require, "cmp_nvim_lsp")
		if ok_cmp then
			caps = cmp.default_capabilities(caps)
		end
		local lsp_util = require("lspconfig.util")
		lsp_util.default_config = lsp_util.default_config or {}
		lsp_util.default_config.capabilities =
			vim.tbl_deep_extend("force", lsp_util.default_config.capabilities or {}, caps)

		local ftMap = {
			vim = "indent",
			python = { "indent" },
			git = "",
			markdown = { "treesitter", "indent" },
		}

		local function chain_selector(bufnr)
			local ufo = require("ufo")
			local Promise = require("promise")
			local function fallback(err, provider)
				if type(err) == "string" and err:match("UfoFallbackException") then
					return ufo.getFolds(bufnr, provider)
				else
					return Promise.reject(err)
				end
			end
			return require("ufo")
				.getFolds(bufnr, "lsp")
				:catch(function(err)
					return fallback(err, "treesitter")
				end)
				:catch(function(err)
					return fallback(err, "indent")
				end)
		end

		local function fold_virt_text_handler(virtText, lnum, endLnum, width, truncate)
			local newVirtText = {}
			local suffix = (" 󰁂 %d "):format(endLnum - lnum)
			local sufWidth = vim.fn.strdisplaywidth(suffix)
			local targetWidth = width - sufWidth
			local curWidth = 0
			for _, chunk in ipairs(virtText) do
				local text, hl = chunk[1], chunk[2]
				local chunkWidth = vim.fn.strdisplaywidth(text)
				if targetWidth > curWidth + chunkWidth then
					table.insert(newVirtText, { text, hl })
				else
					local truncated = truncate(text, targetWidth - curWidth)
					table.insert(newVirtText, { truncated, hl })
					chunkWidth = vim.fn.strdisplaywidth(truncated)
					if curWidth + chunkWidth < targetWidth then
						suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
					end
					break
				end
				curWidth = curWidth + chunkWidth
			end
			table.insert(newVirtText, { suffix, "MoreMsg" })
			return newVirtText
		end

		local function peek_or_hover()
			local ufo = require("ufo")
			local winid = ufo.peekFoldedLinesUnderCursor()
			if winid then
				local bufnr = vim.api.nvim_win_get_buf(winid)
				for _, k in ipairs({ "a", "i", "o", "A", "I", "O", "gd", "gr" }) do
					vim.keymap.set("n", k, "<CR>" .. k, { noremap = false, buffer = bufnr })
				end
			else
				if vim.lsp.buf.hover then
					vim.lsp.buf.hover()
				end
			end
		end

		local function go_prev_and_peek()
			require("ufo").goPreviousClosedFold()
			require("ufo").peekFoldedLinesUnderCursor()
		end

		local function go_next_and_peek()
			require("ufo").goNextClosedFold()
			require("ufo").peekFoldedLinesUnderCursor()
		end

		local function apply_folds_then_close_all(providerName)
			require("async")(function()
				local bufnr = vim.api.nvim_get_current_buf()
				require("ufo").attach(bufnr)
				local ranges = await(require("ufo").getFolds(bufnr, providerName))
				if not vim.tbl_isempty(ranges) then
					if require("ufo").applyFolds(bufnr, ranges) then
						require("ufo").closeAllFolds()
					end
				end
			end)
		end

		require("ufo").setup({
			provider_selector = function(bufnr, filetype, buftype)
				return ftMap[filetype] or chain_selector
			end,
			fold_virt_text_handler = fold_virt_text_handler,
			enable_get_fold_virt_text = true,
		})

		vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
		vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
		vim.keymap.set("n", "zp", peek_or_hover, { desc = "Peek folded / LSP hover" })
		vim.keymap.set("n", "[z", go_prev_and_peek, { desc = "Prev fold & peek" })
		vim.keymap.set("n", "]z", go_next_and_peek, { desc = "Next fold & peek" })
		vim.keymap.set("n", "<leader>za", function()
			apply_folds_then_close_all("lsp")
		end, { desc = "Apply LSP folds & close all" })
	end,
}
