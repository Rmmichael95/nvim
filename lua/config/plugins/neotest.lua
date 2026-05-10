return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"Nsidorenco/neotest-vstest", -- dotnet via VS Test Platform
		},
		keys = {
			{
				"<leader>tt",
				function()
					require("neotest").run.run()
				end,
				desc = "Run nearest test",
			},
			{
				"<leader>tf",
				function()
					require("neotest").run.run(vim.fn.expand("%"))
				end,
				desc = "Run file tests",
			},
			{
				"<leader>tl",
				function()
					require("neotest").run.run_last()
				end,
				desc = "Re-run last test",
			},
			{
				"<leader>ts",
				function()
					require("neotest").summary.toggle()
				end,
				desc = "Test summary",
			},
			{
				"<leader>to",
				function()
					require("neotest").output_panel.toggle()
				end,
				desc = "Test output panel",
			},
			{
				"<leader>td",
				function()
					require("neotest").run.run({ strategy = "dap" })
				end,
				desc = "Debug nearest test",
			},
		},
		config = function()
			vim.g.neotest_vstest = {
				dap_settings = { type = "netcoredbg" },
				timeout_ms = 150000,
			}

			require("neotest").setup({
				adapters = {
					require("neotest-vstest"),
				},
				output = { open_on_run = true },
				status = { virtual_text = true },
				summary = {
					mappings = {
						expand = { "<CR>", "<2-LeftMouse>" },
						run = "r",
						debug = "d",
						stop = "u",
						attach = "a",
						output = "o",
						short = "O",
					},
				},
			})
		end,
	},
}
