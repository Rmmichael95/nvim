return {
	{
		"danymat/neogen",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		-- ─── Keymaps ────────────────────────────────────────────────────────────
		-- <Leader>ng  → smart generate (neogen picks the right annotation type)
		-- <Leader>nf  → force function annotation
		-- <Leader>nt  → force type/class annotation
		-- <Leader>nF  → force file-level annotation
		keys = {
			{
				"<Leader>ng",
				function()
					require("neogen").generate()
				end,
				desc = "Neogen: generate annotation",
			},
			{
				"<Leader>nf",
				function()
					require("neogen").generate({ type = "func" })
				end,
				desc = "Neogen: function annotation",
			},
			{
				"<Leader>nt",
				function()
					require("neogen").generate({ type = "type" })
				end,
				desc = "Neogen: type/class annotation",
			},
			{
				"<Leader>nF",
				function()
					require("neogen").generate({ type = "file" })
				end,
				desc = "Neogen: file annotation",
			},
		},
		opts = {
			-- Jump between annotation placeholders with <Tab> inside snippet.
			-- Set to false if you prefer your snippet engine's native <Tab>.
			snippet_engine = "luasnip", -- aligns with your existing LuaSnip setup

			-- ─── Per-language annotation conventions ──────────────────────────
			-- Each entry maps neovim filetype → neogen annotation_convention.
			-- Only filetypes with active LSP servers in your lang/ directory are
			-- listed; anything omitted falls back to neogen's built-in default.
			languages = {

				-- ── Lua ────────────────────────────────────────────────────────
				-- EmmyLua: the standard understood by lua_ls / Lazydev.
				-- Gives you @param, @return, @class, @field with hover docs.
				lua = {
					template = { annotation_convention = "emmylua" },
				},

				-- ── Python ─────────────────────────────────────────────────────
				-- Google style: terse, single-section per block.  Matches Black +
				-- Pyright's preferred hover rendering better than reST or numpy.
				python = {
					template = { annotation_convention = "google_docstrings" },
				},

				-- ── TypeScript & TSX ───────────────────────────────────────────
				-- TSDoc: the TypeScript-native superset of JSDoc.  Understood by
				-- ts_ls, vtsls, and TypeDoc for HTML doc generation via dooku.
				typescript = {
					template = { annotation_convention = "tsdoc" },
				},
				typescriptreact = {
					template = { annotation_convention = "tsdoc" },
				},

				-- ── JavaScript & JSX ───────────────────────────────────────────
				-- JSDoc: universal, understood by ts_ls in JS mode.
				javascript = {
					template = { annotation_convention = "jsdoc" },
				},
				javascriptreact = {
					template = { annotation_convention = "jsdoc" },
				},

				-- ── C / C++ ────────────────────────────────────────────────────
				-- Doxygen: the standard clangd surfaces in hover + code lens.
				-- Pairs with clang-format (your formatter) and cpplint (linter).
				c = {
					template = { annotation_convention = "doxygen" },
				},
				cpp = {
					template = { annotation_convention = "doxygen" },
				},

				-- ── Rust ───────────────────────────────────────────────────────
				-- rustdoc: native Rust doc-comment style (/// … //! …).
				-- rust-analyzer renders these live in hover and inlay hints.
				rust = {
					template = { annotation_convention = "rustdoc" },
				},

				-- ── PHP ────────────────────────────────────────────────────────
				-- PHPDoc: consumed by both intelephense and phpactor for
				-- type-narrowing, completions, and dooku HTML output.
				php = {
					template = { annotation_convention = "phpdoc" },
				},

				-- ── C# ─────────────────────────────────────────────────────────
				-- xmldoc: the .NET/Roslyn standard (/// <summary>…</summary>).
				-- Roslyn surfaces these in hover exactly as VS does.
				cs = {
					template = { annotation_convention = "xmldoc" },
				},

				-- ── R ──────────────────────────────────────────────────────────
				-- roxygen2: the universal R documentation standard.
				-- R.nvim + r_language_server both understand @param / @return tags.
				r = {
					template = { annotation_convention = "roxygen2" },
				},
			},
		},
		config = function(_, opts)
			require("neogen").setup(opts)
		end,
	},

	-- ─── dooku (doc generator / HTML preview) ───────────────────────────────
	-- Unchanged — kept here so the two tools remain co-located and obvious.
	{
		"Zeioth/dooku.nvim",
		event = "VeryLazy",
		opts = {
			browser_cmd = "xdg-open",
			on_bufwrite_generate = false,
			on_generate_open = true,
			auto_setup = true,
			on_generate_notification = true,
			on_open_notification = true,
		},
	},
}
