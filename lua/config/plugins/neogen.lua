return {
	{
		"danymat/neogen",
		keys = {
			{ "<Leader>ng", "<Cmd>lua require('neogen').generate()<CR>", desc = "Toggle Pin" },
		},
		opts = {
			languages = {
				lua = {
					template = {
						annotation_convention = "emmylua", -- for a full list of annotation_conventions, see supported-languages below
					},
				},
			},
		},
		config = function(_, opts)
			require("neogen").setup(opts)
		end,
	},
	{
		"Zeioth/dooku.nvim",
		event = "VeryLazy",
		opts = {
			-- your config options here
			browser_cmd = "xdg-open", -- write your internet browser here. If unset, it will attempt to detect it automatically.

			-- automations
			on_bufwrite_generate = false, -- auto run :DookuGenerate when a buffer is written.
			on_generate_open = true, -- auto open when running :DookuGenerate. This options is not triggered by on_bufwrite_generate.
			auto_setup = true, -- auto download a config for the generator if it doesn't exist in the project.

			-- notifications
			on_generate_notification = true,
			on_open_notification = true,
		},
	},
}
