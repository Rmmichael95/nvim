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
			-- [Keep your existing keymap, snippets, appearance, and completion settings as they are]
			-- ...

			sources = {
				-- REMOVED "avante" from the default array
				default = { "lsp", "path", "snippets", "buffer", "minuet" },
				per_filetype = {
					sql = { "dadbod" },
					-- ADDED: Isolate CodeCompanion so it only triggers in its own chat buffers
					codecompanion = { "codecompanion" },
				},
				providers = {
					lsp = { score_offset = 100 },
					minuet = {
						name = "minuet",
						module = "minuet.blink",
						score_offset = -10,
						async = true,
					},
					-- REMOVED: the avante provider block
					-- ADDED: CodeCompanion provider
					codecompanion = {
						name = "CodeCompanion",
						module = "codecompanion.providers.completion.blink",
					},
					dadbod = { module = "vim_dadbod_completion.blink" },
					ripgrep = {
						-- [Keep your existing ripgrep opts]
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
