return {
	"mason-org/mason.nvim",
	dependencies = {
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		-- ADD: bridges Mason → vim.lsp.enable() after install
		"mason-org/mason-lspconfig.nvim",
	},
	cmd = "Mason",
	keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
	-- build = ":MasonUpdate",
	opts = {
		ensure_installed = {
			-- LSP
			"clangd",
			"css-lsp",
			"html-lsp",
			"bash-language-server",
			"lua-language-server",
			"typescript-language-server",
			"yaml-language-server",
			"r-languageserver",
			"rust-analyzer",
			"vim-language-server",
			"texlab",
			"zls",
			-- C# — roslyn replaces omnisharp
			"roslyn",
			"netcoredbg",
			"csharpier",
			"intelephense",
			-- React / JS
			"js-debug-adapter",
			-- DAP
			"cpptools",
			"debugpy",
			"firefox-debug-adapter",
			"php-debug-adapter",
			-- conform
			"clang-format",
			"prettier",
			"phpcbf",
			"phpactor",
			"stylua",
			"isort",
			"black",
			-- lint
			"codespell",
			"cpplint",
			"phpcs",
			"pylint",
			"eslint_d",
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
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		-- ADD: auto-enable LSP servers after Mason installs them
		require("mason-lspconfig").setup({
			automatic_enable = true,
		})

		require("mason-tool-installer").setup(opts)
	end,
}
