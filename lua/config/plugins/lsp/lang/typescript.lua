-- lua/config/plugins/lsp/lang/typescript.lua
local lsp = require("config.util")

local ts_inlay_hints = {
	includeInlayParameterNameHints = "all",
	includeInlayParameterNameHintsWhenArgumentMatchesName = false,
	includeInlayFunctionParameterTypeHints = true,
	includeInlayVariableTypeHints = true,
	includeInlayVariableTypeHintsWhenTypeMatchesName = false,
	includeInlayPropertyDeclarationTypeHints = true,
	includeInlayFunctionLikeReturnTypeHints = true,
	includeInlayEnumMemberValueHints = true,
}

lsp.setup("ts_ls", {
	filetypes = {
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
	},
	settings = {
		typescript = {
			inlayHints = ts_inlay_hints,
			preferences = { importModuleSpecifier = "relative" },
			suggest = { completeFunctionCalls = true },
		},
		javascript = {
			inlayHints = ts_inlay_hints,
			suggest = { completeFunctionCalls = true },
		},
	},
})

-- ─────────────────────────────────────────────────────────────────────────────
-- vtsls — VS Code TypeScript language features, bundled as an LSP server
--
-- Why: vtsls runs the same tsserver that powers VS Code's TS extension.
-- On large Next.js app-router projects it is measurably faster than ts_ls and
-- has first-class awareness of Next.js server/client component boundaries,
-- React Server Actions, and the app-router type augmentations shipped with
-- `@types/react` 18+.
--
-- Coexistence strategy: vtsls only attaches when a next.config.* is found
-- at or above the buffer's directory. On non-Next.js TypeScript projects ts_ls
-- continues to handle everything — the two servers never attach to the same
-- buffer simultaneously.
--
-- Mason: add "vtsls" to ensure_installed in mason.lua
-- ─────────────────────────────────────────────────────────────────────────────

lsp.setup("vtsls", {
	filetypes = {
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
	},

	-- Only attach inside a Next.js project tree.
	-- The native Neovim 0.11 root_dir API: call cb(path) to attach, call
	-- cb() with no args (or simply not call it) to silently skip attachment.
	root_dir = function(bufnr, cb)
		local fname = vim.api.nvim_buf_get_name(bufnr)
		local markers = {
			"next.config.js",
			"next.config.ts",
			"next.config.mjs",
			"next.config.cjs",
		}
		local found = vim.fs.find(markers, {
			path = vim.fs.dirname(fname),
			upward = true,
			stop = vim.uv.os_homedir(),
		})[1]
		if found then
			cb(vim.fs.dirname(found))
		end
		-- No cb() call → vtsls skips this buffer → ts_ls wins instead
	end,

	settings = {
		settings = {
			typescript = {
				inlayHints = ts_inlay_hints,
				preferences = { importModuleSpecifier = "relative" },
				suggest = { completeFunctionCalls = true },
			},
			javascript = {
				inlayHints = ts_inlay_hints,
				suggest = { completeFunctionCalls = true },
			},
		},
		vtsls = {
			-- Move-to-file refactor (appears in code actions alongside extract)
			enableMoveToFileCodeAction = true,
			-- Prefer the project's own tsdk over the bundled one.
			-- This matters for Next.js: the project's tsserver knows about the
			-- Next.js tsconfig paths and module augmentations in node_modules.
			autoUseWorkspaceTsdk = true,
			experimental = {
				completion = {
					-- Server-side fuzzy match is faster than client re-ranking on
					-- large projects where completion lists are in the thousands.
					enableServerSideFuzzyMatch = true,
				},
			},
		},
	},
})
