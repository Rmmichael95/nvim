return {
	"mason-org/mason.nvim",
	dependencies = {
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		"mason-org/mason-lspconfig.nvim",
	},
	cmd = "Mason",
	keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
	-- build = ":MasonUpdate",
	opts = {
		ensure_installed = {
			-- ── LSP — core ────────────────────────────────────────────────────────
			"bash-language-server", -- lang/bash.lua
			"clangd", -- lang/c_cpp.lua
			"cmake-language-server", -- lang/c_cpp.lua
			"json-lsp", -- lang/json.lua
			"lua-language-server", -- lang/lua_lang.lua
			"perlnavigator", -- lang/perl.lua
			"r-languageserver", -- lang/r_lang.lua
			"rust-analyzer", -- lang/rust.lua
			"vim-language-server", -- lang/system.lua
			"marksman", -- lang/markdown.lua
			"yaml-language-server", -- lang/system.lua
			"zls", -- lang/system.lua
			"systemd-lsp", -- lang/system.lua
			"wasm-language-tools", -- lang/system.lua
			"texlab", -- lang/tex.lua
			"ltex-ls", -- lang/tex.lua
			"typescript-language-server", -- lang/typescript.lua
			"vtsls", -- lang/typescript.lua
			"graphql-language-service-cli", -- lang/graphql.lua
			"prisma-language-server", -- lang/prisma.lua
			-- ── LSP — SQL ─────────────────────────────────────────────────────────
			"sqls", -- lang/sql.lua
			-- ── LSP — web ─────────────────────────────────────────────────────────
			"css-lsp", -- lang/web.lua
			"emmet-language-server", -- lang/web.lua
			"html-lsp", -- lang/web.lua
			"tailwindcss-language-server", -- lang/web.lua
			-- ── LSP — PHP ─────────────────────────────────────────────────────────
			"intelephense", -- lang/php.lua
			"phpactor", -- lang/php.lua
			-- ── LSP — Python ──────────────────────────────────────────────────────
			"pyright", -- lang/python.lua
			"ruff", -- lang/python.lua, conform.lua
			-- ── LSP — C# ──────────────────────────────────────────────────────────
			"roslyn", -- lang/cs.lua
			-- ── DAP ───────────────────────────────────────────────────────────────
			"netcoredbg", -- dap.lua (cs, fsharp, vb)
			"cpptools", -- dap.lua (c, cpp)
			"codelldb", -- dap.lua (rust)
			"debugpy", -- dap.lua (python)
			"js-debug-adapter", -- dap.lua (typescript, javascript, node, chrome)
			"firefox-debug-adapter", -- dap.lua (typescriptreact)
			"perl-debug-adapter", -- dap.lua (perl)
			"php-debug-adapter", -- dap.lua (php)
			-- ── conform ───────────────────────────────────────────────────────────
			"clang-format", -- conform.lua (c, cpp)
			"prettier", -- conform.lua (js, ts, css, html, json, yaml, graphql, markdown)
			"sql-formatter", -- conform.lua (sql, mysql)
			"csharpier", -- conform.lua (cs, cshtml, razor)
			"phpcbf", -- conform.lua (php)
			"stylua", -- conform.lua (lua)
			"isort", -- conform.lua (python)
			"black", -- conform.lua (python)
			-- ── nvim-lint ─────────────────────────────────────────────────────────
			"codespell", -- nvim-lint.lua (*)
			"cpplint", -- nvim-lint.lua (c, cpp)
			"pylint", -- nvim-lint.lua (python)
			"eslint_d", -- nvim-lint.lua (js, ts, jsx, tsx, graphql, svelte)
			"phpcs", -- nvim-lint.lua (php)
			"markdownlint-cli2", -- nvim-lint.lua (markdown), conform.lua (markdown)
			"markdown-toc", -- conform.lua (markdown)
		},
	},
	config = function(_, opts)
		require("mason").setup({
			-- ADD: Crashdummyy registry for roslyn
			registries = {
				"github:Crashdummyy/mason-registry",
				"github:mason-org/mason-registry",
			},
			ui = {
				border = "rounded",
				icons = {
					package_installed = "",
					package_pending = "",
					package_uninstalled = "",
				},
			},
		})

		-- ADD: auto-enable LSP servers after Mason installs them
		require("mason-lspconfig").setup({
			automatic_enable = false,
		})

		require("mason-tool-installer").setup(opts)
	end,
}
