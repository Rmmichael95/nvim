-- ~/.config/nvim/lua/codecompanion/tools/wp_cli.lua

local Job = require("plenary.job")

return {
	name = "wp_cli",
	cmds = {
		desc = "Execute safe local WP-CLI queries to inspect themes, block patterns, and site structural configurations.",
		tools = {
			-- Define the system capabilities exposed directly to the model schema
			{
				name = "execute_command",
				description = "Run a read-only or structural WP-CLI diagnostic command.",
				parameters = {
					type = "object",
					properties = {
						subcommand = {
							type = "string",
							description = "The specific WP-CLI subcommand to execute (e.g., 'theme list', 'pattern list'). Do not include the preceding 'wp' string.",
						},
						args = {
							type = "string",
							description = "Additional command flags (e.g., '--status=active' or '--format=json').",
						},
					},
					required = { "subcommand" },
				},
				-- The actual local background execution engine
				callback = function(self, input)
					local cmd_args = vim.split(input.subcommand, " ")
					if input.args and input.args ~= "" then
						local extra_args = vim.split(input.args, " ")
						for _, arg in ipairs(extra_args) do
							table.insert(cmd_args, arg)
						end
					end

					local output = {}
					local stderr = {}

					-- Safely initialize a local background job process block
					local job = Job:new({
						command = "wp", -- Relies directly on your system's path executable binary
						args = cmd_args,
						on_stdout = function(_, line)
							table.insert(output, line)
						end,
						on_stderr = function(_, line)
							table.insert(stderr, line)
						end,
					})

					job:sync(5000) -- Enforce a strict 5-second processing timeout safeguard

					if #stderr > 0 then
						return { error = table.concat(stderr, "\n") }
					end

					return { output = table.concat(output, "\n") }
				end,
			},
		},
	},
	-- Contextual guidance appended directly to the system prompt engine when this tool is active
	system_prompt = function()
		return [[
You are equipped with the 'wp_cli' tool. Use this skill whenever the user asks you to write patterns or blocks that must perfectly match the active site context. 
CRITICAL LIMITATION: You are only allowed to run inspect/read subcommands ('theme', 'pattern', 'plugin', 'config'). Never issue write destructive commands ('db drop', 'plugin delete') unless the user explicitly orders a structural reset layout change.
]]
	end,
}
