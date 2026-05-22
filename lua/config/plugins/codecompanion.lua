-- lua/config/plugins/codecompanion.lua

return {
	"olimorris/codecompanion.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	cmd = {
		"CodeCompanion",
		"CodeCompanionChat",
		"CodeCompanionActions",
	},
	keys = {
		{ "<leader>aa", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "AI Actions" },
		{ "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", mode = "n", desc = "AI Chat Toggle" },
		{ "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", mode = "v", desc = "AI Chat with Selection" },
		{ "<leader>cq", "<cmd>CodeCompanionChat Add<cr>", mode = "v", desc = "Add Selection to Chat" },
	},

	opts = {
		interactions = {
			chat = {
				adapter = "gemini",

				opts = {
					system_prompt = function(ctx)
						return ctx.default_system_prompt
							.. [[

Additional WordPress tooling instructions:

A WordPress tool is available. Use it whenever the user asks about the current WordPress install, active theme, installed themes, plugins, WordPress options, WordPress 7 readiness, block theme support, theme.json, templates, template parts, block overrides, or WP-CLI output.

Do not print WP-CLI commands and ask the user to run them.
Do not guess WordPress state.
Do not invent command output.
Use the available tool to gather the information first.

For block override readiness, use the WordPress tool with:
action = "block_overrides_audit"

For active theme checks, use:
action = "active_theme"
]]
					end,
				},

				tools = {
					["wp_cli"] = {
						description = "Run approved WP-CLI checks against the current local WordPress site.",
						opts = {
							require_approval_before = true,
						},
						path = "~/.config/nvim/lua/codecompanion/tools/wp_cli.lua",
					},

					opts = {
						default_tools = {
							"wp_cli",
						},
					},
				},
			},

			inline = {
				adapter = "flm",
			},
		},

		adapters = {
			http = {
				opts = {
					allow_insecure = true,
				},

				-- FastFlowLM NPU — local Qwen/Qwen-compatible endpoint
				flm = function()
					return require("codecompanion.adapters").extend("openai_compatible", {
						name = "flm",
						formatted_name = "FLM",
						env = {
							url = "http://127.0.0.1:52625",
							api_key = "FLM_API_KEY",
						},
						schema = {
							model = {
								default = "qwen3.5:4b",
							},
							temperature = {
								default = 0.1,
							},
							max_tokens = {
								default = 4096,
							},
						},
					})
				end,

				-- Gemini HTTP adapter patched for CodeCompanion Gemini thinkingConfig issues.
				-- Keep this until your installed CodeCompanion version no longer sends
				-- generationConfig.thinkingConfig as a string.
				gemini = function()
					local adapters = require("codecompanion.adapters")

					local adapter = adapters.extend("gemini", {
						env = {
							api_key = "cmd:echo $GEMINI_API_KEY",
						},
						schema = {
							model = {
								default = "gemini-2.5-flash-lite",
								choices = {
									["gemini-2.5-flash-lite"] = {
										formatted_name = "Gemini 2.5 Flash Lite",
										opts = {
											can_reason = false,
											has_vision = true,
										},
									},
									["gemini-2.5-flash"] = {
										formatted_name = "Gemini 2.5 Flash",
										opts = {
											can_reason = false,
											has_vision = true,
										},
									},
								},
							},

							temperature = {
								default = 0.2,
							},

							maxOutputTokens = {
								default = 8192,
							},

							thinkingLevel = {
								optional = true,
								default = nil,
								enabled = function()
									return false
								end,
							},
						},
					})

					if adapter.schema then
						adapter.schema.thinkingLevel = {
							optional = true,
							default = nil,
							enabled = function()
								return false
							end,
						}
					end

					local original_form_parameters = adapter.handlers and adapter.handlers.form_parameters

					if original_form_parameters then
						adapter.handlers.form_parameters = function(self, params, ...)
							params = original_form_parameters(self, params, ...)

							if params and params.body and params.body.generationConfig then
								params.body.generationConfig.thinkingConfig = nil
							end

							return params
						end
					end

					return adapter
				end,

				openai = function()
					return require("codecompanion.adapters").extend("openai", {
						env = {
							api_key = "cmd:echo $OPENAI_API_KEY",
						},
						schema = {
							model = {
								default = "gpt-4o-mini",
							},
						},
					})
				end,

				claude_sonnet = function()
					return require("codecompanion.adapters").extend("anthropic", {
						schema = {
							model = {
								default = "claude-sonnet-4-20250514",
							},
						},
					})
				end,
			},
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
