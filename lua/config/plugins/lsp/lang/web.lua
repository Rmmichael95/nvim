-- lua/config/plugins/lsp/lang/web.lua
local lsp = require("config.util")

-- CSS / SCSS / Less
lsp.setup("cssls", {
	filetypes = { "css", "scss", "less" },
	settings = {
		css = { validate = true },
		scss = { validate = true },
		less = { validate = true },
	},
})

-- HTML
lsp.setup("html", {
	filetypes = { "html", "templ", "php" },
})

-- Emmet
lsp.setup("emmet-language-server")
-- lsp.setup("emmet_ls", {  -- legacy fallback if needed
--   filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
--   init_options = { html = { options = { ["bem.enabled"] = true } } },
-- })

-- Tailwind CSS (React + utility function class detection)
lsp.setup("tailwindcss", {
	filetypes = {
		"html",
		"css",
		"scss",
		"less",
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
		"svelte",
		"vue",
		"astro",
		"php",
	},
	settings = {
		tailwindCSS = {
			includeLanguages = {
				typescript = "javascript",
				typescriptreact = "javascript",
				javascriptreact = "javascript",
			},
			experimental = {
				classRegex = {
					{ "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
					{ "cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
					{ "cn\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
					{ "clsx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
					{ "twMerge\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
					"class:([\\w\\d\\-/:]+)",
				},
			},
			validate = true,
		},
	},
})

-- GraphQL (disabled by default — uncomment per project)
-- lsp.setup("graphql", {
--   filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
-- })

-- Svelte (disabled by default)
-- lsp.setup("svelte")
