--- lua/config/plugins/lsp/lang/json.lua
--
-- json-lsp gains the full SchemaStore catalog (~800 schemas):
--   package.json, tsconfig, GitHub Actions, Renovate, docker-compose, etc.
-- SchemaStore.nvim is lazy — it only loads when jsonls attaches.
local lsp = require("config.util")

lsp.setup("jsonls", {
  -- jsonls only activates on BufRead/BufNewFile — SchemaStore can afford
  -- to be required here at attach time, not at startup.
  settings = {
    json = {
      format = { enable = true },
      validate = { enable = true },
      -- Schemas are injected lazily so startup isn't slowed
      schemas = require("schemastore").json.schemas(),
    },
  },
  before_init = function(_, config)
    -- Refresh schemas each time a buffer attaches in case SchemaStore updated
    config.settings.json.schemas = require("schemastore").json.schemas()
  end,
})- lua/config/plugins/lsp/lang/json.lua
local lsp = require("config.util")

lsp.setup("jsonls", {
	settings = {
		json = {
			format = { enable = true },
			validate = { enable = true },
		},
	},
})
