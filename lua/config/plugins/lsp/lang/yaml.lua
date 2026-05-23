-- lua/config/plugins/lsp/lang/yaml.lua
--
-- yaml-language-server with the full SchemaStore catalog:
--   Kubernetes manifests, GitHub Actions, Helm values, docker-compose,
--   Renovate config, cloud-init, Ansible, and 300+ more.
local lsp = require("config.util")

lsp.setup("yamlls", {
	filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab" },
	settings = {
		redhat = { telemetry = { enabled = false } },
		yaml = {
			keyOrdering = false,
			format = { enable = true },
			validate = true,
			hover = true,
			completion = true,
			schemaStore = {
				-- Disable yamlls's built-in store; SchemaStore.nvim takes over
				enable = false,
				url = "",
			},
			schemas = require("schemastore").yaml.schemas({
				-- Opt-in extras beyond the default catalog
				extra = {
					{
						description = "Local schema override",
						fileMatch = { ".yamllint", ".yamllint.yaml", ".yamllint.yml" },
						name = "yamllint",
						url = "https://json.schemastore.org/yamllint.json",
					},
				},
			}),
		},
	},
})
