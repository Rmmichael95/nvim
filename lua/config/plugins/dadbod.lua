-- lua/config/plugins/dadbod.lua
return {
	"kristijanhusak/vim-dadbod-ui",
	dependencies = {
		{ "tpope/vim-dadbod", lazy = true },
		{ "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
	},
	cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
	keys = {
		{ "<leader>db", "<cmd>DBUIToggle<CR>", desc = "Toggle DB UI" },
		{ "<leader>da", "<cmd>DBUIAddConnection<CR>", desc = "Add DB Connection" },
		{ "<leader>df", "<cmd>DBUIFindBuffer<CR>", desc = "Find DB Buffer" },
	},
	init = function()
		vim.g.db_ui_use_nerd_fonts = 1

		-- Store connections outside of your dotfiles repo (has plaintext URLs)
		vim.g.db_ui_save_location = vim.fn.expand("~/.local/share/db_ui")

		-- Show DB name in the statusline when in a SQL buffer
		vim.g.db_ui_show_database_icon = 1
		vim.g.db_ui_win_position = "left"
		vim.g.db_ui_winwidth = 40

		-- Execute queries with <leader>S in sql buffers (default is <leader>W)
		vim.g.db_ui_execute_on_save = 0 -- Don't auto-run on save
	end,
}
