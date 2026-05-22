-- lua/overseer/template/python.lua
return {
	name = "python",

	params = {
		subcommand = {
			type = "enum",
			choices = { "run", "pytest", "ruff-check", "ruff-fix" },
			default = "run",
			desc = "Python task",
			order = 1,
		},
		file = {
			type = "string",
			default = "${file}",
			desc = "File to run (ignored for pytest/ruff)",
			optional = true,
			order = 2,
		},
		args = {
			type = "string",
			default = "",
			desc = "Extra args",
			optional = true,
			order = 3,
		},
	},

	builder = function(params)
		-- resolve the python executable, honouring venvs
		local python = (function()
			local venv = vim.fn.getcwd() .. "/.venv/bin/python"
			if vim.fn.executable(venv) == 1 then
				return venv
			end
			venv = vim.fn.getcwd() .. "/venv/bin/python"
			if vim.fn.executable(venv) == 1 then
				return venv
			end
			return vim.fn.exepath("python3") or "python"
		end)()

		local cmd, cmd_args

		if params.subcommand == "run" then
			cmd = python
			cmd_args = { params.file }
		elseif params.subcommand == "pytest" then
			cmd = python
			cmd_args = { "-m", "pytest", "-v" }
		elseif params.subcommand == "ruff-check" then
			cmd = vim.fn.stdpath("data") .. "/mason/bin/ruff"
			cmd_args = { "check", "." }
		elseif params.subcommand == "ruff-fix" then
			cmd = vim.fn.stdpath("data") .. "/mason/bin/ruff"
			cmd_args = { "check", "--fix", "." }
		end

		if params.args ~= "" then
			for arg in params.args:gmatch("%S+") do
				table.insert(cmd_args, arg)
			end
		end

		return {
			cmd = { cmd },
			args = cmd_args,
			components = {
				{
					"on_output_quickfix",
					open_on_match = true,
					set_diagnostics = true,
					-- Python traceback: File "foo.py", line 42, in bar
					errorformat = 'File "%f"\\, line %l\\, in %m,%f:%l:%c: %t%*[^ ] %m',
				},
				"on_result_diagnostics",
				{ "on_complete_notify", statuses = { "FAILURE" } },
				"default",
			},
		}
	end,

	condition = {
		callback = function()
			return vim.fn.filereadable(vim.fn.getcwd() .. "/pyproject.toml") == 1
				or vim.fn.filereadable(vim.fn.getcwd() .. "/setup.py") == 1
				or vim.fn.filereadable(vim.fn.getcwd() .. "/requirements.txt") == 1
				or vim.bo.filetype == "python"
		end,
	},
}
