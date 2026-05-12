return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"Nsidorenco/neotest-vstest", -- dotnet via VS Test Platform
			"olimorris/neotest-phpunit",
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

			local function neotest_icon(name)
				local ok, mi = pcall(require, "mini.icons")
				if not ok then
					return nil
				end
				local glyph = mi.get("lsp", "neotest_" .. name)
				return glyph
			end

			require("neotest").setup({
				log_level = vim.log.levels.WARN,
				diagnostic = { enabled = true, severity = vim.diagnostic.severity.ERROR },
				consumers = {},
				highlights = {},
				projects = {},
				discovery = { enabled = true, concurrent = 0, filter_dir = nil },
				icons = {
					passed = neotest_icon("passed") or "✓",
					failed = neotest_icon("failed") or "✗",
					running = neotest_icon("running") or "⟳",
					skipped = neotest_icon("skipped") or "s",
					unknown = neotest_icon("unknown") or "?",
					watching = neotest_icon("watching") or "󰈈",
					running_animated = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
					expanded = "▾",
					collapsed = "▸",
					child_prefix = "├",
					child_indent = "│",
					final_child_prefix = "└",
					final_child_indent = " ",
					non_collapsible = "─",
				},
				floating = {
					border = "rounded",
					max_height = 0.6,
					max_width = 0.6,
					options = {},
				},
				quickfix = { enabled = true, open = false },
				strategies = {
					integrated = {
						width = 80,
						height = 40,
					},
				},
				adapters = {
					require("neotest-vstest"),
					require("neotest-phpunit"),
				},
				run = { enabled = true },
				running = { concurrent = true },
				default_strategy = "integrated",
				output = { enabled = true, open_on_run = true },
				output_panel = { enabled = true, open = "botright split | resize 15" },
				status = { enabled = true, virtual_text = true, signs = true },
				state = { enabled = true },
				watch = { enabled = true, symbol_queries = {} },
				summary = {
					enabled = true,
					animated = true,
					follow = true,
					expand_errors = true,
					open = "botright vsplit | vertical resize 50",
					count = true,
					mappings = {
						expand = { "<CR>", "<2-LeftMouse>" },
						expand_all = "e",
						collapse = "c",
						collapse_all = "C",
						run = "r",
						watch = "w",
						debug = "d",
						stop = "u",
						attach = "a",
						output = "o",
						short = "O",
						jumpto = "i",
						jump_err = "I",
						jump_prev = "[",
						jump_next = "]",
						next_failed = "}",
						prev_failed = "{",
						next_sibling = "gj",
						prev_sibling = "gk",
						mark = "m",
						run_marked = "R",
						debug_marked = "D",
						clear_marked = "M",
						target = "t",
						parent = "P",
						clear_target = "<BS>",
					},
				},
			})
		end,
	},
}
