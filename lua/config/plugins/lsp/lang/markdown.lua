-- lua/config/plugins/lsp/lang/markdown.lua
-- Marksman: markdown LSP — wiki-links, go-to-def, completion, document outline
local lsp = require("config.util")

lsp.setup("marksman", {
	filetypes = { "markdown", "markdown.mdx" },
	root_dir = function(fname)
		-- FIX: util.path.dirname is deprecated in newer lspconfig and returns
		-- unexpected types. Use vim.fs.dirname (core Neovim, always returns string).
		local util = require("lspconfig.util")
		return util.root_pattern(".marksman.toml", ".git")(fname) or vim.fs.dirname(fname)
	end,
	on_attach = function(client, bufnr)
		local map = function(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
		end

		-- Follow a wiki-link or regular md link under cursor
		map("n", "gd", vim.lsp.buf.definition, "Go to link definition")
		-- Show all references to the current heading / file
		map("n", "gr", vim.lsp.buf.references, "References to this heading/file")
	end,
})
