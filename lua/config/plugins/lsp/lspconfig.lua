return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"saghen/blink.cmp",
			"williamboman/mason.nvim",
			"folke/lazydev.nvim",
			"echasnovski/mini.icons",
			"p00f/clangd_extensions.nvim",
			"R-nvim/R.nvim",
			"Nsidorenco/neotest-vstest",
			{ "antosha417/nvim-lsp-file-operations", config = true },
		},
		opts = {
			diagnostics = {
				underline = true,
				update_in_insert = false,
				virtual_text = {
					spacing = 4,
					source = "if_many",
					prefix = "icons",
					format = function(diagnostic)
						local msg = diagnostic.message
						if #msg > 80 then
							return msg:sub(1, 77) .. "..."
						end
						return msg
					end,
				},
				severity_sort = true,
				float = {
					border = "rounded",
					source = true,
					max_width = 80,
					wrap = true,
					focusable = true,
					style = "minimal",
				},
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = " ",
						[vim.diagnostic.severity.WARN] = " ",
						[vim.diagnostic.severity.HINT] = "󰠠 ",
						[vim.diagnostic.severity.INFO] = " ",
					},
				},
			},
		},
		config = function(_, opts)
			-- ── Diagnostic signs (pre-0.10 compat) ────────────────────────────
			if vim.fn.has("nvim-0.10.0") == 0 then
				if type(opts.diagnostics.signs) ~= "boolean" then
					for severity, icon in pairs(opts.diagnostics.signs.text) do
						local name = vim.diagnostic.severity[severity]:lower():gsub("^%l", string.upper)
						name = "DiagnosticSign" .. name
						vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
					end
				end
			end

			-- ── Icon prefix (0.10+ uses a function) ───────────────────────────
			if type(opts.diagnostics.virtual_text) == "table" and opts.diagnostics.virtual_text.prefix == "icons" then
				opts.diagnostics.virtual_text.prefix = vim.fn.has("nvim-0.10.0") == 0 and "●"
					or function(diagnostic)
						local icons = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
						for d, icon in pairs(icons) do
							if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
								return icon
							end
						end
					end
			end

			vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

			-- ── Full diagnostic float keymap ───────────────────────────────────
			vim.keymap.set("n", "<leader>e", function()
				vim.diagnostic.open_float(nil, opts.diagnostics.float)
			end, { desc = "Show diagnostic float" })

			-- ── LspAttach — keymaps & features ────────────────────────────────
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					local o = { buffer = ev.buf, silent = true }
					local client = vim.lsp.get_client_by_id(ev.data.client_id)
					local keymap = vim.keymap

					keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, o)

					if client and client:supports_method("textDocument/rename") then
						keymap.set(
							"n",
							"<leader>rn",
							vim.lsp.buf.rename,
							vim.tbl_extend("force", o, { desc = "Smart rename" })
						)
					end
					if client and client:supports_method("textDocument/codeAction") then
						keymap.set(
							{ "n", "v" },
							"<leader>ca",
							vim.lsp.buf.code_action,
							vim.tbl_extend("force", o, { desc = "Code actions" })
						)
					end
					if client and client:supports_method("textDocument/inlayHint") then
						vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
					end
					if client and client:supports_method("textDocument/codeLens") then
						vim.lsp.codelens.enable(true, { bufnr = ev.buf })
					end

					keymap.set(
						"n",
						"<leader>cc",
						vim.lsp.codelens.run,
						vim.tbl_extend("force", o, { desc = "Run codelens" })
					)
				end,
			})

			-- Auto-load every file in lang/ — add a language by dropping a file, remove by deleting it
			local lang_dir = vim.fn.stdpath("config") .. "/lua/config/plugins/lsp/lang"
			for _, file in ipairs(vim.fn.glob(lang_dir .. "/*.lua", false, true)) do
				local mod = file:gsub(vim.fn.stdpath("config") .. "/lua/", ""):gsub("/", "."):gsub("%.lua$", "")
				require(mod)
			end
		end,
	},
	{
		"R-nvim/R.nvim",
		lazy = false,
		opts = {
			R_args = { "--quiet", "--no-save" },
			hook = {
				on_filetype = function()
					vim.keymap.set("n", "<Enter>", "<Plug>RDSendLine", { buffer = true })
					vim.keymap.set("v", "<Enter>", "<Plug>RSendSelection", { buffer = true })
					require("which-key").add({
						buffer = true,
						mode = { "n", "v" },
						{ "<localleader>a", group = "all" },
						{ "<localleader>b", group = "between marks" },
						{ "<localleader>c", group = "chunks" },
						{ "<localleader>f", group = "functions" },
						{ "<localleader>g", group = "goto" },
						{ "<localleader>i", group = "install" },
						{ "<localleader>k", group = "knit" },
						{ "<localleader>p", group = "paragraph" },
						{ "<localleader>q", group = "quarto" },
						{ "<localleader>r", group = "r general" },
						{ "<localleader>s", group = "split or send" },
						{ "<localleader>t", group = "terminal" },
						{ "<localleader>v", group = "view" },
					})
				end,
			},
			pdfviewer = "",
		},
		config = function(_, opts)
			vim.g.rout_follow_colorscheme = true
			require("r").setup(opts)
			require("r.pdf.generic").open = vim.ui.open
		end,
	},
	{
		"nvim-neotest/neotest",
		optional = true,
		dependencies = { "shunsambongi/neotest-testthat" },
		opts = {
			adapters = { ["neotest-testthat"] = {} },
		},
	},
}
