return {
	{
		"saghen/blink.cmp",
		event = "InsertEnter",
		dependencies = {
			{
				"L3MON4D3/LuaSnip",
				-- follow latest release.
				version = "v2.*",
			},
			"mikavilpas/blink-ripgrep.nvim",
			"kristijanhusak/vim-dadbod-completion",
			"echasnovski/mini.icons",
			"Kaiser-Yang/blink-cmp-avante",
		},
		version = "*",

		---@module 'blink.cmp'
		---@type blink.cmp.Config
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
				-- FIX 2: Append "minuet" to your active execution pipeline array
				default = { "lsp", "avante", "path", "snippets", "buffer", "minuet" },
				per_filetype = {
					sql = { "dadbod" },
				},
				providers = {
					-- FIX 3: Register the structural module mapping so blink can call minuet asynchronously
					lsp = {
						score_offset = 100, -- Forces precise language signatures to win sorting priorities
					},
					minuet = {
						name = "minuet",
						module = "minuet.blink",
						score_offset = -10,
						async = true,
					},
					avante = {
						module = "blink-cmp-avante",
						name = "Avante",
						opts = {},
					},
					dadbod = { module = "vim_dadbod_completion.blink" },
					ripgrep = {
						module = "blink-ripgrep",
						name = "Ripgrep",
						opts = {
							backend = {
								use = "gitgrep-or-ripgrep",
								customize_icon_highlight = true,
								ripgrep = {
									context_size = 5,
									max_filesize = "1M",
									project_root_fallback = true,
									search_casing = "--ignore-case",
									additional_rg_options = {},
									ignore_paths = {},
									additional_paths = {},
								},
							},
						},
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
		config = function()
			require("minuet").setup({
				provider = "openai_fim_compatible",
				-- throttle_delay controls the tracking loop frequency
				throttle_delay = 300,

				-- Tracks total character lookahead/lookbehind bounds
				context_window = 16000,
				context_ratio = 0.75, -- Allocates a 3:1 context split before vs after your cursor position

				provider_options = {
					openai_fim_compatible = {
						endpoint = "http://127.0.0.1:8081/v1/completions",
						model = "qwen-1.5b-fim",
						api_key = "FLM_API_KEY", -- Updated authentication key
						name = "Llama.cpp FIM",
						optional = {
							max_tokens = 128, -- Allows the model to output wider multi-line block completions
							temperature = 0.0, -- Enforces strict, deterministic type compliance
						},
					},
				},
			})
		end,
	},
}
