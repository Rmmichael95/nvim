return {
	name = "dotnet build",
	builder = function()
		return {
			cmd = { "dotnet" },
			args = { "build" },
			components = {
				{ "on_output_quickfix", open_on_match = true },
				"on_result_diagnostics",
				"default",
			},
		}
	end,
	condition = {
		callback = function()
			return #vim.fn.glob("*.sln", false, true) > 0 or #vim.fn.glob("*.csproj", false, true) > 0
		end,
	},
}
