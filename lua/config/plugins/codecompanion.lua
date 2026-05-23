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

				system_prompt = function(ctx)
					return require("codecompanion.prompts.wordpress").chat_system_prompt(ctx)
				end,

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

			agent = {
				adapter = "claude_code",

				tools = {
					["wp_cli"] = {
						description = "Run approved WP-CLI checks against the current local WordPress site.",
						opts = {
							require_approval_before = true,
						},
						path = "~/.config/nvim/lua/codecompanion/tools/wp_cli.lua",
					},
				},
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

			acp = {
				claude_code = function()
					return require("codecompanion.adapters").extend("claude_code", {
						env = {
							CLAUDE_CODE_OAUTH_TOKEN = "cmd:echo $CLAUDE_CODE_OAUTH_TOKEN",
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
		local uv = vim.uv or vim.loop

		local function path_exists(path)
			return path and uv.fs_stat(path) ~= nil
		end

		local function is_wp_root(path)
			return path
				and path_exists(path .. "/wp-config.php")
				and path_exists(path .. "/wp-includes")
				and path_exists(path .. "/wp-admin")
		end

		local function dirname(path)
			if not path or path == "" then
				return nil
			end

			path = path:gsub("/+$", "")
			local parent = path:match("^(.*)/[^/]+$")

			if not parent or parent == "" or parent == path then
				return nil
			end

			return parent
		end

		local function find_wp_root_from(start)
			if not start or start == "" then
				return nil
			end

			start = vim.fn.fnamemodify(start, ":p"):gsub("/+$", "")

			local stat = uv.fs_stat(start)
			if stat and stat.type == "file" then
				start = dirname(start)
			end

			local dir = start

			while dir do
				if is_wp_root(dir) then
					return dir
				end

				local parent = dirname(dir)
				if not parent or parent == dir then
					break
				end

				dir = parent
			end

			return nil
		end

		local function remember_wp_root_from(start)
			local root = find_wp_root_from(start)

			if root then
				vim.g.wp_cli_path = root
			end
		end

		-- Try immediately from current buffer and cwd.
		remember_wp_root_from(vim.api.nvim_buf_get_name(0))
		remember_wp_root_from(vim.fn.getcwd())

		-- Keep updating as you move between project files.
		vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
			group = vim.api.nvim_create_augroup("CodeCompanionWpCliRoot", { clear = true }),
			callback = function(args)
				remember_wp_root_from(vim.api.nvim_buf_get_name(args.buf))
			end,
		})

		vim.api.nvim_create_autocmd("DirChanged", {
			group = vim.api.nvim_create_augroup("CodeCompanionWpCliCwd", { clear = true }),
			callback = function()
				remember_wp_root_from(vim.fn.getcwd())
			end,
		})

		require("codecompanion").setup(opts)
	end,
}
