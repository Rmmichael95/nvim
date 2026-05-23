-- lua/config/plugins/lsp/lang/toml.lua
--
-- taplo: TOML LSP + formatter
--   Covers Cargo.toml (with crate version schema), .cargo/config.toml,
--   pyproject.toml, stylua.toml, and any other TOML config file.
--
-- Mason: add "taplo" to ensure_installed in mason.lua
-- conform: add toml = { "taplo" } to formatters_by_ft
local lsp = require("config.util")

lsp.setup("taplo", {
	filetypes = { "toml" },
	settings = {
		taplo = {
			-- Pull schemas from SchemaStore (covers Cargo.toml, pyproject.toml, etc.)
			schema = {
				enabled = true,
				associations = {
					-- Cargo.toml gets the full crate schema with version completion
					["Cargo.toml"] = "taplo://cargo@unstable.toml",
					["*.cargo/config.toml"] = "taplo://cargo@unstable.toml",
					["pyproject.toml"] = "https://json.schemastore.org/pyproject.json",
					[".taplo.toml"] = "taplo://.taplo.toml",
				},
			},
		},
	},
})
