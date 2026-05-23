-- lua/config/plugins/schemastore.lua
-- Provides the SchemaStore.nvim catalog to jsonls and yamlls.
-- No setup() call needed — the library is required directly in lang/json.lua
-- and lang/yaml.lua at LSP attach time, so it loads lazily.
return {
	"b0o/SchemaStore.nvim",
	lazy = true,
	version = false, -- SchemaStore doesn't tag releases; track HEAD
}
