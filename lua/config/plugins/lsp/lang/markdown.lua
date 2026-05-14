-- lua/config/plugins/lsp/lang/markdown.lua
-- Marksman: markdown LSP — wiki-links, go-to-def, completion, document outline
--
-- Prerequisites:
--   1. marksman must be installed — add "marksman" to mason.lua ensure_installed
--      and run :MasonUpdate, OR: paru -S marksman
--   2. Deploy this file to ~/.config/nvim/lua/config/plugins/lsp/lang/markdown.lua
--
-- config.util uses vim.lsp.config + vim.lsp.enable (native Neovim 0.11+ API).
-- root_dir in this API is (bufnr, cb) — call cb() with the path, don't return it.
-- Fallback to file's own directory so marksman attaches with no marker required.
local lsp = require("config.util")

lsp.setup("marksman", {
	filetypes = { "markdown", "markdown.mdx" },

	root_dir = function(bufnr, cb)
		local fname = vim.api.nvim_buf_get_name(bufnr)
		local file_dir = vim.fs.dirname(fname)

		local marker = vim.fs.find({ ".marksman.toml", ".git" }, {
			path = file_dir,
			upward = true,
			stop = vim.uv.os_homedir(),
		})[1]

		cb(marker and vim.fs.dirname(marker) or file_dir)
	end,

	on_attach = function(client, bufnr)
		local map = function(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
		end
		map("n", "gd", vim.lsp.buf.definition, "Go to link definition")
		map("n", "gr", vim.lsp.buf.references, "References to this heading/file")
	end,
})
