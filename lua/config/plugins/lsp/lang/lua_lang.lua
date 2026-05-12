-- lua/config/plugins/lsp/lang/lua_lang.lua
-- Named lua_lang to avoid collision with the built-in Lua module namespace
local lsp = require("config.util")

lsp.setup("lua_ls", {
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim", "Snacks" },
			},
			completion = {
				callSnippet = "Replace",
			},
			workspace = {
				checkThirdParty = false,
			},
		},
	},
})
