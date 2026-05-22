return {
	"olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
	keys = {
		{ "<leader>aa", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "AI Actions" },
		{ "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", mode = "n", desc = "AI Chat Toggle" },
		{ "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", mode = "v", desc = "AI Chat with Selection" },
		{ "<leader>cq", "<cmd>CodeCompanionChat Add<cr>", mode = "v", desc = "Add Selection to Chat" },
	},
	opts = {
		strategies = {
			-- Shift default chat strategy to Gemini (Fast, huge context for parsing themes)
			chat = {
				adapter = "gemini",
				-- Native MCP Tool registration hook
				tools = {
					opts = {
						-- Automatically enables system command execution permissions
						-- when you request automated theme modifications via chat
						allow_insecure = true,
						-- Registers your custom WP-CLI engine alongside the standard suite
						["wp_cli"] = {
							callback = "codecompanion.tools.wp_cli",
							description = "Query your active local WordPress site state parameters",
							opts = {
								requires_approval = true, -- Force Neovim to prompt you before launching the shell job
							},
						},
					},
				},
			},
			inline = { adapter = "flm" },
			agent = { adapter = "gemini" },
		},
		adapters = {
			http = {
				-- FastFlowLM NPU Configuration (DeepSeek-R1)
				flm = function()
					return require("codecompanion.adapters").extend("openai_compatible", {
						name = "flm",
						formatted_name = "FLM (Qwen3.5)",
						env = {
							url = "http://127.0.0.1:52625",
							api_key = "FLM_API_KEY",
						},
						schema = {
							model = { default = "qwen3.5:4b" },
							temperature = { default = 0.1 },
							max_tokens = { default = 4096 },
							reasoning_effort = { default = "high" },
						},
					})
				end,

				-- Google Gemini Configuration (Targeting AI Studio Keys)
				-- Google Gemini Configuration (Targeting AI Studio Keys)
				gemini = function()
					return require("codecompanion.adapters").extend("gemini", {
						env = {
							api_key = "cmd:echo $GEMINI_API_KEY",
						},
						-- THE FIX: Intercept the complete request right before it sends
						form_messages = function(self, messages, params)
							-- Generate CodeCompanion's standard payload format
							local formatted =
								require("codecompanion.adapters.gemini").form_messages(self, messages, params)

							-- Forcefully remove the broken thinking parameter object from the body table
							if formatted and formatted.generationConfig then
								formatted.generationConfig.thinkingConfig = nil
							end

							return formatted
						end,
						schema = {
							model = {
								default = "gemini-2.5-flash",
							},
						},
					})
				end,

				-- Optimized OpenAI (Replacing raw placeholder gpt5 block)
				openai = function()
					return require("codecompanion.adapters").extend("openai", {
						env = {
							api_key = "cmd:echo $OPENAI_API_KEY",
						},
						schema = {
							model = {
								default = "gpt-4o-mini", -- Cost-efficient token management for blocks
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
	},
	config = function(_, opts)
		require("codecompanion").setup(opts)
	end,
}
