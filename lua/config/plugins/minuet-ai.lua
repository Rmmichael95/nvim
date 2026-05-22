-- lua/config/plugins/minuet-ai.lua
return {
	{
		"milanglacier/minuet-ai.nvim",
		lazy = false,
		config = function()
			require("minuet").setup({
				provider = "openai_fim_compatible",

				-- ── Timing ────────────────────────────────────────────────────
				-- 300ms: local GPU model responds in ~100-200ms so debounce can
				-- be tighter than you'd use for a remote API. Any lower and you
				-- fire mid-keystroke; any higher and the suggestion feels late.
				throttle = 300,

				-- ── Context budget ────────────────────────────────────────────
				-- MUST match the server's -c value. The server was launched with
				-- -c 4096 — sending more than this causes silent front-truncation,
				-- which cuts exactly the code closest to the cursor (most useful).
				context_window = 4096,

				-- Qwen2.5-Coder is trained as a true FIM model: the suffix
				-- (what comes after the cursor) is a first-class signal, not an
				-- afterthought. 0.6 gives:
				--   prefix : (4096 - 128) * 0.60 ≈ 2381 tokens
				--   suffix : (4096 - 128) * 0.40 ≈ 1587 tokens
				-- Enough prefix for full function context; enough suffix that
				-- the model sees the closing brace/return type it must match.
				context_ratio = 0.6,

				provider_options = {
					openai_fim_compatible = {
						end_point = "http://127.0.0.1:8081/v1/completions",
						model = "qwen-1.5b-fim",
						api_key = "FLM_API_KEY",
						name = "Qwen2.5-Coder-1.5B FIM",
						optional = {
							-- 1.5B is a single-completion model. Requesting
							-- more than 1 doubles inference time for marginal
							-- quality gain you'd only see in a 7B+.
							n = 1,

							-- 128 tokens ≈ 4-6 lines — right for a local 1.5B.
							-- A larger model can sustain quality over 256+; this
							-- one degrades on long generations. Keep it tight.
							max_tokens = 128,

							-- Zero temperature = fully deterministic. Correct
							-- for code completion: you want the highest-probability
							-- token at every step, not sampled variation.
							temperature = 0.0,

							-- Stop generation at natural code boundaries.
							-- Prevents the model from running past the
							-- completion point into hallucinated next lines.
							stop = { "\n\n", "<|endoftext|>", "<fim_pad>" },
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
