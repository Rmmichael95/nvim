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
			-- LSP — core
			"bash-language-server", -- bash.lua
			"clangd", -- c_cpp.lua
			"json-lsp", -- json.lua
			"lua-language-server", -- lua_lang.lua
			"perlnavigator", -- perl.lua
			"r-languageserver", -- r_lang.lua
			"rust-analyzer", -- rust.lua
			"vim-language-server", -- system.lua
			"yaml-language-server", -- system.lua
			"zls", -- system.lua
			"systemd-lsp", -- system.lua
			"texlab", -- tex.lua
			"ltex-ls", -- tex.lua        (was missing)
			"typescript-language-server", -- typescript.lua
			-- LSP — web
			"css-lsp", -- web.lua
			"emmet-language-server", -- web.lua
			"html-lsp", -- web.lua
			"tailwindcss-language-server", -- web.lua
			-- LSP — PHP
			"intelephense", -- php.lua
			"phpactor", -- php.lua
			-- LSP — Python
			"pyright", -- python.lua
			"ruff", -- python.lua
			-- C# — roslyn replaces omnisharp
			"roslyn",
			"netcoredbg",
			"csharpier",
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
