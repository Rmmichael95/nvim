-- lua/overseer/template/dotnet_watch.lua
--
-- Replaces the previous stub (dotnet watch build / default components only).
--
-- Three variants selected at run-time via a params prompt:
--   run   → dotnet watch run   (hot-reload; ASP.NET Core / console apps)
--   test  → dotnet watch test  (continuous test runner)
--   build → dotnet watch build (build-only; for library projects)
--
-- Output is parsed for MSBuild diagnostics so build errors surface in the
-- quickfix list exactly like the dotnet-build template. The task stays alive
-- until you explicitly kill it (<leader>ot → select task → q).
--
-- Keymap wired in overseer.lua:
--   <leader>W  →  OverseerRun dotnet-watch  (mirrors <leader>M for build)

return {
	name = "dotnet-watch",

	params = {
		subcommand = {
			type = "enum",
			choices = { "run", "test", "build" },
			default = "run",
			desc = "dotnet watch subcommand",
			order = 1,
		},
		args = {
			type = "string",
			default = "",
			desc = "Extra args passed after the subcommand (e.g. --urls http://localhost:5001)",
			optional = true,
			order = 2,
		},
	},

	builder = function(params)
		local cmd_args = { "watch", params.subcommand }

		-- Append any extra args the user typed in the prompt
		if params.args and params.args ~= "" then
			for arg in params.args:gmatch("%S+") do
				table.insert(cmd_args, arg)
			end
		end

		local components = {
			-- MSBuild error/warning → quickfix + diagnostics (same format as dotnet-build)
			{
				"on_output_quickfix",
				open_on_match = true,
				set_diagnostics = true,
				errorformat = "%f(%l\\,%c): %t%*[^ ] %m",
			},
			"on_result_diagnostics",
			-- Keep the panel open between hot-reloads; don't auto-close on success
			-- because the process is intentionally long-running.
			{
				"on_complete_notify",
				statuses = { "FAILURE" }, -- only notify on failure, not on every reload
			},
			"default",
		}

		return {
			cmd = { "dotnet" },
			args = cmd_args,
			components = components,
			-- Hot-reload output is very chatty; show from the start so you can
			-- see "Application started. Press Ctrl+C to shut down." feedback.
			default_component_params = {
				on_output_summarize = { max_lines = 8 },
			},
		}
	end,

	-- Only surface this template when a dotnet project is present
	condition = {
		callback = function()
			return #vim.fn.glob("*.sln", false, true) > 0 or #vim.fn.glob("*.csproj", false, true) > 0
		end,
	},
}
