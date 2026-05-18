return {
	"olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		-- Optional but highly recommended for better UI menus
		"stevearc/dressing.nvim",
	},
	cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
	keys = {
		{ "<leader>aa", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "AI Actions" },
		{ "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "AI Chat Toggle" },
		{ "<leader>ai", "<cmd>CodeCompanion<cr>", mode = { "n", "v" }, desc = "AI Inline Prompt" },
	},
	opts = {
		strategies = {
			-- Set default adapter to your local NPU
			chat = { adapter = "flm" },
			inline = { adapter = "flm" },
			agent = { adapter = "flm" },
		},
		adapters = {
			-- FastFlowLM NPU Configuration (DeepSeek-R1)
			flm = function()
				return require("codecompanion.adapters").extend("openai_compatible", {
					name = "flm",
					env = {
						url = "http://localhost:52625/v1",
						api_key = "cmd:echo $FLM_API_KEY", -- Safely pull from env
					},
					schema = {
						model = {
							default = "deepseek-r1:8b",
						},
					},
				})
			end,
			-- Ported Claude Configuration
			claude_sonnet = function()
				return require("codecompanion.adapters").extend("anthropic", {
					schema = {
						model = { default = "claude-sonnet-4-20250514" },
					},
				})
			end,
			-- Ported OpenAI Configuration
			gpt5 = function()
				return require("codecompanion.adapters").extend("openai", {
					schema = {
						model = { default = "gpt-5" },
					},
				})
			end,
		},
		display = {
			chat = {
				window = {
					layout = "vertical",
					width = 45,
				},
			},
		},
	},
	config = function(_, opts)
		require("codecompanion").setup(opts)
	end,
}
