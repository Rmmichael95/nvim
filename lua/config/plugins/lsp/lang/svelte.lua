-- lua/config/plugins/lsp/lang/svelte.lua
--
-- Svelte toolchain:
--   svelte-language-server  — completions, go-to-def, diagnostics, component props
--   eslint_d                — already wired in nvim-lint.lua for svelte
--   prettier                — already wired in conform.lua for svelte
--
-- Mason: add "svelte-language-server" to ensure_installed in mason.lua
local lsp = require("config.util")

lsp.setup("svelte", {
	filetypes = { "svelte" },
	-- svelte-language-server needs to know about TypeScript so it can type-check
	-- .svelte files that use <script lang="ts">
	settings = {
		svelte = {
			plugin = {
				html = { completions = { enable = true, emmet = false } },
				svelte = {
					defaultScriptLanguage = "ts",
					compilerWarnings = {
						-- suppress noisy a11y warnings if you prefer (remove to enable)
						["a11y-click-events-have-key-events"] = "ignore",
						["a11y-no-static-element-interactions"] = "ignore",
					},
				},
			},
		},
	},
	-- ts_ls / vtsls must restart when a svelte file triggers TS changes.
	-- This on_attach notifies them so they re-read tsconfig.
	on_attach = function(_, bufnr)
		vim.api.nvim_create_autocmd("BufWritePost", {
			buffer = bufnr,
			group = vim.api.nvim_create_augroup("svelte_on_write_" .. bufnr, { clear = true }),
			callback = function(args)
				for _, client in pairs(vim.lsp.get_clients({ bufnr = args.buf })) do
					if client.name == "ts_ls" or client.name == "vtsls" then
						client.notify("$/onDidChangeTsOrJsFile", { uri = args.match })
					end
				end
			end,
		})
	end,
})
