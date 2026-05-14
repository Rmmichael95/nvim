-- lua/config/plugins/lsp/lang/markdown.lua
-- Marksman: markdown LSP — wiki-links, go-to-def, completion, document outline
local lsp = require("config.util")

lsp.setup("marksman", {
	filetypes = { "markdown", "markdown.mdx" },
	root_dir = function(fname)
		-- prefer a .marksman.toml or .git root; falls back to file dir
		local util = require("lspconfig.util")
		return util.root_pattern(".marksman.toml", ".git")(fname)
			or util.find_git_ancestor(fname)
			or util.path.dirname(fname)
	end,
	on_attach = function(client, bufnr)
		-- Marksman provides: completion, go-to-definition (wiki-links),
		-- document symbols, hover (front-matter), references
		-- No inlay hints or code lens — nothing to disable
		local map = function(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
		end

		-- Follow a wiki-link or regular md link under cursor
		map("n", "gd", vim.lsp.buf.definition, "Go to link definition")
		-- Show all references to the current heading / file
		map("n", "gr", vim.lsp.buf.references, "References to this heading/file")
	end,
})
