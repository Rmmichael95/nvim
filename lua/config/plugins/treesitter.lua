return {
	{
		"neovim-treesitter/nvim-treesitter",
		dependencies = { "neovim-treesitter/treesitter-parser-registry" },
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			-- Minimal setup — install_dir is optional
			require("nvim-treesitter").setup({})

			-- Parsers to pre-install (registry auto-discovers the rest via auto_install)
			require("nvim-treesitter").install({
				"bash",
				"c",
				"cpp",
				"css",
				"html",
				"javascript",
				"typescript",
				"json",
				"lua",
				"markdown",
				"markdown_inline",
				"python",
				"rust",
				"zig",
				"vim",
				"vimdoc",
				"yaml",
				"sql",
				"c_sharp",
				"tsx",
				"graphql",
				"php",
				"perl",
				"r",
				"toml",
				"razor",
			})

			-- Features are now enabled per-FileType via native Neovim APIs
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("treesitter_features", { clear = true }),
				callback = function(ev)
					local ok = pcall(vim.treesitter.start, ev.buf)
					if not ok then
						return
					end -- get_parser() now returns nil gracefully

					-- Treesitter folds (buffer-scoped via [0][0] to avoid window bleed)
					vim.wo[0][0].foldmethod = "expr"
					vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"

					-- Treesitter indentation (experimental but solid for your langs)
					vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
		end,
	},
	{
		"cameron-wags/rainbow_csv.nvim",
		config = true,
		ft = {
			"csv",
			"tsv",
			"csv_semicolon",
			"csv_whitespace",
			"csv_pipe",
			"rfc_csv",
			"rfc_semicolon",
		},
		cmd = {
			"RainbowDelim",
			"RainbowDelimSimple",
			"RainbowDelimQuoted",
			"RainbowMultiDelim",
		},
	},
}
