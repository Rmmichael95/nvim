-- lua/config/plugins/harpoon.lua
return {
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		-- Declare keys here so lazy.nvim can load harpoon on first invocation.
		-- This replaces the broken config-time map() calls entirely.
		keys = function()
			local harpoon = require("harpoon")

			-- ── Helpers ──────────────────────────────────────────────────────────
			local function nav(n)
				return function()
					harpoon:list():select(n)
				end
			end

			-- ── Keymap table ─────────────────────────────────────────────────────
			return {
				-- Add current file to harpoon list
				{
					"<leader>ha",
					function()
						harpoon:list():add()
						vim.notify("󱡅 Harpoon: file added", vim.log.levels.INFO, { title = "Harpoon" })
					end,
					desc = "Add file",
				},

				-- Toggle the harpoon quick-menu
				{
					"<leader>hh",
					function()
						harpoon.ui:toggle_quick_menu(harpoon:list())
					end,
					desc = "Quick menu",
				},

				-- Navigate to harpooned files 1-4
				{ "<leader>h1", nav(1), desc = "File 1" },
				{ "<leader>h2", nav(2), desc = "File 2" },
				{ "<leader>h3", nav(3), desc = "File 3" },
				{ "<leader>h4", nav(4), desc = "File 4" },

				-- Cycle through list (useful without remembering slot numbers)
				{
					"[h",
					function()
						harpoon:list():prev()
					end,
					desc = "Prev harpoon file",
				},
				{
					"]h",
					function()
						harpoon:list():next()
					end,
					desc = "Next harpoon file",
				},
			}
		end,

		config = function()
			local harpoon = require("harpoon")

			harpoon:setup({
				settings = {
					-- Sync across all neovim instances in the same project
					sync_on_ui_close = true,
					-- Save on every change in the quick-menu
					save_on_toggle = true,
				},
			})

			-- ── which-key group label ─────────────────────────────────────────────
			-- Registers <leader>h as a named group so which-key shows it properly.
			local ok, wk = pcall(require, "which-key")
			if ok then
				wk.add({ { "<leader>h", group = "harpoon" } })
			end
		end,
	},
}
