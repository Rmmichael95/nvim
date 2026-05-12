-- lua/config/plugins/lsp/lang/python.lua
local lsp = require("config.util")

lsp.setup("pyright")

-- Ruff: fast linter/formatter. Disables hover so Pyright handles it.
lsp.setup("ruff", {
	cmd_env = { RUFF_TRACE = "messages" },
	init_options = {
		settings = { logLevel = "error" },
	},
	on_attach = function(client, _)
		-- Defer to Pyright for hover documentation
		client.server_capabilities.hoverProvider = false
	end,
})
