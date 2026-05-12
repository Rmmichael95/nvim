-- lua/config/plugins/lsp/lang/json.lua
local lsp = require("config.util")

lsp.setup("jsonls", {
	settings = {
		json = {
			format = { enable = true },
			validate = { enable = true },
		},
	},
})
