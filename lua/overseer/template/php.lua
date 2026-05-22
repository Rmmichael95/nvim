-- lua/overseer/template/php.lua
return {
	name = "php",

	params = {
		subcommand = {
			type = "enum",
			choices = { "serve", "artisan", "composer", "test" },
			default = "serve",
			desc = "PHP task",
			order = 1,
		},
		args = {
			type = "string",
			default = "",
			desc = "Extra args (e.g. artisan migrate, composer require foo/bar)",
			optional = true,
			order = 2,
		},
	},

	builder = function(params)
		local extra = {}
		if params.args ~= "" then
			for arg in params.args:gmatch("%S+") do
				table.insert(extra, arg)
			end
		end

		local cmd, cmd_args

		if params.subcommand == "serve" then
			-- Laravel dev server; falls back to php -S for plain PHP
			if vim.fn.filereadable("artisan") == 1 then
				cmd = "php"
				cmd_args = vim.list_extend({ "artisan", "serve" }, extra)
			else
				cmd = "php"
				cmd_args = vim.list_extend({ "-S", "localhost:8000" }, extra)
			end
		elseif params.subcommand == "artisan" then
			cmd = "php"
			cmd_args = vim.list_extend({ "artisan" }, extra)
		elseif params.subcommand == "composer" then
			cmd = "composer"
			cmd_args = extra
		elseif params.subcommand == "test" then
			if vim.fn.filereadable("artisan") == 1 then
				cmd = "php"
				cmd_args = vim.list_extend({ "artisan", "test", "--colors=always" }, extra)
			else
				cmd = vim.fn.exepath("phpunit") or "./vendor/bin/phpunit"
				cmd_args = extra
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
				},
				"on_result_diagnostics",
				{ "on_complete_notify", statuses = { "FAILURE" } },
				"default",
			},
		}
	end,

	condition = {
		callback = function()
			return vim.fn.filereadable(vim.fn.getcwd() .. "/composer.json") == 1 or vim.bo.filetype == "php"
		end,
	},
}
