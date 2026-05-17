return {
	"yetone/avante.nvim",
	-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
	-- ⚠️ must add this setting! ! !
	build = vim.fn.has("win32") ~= 0 and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
		or "make",
	event = "VeryLazy",
	version = false, -- Never set this value to "*"! Never!
	---@module 'avante'
	---@type avante.Config
	opts = {
		-- add any opts here
		-- this file can contain specific instructions for your project
		instructions_file = "avante.md",

		-- Set the default provider to the local NPU
		provider = "flm",

		providers = {
			-- New llama.cpp GPU Configuration
			llamacpp = {
				__inherited_from = "openai",
				api_key_name = "FLM_API_KEY", -- We reuse your FLM key env var to bypass Avante's nil-key check; the local server ignores it anyway.
				endpoint = "http://127.0.0.1:8080/v1",
				model = "qwen-2.5-7b", -- llama-server ignores this string when only running one model, but Avante requires it.
			},
			-- FastFlowLM NPU Configuration
			flm = {
				__inherited_from = "openai",
				api_key_name = "FLM_API_KEY",
				endpoint = "http://localhost:52625/v1",
				--model = "llama3.2:1b",
				model = "deepseek-r1:8b",
			},
			claude = {
				endpoint = "https://api.anthropic.com",
				model = "claude-sonnet-4-20250514",
				timeout = 30000, -- Timeout in milliseconds
				extra_request_body = {
					temperature = 0.75,
					max_tokens = 20480,
				},
			},
			openai = {
				endpoint = "https://api.openai.com/v1",
				model = "gpt-5",
				timeout = 30000, -- Timeout in milliseconds
				extra_request_body = {
					temperature = 0.75,
					max_tokens = 32768,
				},
			},
		},
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		--- The below dependencies are optional,
		"folke/snacks.nvim", -- for input provider snacks
		"zbirenbaum/copilot.lua", -- for providers='copilot'
		{
			-- support for image pasting
			"HakonHarnes/img-clip.nvim",
			event = "VeryLazy",
			opts = {
				-- recommended settings
				default = {
					embed_image_as_base64 = false,
					prompt_for_file_name = false,
					drag_and_drop = {
						insert_mode = true,
					},
					-- required for Windows users
					use_absolute_path = true,
				},
			},
		},
		{
			-- Make sure to set this up properly if you have lazy=true
			"MeanderingProgrammer/render-markdown.nvim",
			opts = {
				file_types = { "markdown", "Avante" },
			},
			ft = { "markdown", "Avante" },
		},
	},
}
