-- lua/config/plugins/lsp/lang/web.lua
local lsp = require("config.util")

-- CSS / SCSS / Less
lsp.setup("cssls", {
	filetypes = { "css", "scss", "less" },
	settings = {
		css = { validate = true, lint = { unknownAtRules = "ignore" } },
		scss = { validate = true, lint = { unknownAtRules = "ignore" } },
		less = { validate = true, lint = { unknownAtRules = "ignore" } },
	},
})

-- HTML
lsp.setup("html", {
	filetypes = { "html", "templ" },
})

-- Emmet
lsp.setup("emmet-language-server", {
	cmd = { vim.fn.stdpath("data") .. "/mason/bin/emmet-language-server", "--stdio" },
	filetypes = {
		"html",
		"css",
		"scss",
		"sass",
		"less",
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
		"php",
		"svelte",
		"vue",
	},
	init_options = {
		includeLanguages = {
			["javascript.jsx"] = "javascriptreact",
			["typescript.tsx"] = "typescriptreact",
		},
	},
})

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
				svelte = "html",
				php = "html",
			},
			experimental = {
				classRegex = {
					{ "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
					{ "tv\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
					{ "cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
					{ "cn\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
					{ "clsx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
					{ "twMerge\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
					"class:([\\w\\d\\-/:]+)",
				},
			},
			files = {
				exclude = {
					"**/.git/**",
					"**/node_modules/**",
					"**/.next/**",
					"**/dist/**",
					"**/.cache/**",
				},
			},
			validate = true,
		},
	},
})

lsp.setup("graphql", {
	filetypes = { "graphql", "gql", "typescriptreact", "javascriptreact" },
	root_dir = function(bufnr, cb)
		local fname = vim.api.nvim_buf_get_name(bufnr)
		local found = vim.fs.find({
			".graphqlrc",
			".graphqlrc.json",
			".graphqlrc.yml",
			".graphqlrc.yaml",
			"graphql.config.js",
			"graphql.config.ts",
			"graphql.config.json",
		}, { path = vim.fs.dirname(fname), upward = true, stop = vim.uv.os_homedir() })[1]
		if found then
			cb(vim.fs.dirname(found))
		end
	end,
})

lsp.setup("sqls", {
	settings = {
		sqls = {
			connections = {
				{
					driver = "mysql",
					dataSourceName = "admin:password@tcp(localhost:3306)/",
				},
			},
		},
	},
})

-- Svelte (disabled by default)
-- lsp.setup("svelte", {
--   filetypes = { "svelte" },
--   root_dir = function(bufnr, cb)
--     local fname = vim.api.nvim_buf_get_name(bufnr)
--     local found = vim.fs.find(
--       { "svelte.config.js", "svelte.config.ts", "svelte.config.mjs" },
--       { path = vim.fs.dirname(fname), upward = true, stop = vim.uv.os_homedir() }
--     )[1]
--     if found then cb(vim.fs.dirname(found)) end
--   end,
--   settings = {
--     typescript = {
--       -- Point svelte-ls at the project's own tsserver so <script lang="ts">
--       -- gets real type diagnostics, not silence
--       tsdk = vim.fn.getcwd() .. "/node_modules/typescript/lib",
--     },
--   },
-- })
