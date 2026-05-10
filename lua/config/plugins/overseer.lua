return {
	{
		"stevearc/overseer.nvim",
		cmd = { "OverseerRun", "OverseerToggle" },
		keys = {
			{
				"<leader>M",
				"<Cmd>OverseerRun dotnet build<CR>",
				desc = "dotnet build",
			},
			{
				"<leader><CR>",
				function()
					local tasks = require("overseer").list_tasks({ recent_first = true })
					if #tasks > 0 then
						require("overseer").run_action(tasks[1], "restart")
					end
				end,
				desc = "Restart last task",
			},
			{ "<leader>ob", "<Cmd>OverseerRun<CR>", desc = "Overseer: pick template" },
			{ "<leader>ot", "<Cmd>OverseerToggle<CR>", desc = "Overseer: toggle panel" },
		},
		opts = {
			strategy = "terminal",
			templates = { "builtin", "dotnet_build", "dotnet_watch" },
			template_dirs = { "overseer.template" },
			auto_detect_success_color = true,
			dap = true, -- lets overseer fire preLaunchTask from .vscode/launch.json
			task_list = {
				default_detail = 1,
				max_width = { 100, 0.2 },
				min_width = { 40, 0.1 },
				max_height = { 20, 0.1 },
				min_height = 8,
				separator = "────────────────────────────────────────",
				direction = "bottom",
				bindings = {
					["?"] = "ShowHelp",
					["g?"] = "ShowHelp",
					["<CR>"] = "RunAction",
					["<C-e>"] = "Edit",
					["o"] = "Open",
					["<C-v>"] = "OpenVsplit",
					["<C-s>"] = "OpenSplit",
					["<C-f>"] = "OpenFloat",
					["<C-q>"] = "OpenQuickFix",
					["p"] = "TogglePreview",
					["<C-l>"] = "IncreaseDetail",
					["<C-h>"] = "DecreaseDetail",
					["L"] = "IncreaseAllDetail",
					["H"] = "DecreaseAllDetail",
					["["] = "DecreaseWidth",
					["]"] = "IncreaseWidth",
					["{"] = "PrevTask",
					["}"] = "NextTask",
					["<C-k>"] = "ScrollOutputUp",
					["<C-j>"] = "ScrollOutputDown",
					["q"] = "Close",
				},
			},
		},
		config = function(_, opts)
			require("overseer").setup(opts)
		end,
	},
}
