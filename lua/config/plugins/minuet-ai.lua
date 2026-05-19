return {
	{
		"milanglacier/minuet-ai.nvim",
		lazy = false,
		config = function()
			require("minuet").setup({
				provider = "openai_fim_compatible",
				throttle = 350,
				context_window = 16000,
				context_ratio = 0.75,
				provider_options = {
					openai_fim_compatible = {
						end_point = "http://127.0.0.1:8081/v1/completions",
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
