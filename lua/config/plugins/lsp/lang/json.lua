-- lua/config/plugins/lsp/lang/json.lua
--
-- json-lsp with SchemaStore catalog (~800 schemas):
--   package.json, tsconfig, GitHub Actions, Renovate, docker-compose, etc.
--
-- SchemaStore.nvim (plugins/schemastore.lua) lazy-loads on first require().
local lsp = require("config.util")

lsp.setup("jsonls", {
	settings = {
		json = {
			format = { enable = true },
			validate = { enable = true },
			schemas = require("schemastore").json.schemas(),
		},
	},
})
