return {
	{
		"saghen/blink.cmp",
		event = "InsertEnter",
		dependencies = {
			{
				"L3MON4D3/LuaSnip",
				version = "v2.*",
			},
			"mikavilpas/blink-ripgrep.nvim",
			"kristijanhusak/vim-dadbod-completion",
			"echasnovski/mini.icons",
			"milanglacier/minuet-ai.nvim",
		},
		version = "*",
		opts = {
			keymap = {
				["<c-x>"] = { "show", "show_documentation", "hide_documentation" },
				["<c-e>"] = { "cancel", "fallback" },
				["<tab>"] = { "snippet_forward", "accept", "fallback" },
				["<c-l>"] = { "select_and_accept", "fallback" },
				["<c-k>"] = { "select_prev", "fallback" },
				["<up>"] = { "select_prev", "fallback" },
				["<c-j>"] = { "select_next", "fallback" },
				["<down>"] = { "select_next", "fallback" },
			},

			snippets = { preset = "luasnip" },

			appearance = {
				use_nvim_cmp_as_default = true,
				nerd_font_variant = "mono",
			},

			completion = {
				keyword = { range = "full" },
				accept = {
					auto_brackets = { enabled = true },
				},
				menu = {
					draw = {
						padding = { 0, 1 },
						components = {
							kind_icon = {
								text = function(ctx)
									return " " .. ctx.kind_icon .. ctx.icon_gap .. " "
								end,
								highlight = function(ctx)
									local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
									return hl
								end,
							},
							kind = {
								highlight = function(ctx)
									local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
									return hl
								end,
							},
						},
						treesitter = { "lsp" },
						columns = {
							{ "label", "label_description", gap = 1 },
							{ "kind_icon", "kind" },
						},
					},
					border = "rounded",
				},
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 200,
					window = { border = "rounded" },
				},
				-- FIX 1: Force ghost text on natively instead of relying on an un-triggered global
				ghost_text = {
					enabled = true,
				},
			},
			sources = {
				-- ADDED: "ripgrep" is now active in the default loop
				default = { "lsp", "path", "snippets", "buffer", "ripgrep", "minuet" },
				per_filetype = {
					-- It's highly useful to keep buffer completions active inside SQL and Chat files
					sql = { "dadbod", "buffer" },
					codecompanion = { "codecompanion", "buffer" },
				},
				providers = {
					-- 1. TOP TIER: Code Intelligence & Paths
					lsp = { name = "LSP", score_offset = 100 },
					snippets = { name = "Snippets", score_offset = 90 },
					path = { name = "Path", score_offset = 80 },

					-- 2. MID TIER: Current File Context
					buffer = {
						name = "Buffer",
						score_offset = 10,
						-- OPTIMIZATION: Stop scanning all open tabs. Only scan the active file.
						-- Your ripgrep provider will handle finding strings in other files.
						opts = {
							get_bufnrs = function()
								return { vim.api.nvim_get_current_buf() }
							end,
						},
					},

					-- 3. BACKGROUND TIER: Local AI
					minuet = {
						name = "minuet",
						module = "minuet.blink",
						score_offset = -10,
						async = true,
					},

					-- 4. BOTTOM TIER: Project Search
					ripgrep = {
						module = "blink-ripgrep",
						name = "Ripgrep",
						score_offset = -20,
						min_keyword_length = 4,
						opts = {
							backend = {
								use = "gitgrep-or-ripgrep",
								customize_icon_highlight = true,
								ripgrep = {
									context_size = 0,
									max_filesize = "250K",
									search_casing = "--smart-case",
									additional_rg_options = {
										"--max-columns=150",
										"-g",
										"!*.lock",
										"-g",
										"!*-lock.json",
										"-g",
										"!*.min.*",
									},
									ignore_paths = {
										"node_modules",
										".git",
										"vendor",
										"build",
										"dist",
									},
								},
							},
						},
					},

					-- Isolated Filetype Providers
					codecompanion = {
						name = "CodeCompanion",
						module = "codecompanion.providers.completion.blink",
					},
					dadbod = {
						name = "Dadbod",
						module = "vim_dadbod_completion.blink",
					},
				},
			},
			signature = { enabled = true, window = { border = "rounded" } },
		},
		opts_extend = {
			"sources.completion.enabled_providers",
			"sources.compat",
			"sources.default",
		},
		config = function(_, opts)
			require("blink.cmp").setup(opts)
		end,
	},
	{
		"milanglacier/minuet-ai.nvim",
		-- KEEP EXACTLY AS IS. Minuet is perfectly configured for local FIM.
		config = function()
			require("minuet").setup({
				provider = "openai_fim_compatible",
				throttle_delay = 300,
				context_window = 16000,
				context_ratio = 0.75,
				provider_options = {
					openai_fim_compatible = {
						endpoint = "http://127.0.0.1:8081/v1/completions",
						model = "qwen-1.5b-fim",
						api_key = "FLM_API_KEY",
						name = "Llama.cpp FIM",
						optional = {
							max_tokens = 128,
							temperature = 0.0,
						},
					},
				},
				keymap = {
					accept_line = "<A-l>",
					accept_word = "<C-Right>",
					dismiss = "<A-e>",
				},
			})
		end,
	},
}
