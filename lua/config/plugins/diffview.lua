return {
	{
		"sindrets/diffview.nvim",
		-- already pulled in by neogit; declare here for keys + config only
		cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles" },
		keys = {
			{ "<leader>gD", "<cmd>DiffviewOpen<CR>", desc = "Diffview Open" },
			{ "<leader>gX", "<cmd>DiffviewClose<CR>", desc = "Diffview Close" },
			{ "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "File History (current)" },
			{ "<leader>gH", "<cmd>DiffviewFileHistory<CR>", desc = "File History (repo)" },
		},
		opts = {
			enhanced_diff_hl = true,
			view = {
				merge_tool = {
					layout = "diff3_mixed",
					disable_diagnostics = true,
				},
			},
			hooks = {
				diff_buf_read = function(bufnr)
					vim.opt_local.wrap = false
					vim.opt_local.list = false
					vim.opt_local.colorcolumn = ""
				end,
			},
		},
	},
}
