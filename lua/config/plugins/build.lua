return {
	{
		"pianocomposer321/officer.nvim",
		dependencies = "stevearc/overseer.nvim",
		keys = {
			{ "<leader><CR>", "<Cmd>require('user.overseer_util').restart_last_task<CR>" },
			{ "<leader>M", "<Cmd>Make<CR>" },
		},
		cmd = "Make",
		opts = {
			create_mappings = true,
			-- components = { "user.track_history" },
		},
	},
	{
		{
			"stevearc/overseer.nvim",
			opts = {},
			dependencies = "stevearc/overseer.nvim",
			keys = {
				{ "<leader>ob", "<Cmd>OverseerRun<CR>" },
				{ "<leader>ot", "<Cmd>OverseerToggle<CR>" },
			},
		},
	},
}
