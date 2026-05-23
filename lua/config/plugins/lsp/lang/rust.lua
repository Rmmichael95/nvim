-- lua/config/plugins/lsp/lang/rust.lua
local lsp = require("config.util")

lsp.setup("rust_analyzer", {
	settings = {
		["rust-analyzer"] = {
			-- Run clippy instead of cargo check on save.
			-- Diagnostics surface directly through LSP — no nvim-lint entry needed.
			-- allFeatures ensures feature-gated code is also checked.
			check = {
				command = "clippy",
				extraArgs = { "--all-targets" },
			},
			cargo = {
				allFeatures = true,
				loadOutDirsFromCheck = true,
			},
			-- Inlay hints — show param names, type hints, and chained call types.
			inlayHints = {
				bindingModeHints = { enable = true },
				closureReturnTypeHints = { enable = "with_block" },
				lifetimeElisionHints = { enable = "skip_trivial" },
				parameterHints = { enable = true },
				typeHints = { enable = true },
			},
			procMacro = {
				enable = true,
			},
		},
	},
})
