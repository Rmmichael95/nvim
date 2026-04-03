return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"theHamsta/nvim-dap-virtual-text",
			"williamboman/mason.nvim",
			"jay-babu/mason-nvim-dap.nvim",
			"folke/lazydev.nvim",
		},
		keys = {
			-- set keybinds
			{
				"`b",
				function()
					local dap = require("dap")
					dap.toggle_breakpoint()
				end,
				-- configure svelte server
				desc = "Toggle breakpoint",
			},
			{
				"`c",
				function()
					local dap = require("dap")
					dap.continue()
				end,
				desc = "DAP continue",
			},
			{
				"`i",
				function()
					local dap = require("dap")
					dap.step_into()
				end,
				desc = "DAP step into",
			},
			{
				"`s",
				function()
					local dap = require("dap")
					dap.step_over()
				end,
				desc = "DAP step over",
			},
			{
				"`o",
				function()
					local dap = require("dap")
					dap.step_out()
				end,
				desc = "DAP step out",
			},
			{
				"`p",
				function()
					local dap = require("dap")
					dap.step_back()
				end,
				desc = "DAP step back",
			},
			{
				"`h",
				function()
					local dap = require("dap")
					dap.run_to_cursor()
				end,
				desc = "DAP run to cursor",
			},
			{
				"`r",
				function()
					local dap = require("dap")
					dap.restart()
				end,
				desc = "DAP restart",
			},
			{
				"`t",
				function()
					local ui = require("dapui")
					ui.toggle()
				end,
				desc = "DAP-UI toggle",
			},
			{
				"`?",
				function()
					local ui = require("dapui")
					ui.eval(nil, { enter = true })
				end,
				desc = "DAP eval under cursor",
			},
		},
		opts = {
			enabled = true, -- enable this plugin (the default)
			enabled_commands = true, -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
			highlight_changed_variables = true, -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
			highlight_new_as_changed = false, -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
			show_stop_reason = true, -- show stop reason when stopped for exceptions
			commented = false, -- prefix virtual text with comment string
			only_first_definition = true, -- only show virtual text at first definition (if there are multiple)
			all_references = false, -- show virtual text on all all references of the variable (not only definitions)
			clear_on_continue = false, -- clear virtual text on "continue" (might cause flickering when stepping)
			--- A callback that determines how a variable is displayed or whether it should be omitted
			--- @param variable Variable https://microsoft.github.io/debug-adapter-protocol/specification#Types_Variable
			--- @param buf number
			--- @param stackframe dap.StackFrame https://microsoft.github.io/debug-adapter-protocol/specification#Types_StackFrame
			--- @param node userdata tree-sitter node identified as variable definition of reference (see `:h tsnode`)
			--- @param options nvim_dap_virtual_text_options Current options for nvim-dap-virtual-text
			--- @return string|nil A text how the virtual text should be displayed or nil, if this variable shouldn't be displayed
			display_callback = function(variable, buf, stackframe, node, options)
				-- by default, strip out new line characters
				if options.virt_text_pos == "inline" then
					return " = " .. variable.value:gsub("%s+", " ")
				else
					return variable.name .. " = " .. variable.value:gsub("%s+", " ")
				end
			end,
			-- position of virtual text, see `:h nvim_buf_set_extmark()`, default tries to inline the virtual text. Use 'eol' to set to end of line
			virt_text_pos = vim.fn.has("nvim-0.10") == 1 and "inline" or "eol",

			-- experimental features:
			all_frames = false, -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
			virt_lines = false, -- show virtual lines instead of virtual text (will flicker!)
			virt_text_win_col = nil, -- position the virtual text at a fixed window column (starting from the first text column) ,
		},
		config = function(_, opts)
			local dap, ui = require("dap"), require("dapui")
			ui.setup()

			dap.adapters.firefox = {
				type = "executable",
				command = "node",
				args = {
					vim.fn.stdpath("data") .. "/mason/bin/firefox-debug-adapter",
				},
			}

			dap.configurations.typescriptreact = {
				{
					name = "Debug with Firefox",
					type = "firefox",
					request = "launch",
					reAttach = true,
					url = "http://localhost:3000",
					webRoot = "${workspaceFolder}",
					firefoxExecutable = "/usr/bin/floorp", -- adjust to your Firefox executable path
				},
			}

			dap.adapters.perl = {
				type = "executable",
				command = vim.env.MASON .. "/bin/perl-debug-adapter",
				-- command = "/home/ryanm/.local/share/nvim/mason/bin/perl-debug-adapter",
				args = {},
			}

			dap.configurations.perl = {
				{
					type = "perl",
					request = "launch",
					name = "Launch Perl",
					program = "${file}", -- The current file being debugged
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
				},
			}
			-- dap.set_log_level("TRACE")

			-- configure svelte server
			dap.listeners.before.attach.dapui_config = function()
				ui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				ui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				ui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				ui.close()
			end

			require("nvim-dap-virtual-text").setup(opts)

			local path = require("mason-registry").get_package("php-debug-adapter"):get_install_path()
			dap.adapters.php = {
				type = "executable",
				command = "node",
				args = { path .. "/extension/out/phpDebug.js" },
			}

			if not dap.adapters["netcoredbg"] then
				require("dap").adapters["netcoredbg"] = {
					type = "executable",
					command = vim.fn.exepath("netcoredbg"),
					args = { "--interpreter=vscode" },
					options = {
						detached = false,
					},
				}
			end
			for _, lang in ipairs({ "cs", "fsharp", "vb" }) do
				if not dap.configurations[lang] then
					dap.configurations[lang] = {
						{
							type = "netcoredbg",
							name = "Launch file",
							request = "launch",
							---@diagnostic disable-next-line: redundant-parameter
							program = function()
								return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/", "file")
							end,
							cwd = "${workspaceFolder}",
						},
					}
				end
			end
		end,
	},
	{
		"nvim-neotest/neotest",
		optional = true,
		dependencies = {
			"Issafalcon/neotest-dotnet",
		},
		opts = {
			adapters = {
				["neotest-dotnet"] = {
					-- Here we can set options for neotest-dotnet
				},
			},
		},
	},
}
