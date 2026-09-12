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
		local cwd = nil

		-- dotnet watch's --project flag has known ordering/parsing quirks when
		-- combined with `test` (see nx-dotnet/nx-dotnet#425). Simpler and more
		-- reliable: cd into the resolved project's own directory instead, where
		-- dotnet watch needs no disambiguation at all.
		if #vim.fn.glob("*.csproj", false, true) == 0 then
			local project
			if params.subcommand == "test" then
				project = vim.fn.glob("**/*.Tests.csproj", false, true)[1]
			end
			if not project then
				local all = vim.fn.glob("**/*.csproj", false, true)
				if #all == 1 then
					project = all[1]
				end
			end
			if project then
				cwd = vim.fn.fnamemodify(project, ":h")
			end
		end

		-- Append any extra args the user typed in the prompt
		if params.args and params.args ~= "" then
			for arg in params.args:gmatch("%S+") do
				table.insert(cmd_args, arg)
			end
		end

		local components = {
			{
				"on_output_quickfix",
				open_on_match = true,
				set_diagnostics = true,
				errorformat = "%f(%l\\,%c): %t%*[^ ] %m",
			},
			"on_result_diagnostics",
			{
				"on_complete_notify",
				statuses = { "FAILURE" },
			},
			"default",
		}

		return {
			cmd = { "dotnet" },
			args = cmd_args,
			cwd = cwd,
			components = components,
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
