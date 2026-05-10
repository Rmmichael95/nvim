return {
	name = "dotnet-watch",
	builder = function()
		return {
			cmd = { "dotnet" },
			args = { "watch", "build" },
			components = { "default" },
		}
	end,
	condition = {
		callback = function()
			return #vim.fn.glob("*.sln", false, true) > 0 or #vim.fn.glob("*.csproj", false, true) > 0
		end,
	},
}
