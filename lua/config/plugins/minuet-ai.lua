return {
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
				keymap = {
					accept_line = "<A-l>",
					accept_word = "<C-Right>",
					dismiss = "<A-e>",
				},
			})
		end,
	},
}
