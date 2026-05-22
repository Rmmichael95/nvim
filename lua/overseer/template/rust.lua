-- lua/overseer/template/rust.lua
-- cargo build / run / test / clippy / check — mirrors the dotnet pattern
return {
	name = "cargo",

	params = {
		subcommand = {
			type = "enum",
			choices = { "build", "run", "test", "clippy", "check" },
			default = "build",
			desc = "cargo subcommand",
			order = 1,
		},
		args = {
			type = "string",
			default = "",
			desc = "Extra args (e.g. --release, -- --nocapture)",
			optional = true,
			order = 2,
		},
		release = {
			type = "boolean",
			default = false,
			desc = "Build in release mode",
			order = 3,
		},
	},

	builder = function(params)
		local cmd_args = { params.subcommand }
		if params.release then
			table.insert(cmd_args, "--release")
		end
		if params.args ~= "" then
			for arg in params.args:gmatch("%S+") do
				table.insert(cmd_args, arg)
			end
		end

		return {
			cmd = { "cargo" },
			args = cmd_args,
			components = {
				{
					"on_output_quickfix",
					open_on_match = true,
					set_diagnostics = true,
					-- rustc error format: src/main.rs:10:5: error[E0...]: ...
					errorformat = "%f:%l:%c: %t%*[^ ] %m,%f:%l:%c: %m",
				},
				"on_result_diagnostics",
				{ "on_complete_notify", statuses = { "FAILURE" } },
				"default",
			},
		}
	end,

	condition = {
		callback = function()
			return vim.fn.filereadable(vim.fn.getcwd() .. "/Cargo.toml") == 1
		end,
	},
}
