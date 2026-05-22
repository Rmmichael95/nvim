-- lua/overseer/template/bash_run.lua
return {
	name = "bash-run",

	params = {
		file = {
			type = "string",
			default = "${file}",
			desc = "Script to run",
			order = 1,
		},
		shellcheck = {
			type = "boolean",
			default = true,
			desc = "Run shellcheck before executing",
			order = 2,
		},
		args = {
			type = "string",
			default = "",
			desc = "Script arguments",
			optional = true,
			order = 3,
		},
	},

	builder = function(params)
		local script_args = {}
		if params.args ~= "" then
			for arg in params.args:gmatch("%S+") do
				table.insert(script_args, arg)
			end
		end

		-- optionally chain shellcheck → bash
		if params.shellcheck and vim.fn.executable("shellcheck") == 1 then
			return {
				cmd = { "bash" },
				args = vim.list_extend(
					{
						"-c",
						"shellcheck " .. vim.fn.shellescape(params.file) .. " && bash " .. vim.fn.shellescape(
							params.file
						) .. " " .. table.concat(script_args, " "),
					},
					{}
				),
				components = {
					{
						"on_output_quickfix",
						open_on_match = true,
						set_diagnostics = true,
						-- shellcheck: file.sh:12:3: SC2086 ...
						errorformat = "%f:%l:%c: %m",
					},
					"on_result_diagnostics",
					{ "on_complete_notify", statuses = { "FAILURE" } },
					"default",
				},
			}
		end

		return {
			cmd = { "bash" },
			args = vim.list_extend({ params.file }, script_args),
			components = {
				{ "on_complete_notify", statuses = { "FAILURE" } },
				"default",
			},
		}
	end,

	condition = {
		callback = function()
			return vim.bo.filetype == "sh" or vim.bo.filetype == "bash"
		end,
	},
}
