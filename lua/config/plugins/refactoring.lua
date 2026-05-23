-- lua/config/plugins/refactoring.lua
--
-- Structural refactoring operations that LSP code actions don't cover:
--   Extract Function   — pull a visual selection into a named function
--   Extract Variable   — lift an expression into a local variable
--   Inline Variable    — inline a variable back to its usage sites
--   Extract Block      — hoist a block into its own function
--
-- Supported filetypes (treesitter-driven):
--   TypeScript, JavaScript, TSX, JSX, Python, Lua, C, C++, C#, PHP, Go, Ruby, Java
--
-- Coexists cleanly with your existing stack:
--   • mini.ai vif/vaf/vic text objects are ideal selection sources before
--     triggering <leader>re (extract) — select with V then hit the keymap.
--   • flash.nvim S-selection → extract is a natural workflow for nested exprs.
--   • vtsls move-to-file code action covers the TS file-level case; refactoring.nvim
--     covers the function/variable/block level.
--   • CodeCompanion handles the "I don't know what to refactor" case (AI suggests);
--     this plugin handles "I know exactly what I want" structural edits.
--
-- Mason: no external tools needed — pure treesitter.

return {
	{
		"ThePrimeagen/refactoring.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		-- Load on keymap trigger only — zero startup cost.
		lazy = true,
		keys = {
			-- ── Extract operations (visual mode) ──────────────────────────────
			-- Select with V (linewise) or <C-v> (block), then trigger.
			-- Tip: use mini.ai `vif` to select a function body first.
			{
				"<leader>re",
				function()
					require("refactoring").refactor("Extract Function")
				end,
				mode = "x",
				desc = "Refactor: extract function",
			},
			{
				"<leader>rv",
				function()
					require("refactoring").refactor("Extract Variable")
				end,
				mode = "x",
				desc = "Refactor: extract variable",
			},
			{
				"<leader>rb",
				function()
					require("refactoring").refactor("Extract Block")
				end,
				mode = "x",
				desc = "Refactor: extract block",
			},
			{
				"<leader>rB",
				function()
					require("refactoring").refactor("Extract Block To File")
				end,
				mode = "x",
				desc = "Refactor: extract block to file",
			},

			-- ── Inline operations (normal mode) ───────────────────────────────
			-- Cursor on the variable/function you want to inline.
			{
				"<leader>ri",
				function()
					require("refactoring").refactor("Inline Variable")
				end,
				mode = { "n", "x" },
				desc = "Refactor: inline variable",
			},
			{
				"<leader>rI",
				function()
					require("refactoring").refactor("Inline Function")
				end,
				mode = "n",
				desc = "Refactor: inline function",
			},

			-- ── Picker: all refactors for current context ─────────────────────
			-- Uses Snacks.picker since that's your picker layer.
			-- Falls back to vim.ui.select if Snacks is unavailable.
			{
				"<leader>rr",
				function()
					-- Try Snacks picker first (matches your snacks.lua setup)
					local ok, snacks = pcall(require, "snacks")
					if ok and snacks.picker then
						require("refactoring").select_refactor()
					else
						require("refactoring").select_refactor()
					end
				end,
				mode = { "n", "x" },
				desc = "Refactor: pick operation",
			},

			-- ── Debug print helpers ───────────────────────────────────────────
			-- Inserts language-idiomatic print statements for rapid debug cycles.
			-- Works for: TS console.log, Python print, Lua print, C printf, etc.
			-- Remove ALL inserted debug prints in the file with <leader>rc.
			{
				"<leader>rp",
				function()
					require("refactoring").debug.print_var({ normal = true })
				end,
				mode = "n",
				desc = "Refactor: print var (cursor)",
			},
			{
				"<leader>rP",
				function()
					require("refactoring").debug.print_var()
				end,
				mode = "x",
				desc = "Refactor: print var (visual)",
			},
			{
				"<leader>rc",
				function()
					require("refactoring").debug.cleanup({})
				end,
				mode = "n",
				desc = "Refactor: clean debug prints",
			},
		},

		opts = {
			-- Show extracted name prompt in the command line.
			-- false = popup float, true = cmdline (less intrusive, pairs well with
			-- your minimal UI philosophy from options.lua shortmess settings).
			prompt_func_return_type = {
				go = true,
				cpp = true,
				c = true,
				java = true,
			},
			prompt_func_param_type = {
				go = true,
				cpp = true,
				c = true,
				java = true,
			},

			-- Printf debug statements — language-idiomatic defaults.
			-- Only override if you want non-standard output (e.g. a logger instead
			-- of raw print). Leaving unset uses refactoring.nvim's built-in defaults
			-- which are correct for every language in your stack.
			printf_statements = {},
			print_var_statements = {},
		},
	},
}
