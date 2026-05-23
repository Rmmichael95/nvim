-- lua/config/plugins/inc-rename.lua
--
-- Live preview rename: replaces the blind vim.lsp.buf.rename() call on <leader>rn
-- with an incremental cmdline rename that shows all in-buffer replacements as you
-- type — before committing. Works with any LSP server (ts_ls, vtsls, clangd,
-- roslyn, intelephense, lua_ls, pyright, etc.).
--
-- How it works:
--   1. <leader>rn populates the cmdline with `:IncRename <current_symbol_name>`
--   2. You edit the name inline; Neovim highlights every occurrence in real time
--   3. <CR> commits — LSP sends workspace/applyEdit for cross-file renames
--
-- Coexists with existing lspconfig.lua:
--   The LspAttach block in lspconfig.lua sets keymap.set("n", "<leader>rn",
--   vim.lsp.buf.rename, ...) on supported clients. This plugin overrides that
--   binding globally. The LspAttach mapping is still guarded by
--   client:supports_method("textDocument/rename") so it only fires when the
--   server is capable — inc-rename.nvim defers to vim.lsp.buf.rename() itself
--   under the hood, so the capability check is still respected.
--
-- C++ note: <leader>tR in cpp_tools.lua is a muscle-memory alias for rename.
--   Update that alias to use IncRename as well (see the keymap override below).

return {
	{
		"smjonas/inc-rename.nvim",
		-- Load the moment a rename keymap is triggered — no startup cost.
		cmd = "IncRename",
		keys = {
			{
				"<leader>rn",
				function()
					-- Pre-fill with the current word so you can edit from a non-empty state.
					-- This removes the need to retype the symbol name from scratch.
					return ":IncRename " .. vim.fn.expand("<cword>")
				end,
				expr = true, -- Return value is fed directly to the cmdline
				mode = "n",
				desc = "Rename symbol (live preview)",
			},
		},
		opts = {
			-- Input field appears in the cmdline, not a float.
			-- Matches your shortmess-heavy, low-noise UI philosophy.
			input_buffer_type = "dressing", -- or nil for built-in vim.ui.input

			-- Highlight group for the preview replacements.
			-- Reuses your existing IncSearch highlight so it fits Catppuccin.
			hl_group = "IncSearch",

			-- Show the count of occurrences that will be renamed in the cmdline.
			show_message = true,

			-- Save the buffer before applying the rename.
			-- Prevents "buffer modified" errors on cross-file LSP edits.
			save_in_cmdline_win = true,
		},

		config = function(_, opts)
			require("inc_rename").setup(opts)

			-- Override the C++ muscle-memory alias in cpp_tools.lua as well.
			-- This fires after LspAttach so it safely wins the race.
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "c", "cpp" },
				callback = function(ev)
					vim.keymap.set("n", "<leader>tR", function()
						return ":IncRename " .. vim.fn.expand("<cword>")
					end, {
						buffer = ev.buf,
						expr = true,
						silent = false, -- cmdline must be visible for live preview
						desc = "C++: rename symbol (live preview)",
					})
				end,
			})
		end,
	},
}
