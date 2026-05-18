return {
	"HakonHarnes/img-clip.nvim",
	-- Only needed when working with images — load on demand
	cmd = { "PasteImage" },
	keys = {
		{ "<leader>mi", "<cmd>PasteImage<cr>", desc = "Paste image from clipboard" },
	},
	opts = {
		default = {
			-- Save relative to the current file, not cwd
			relative_to_current_file = true,
			dir_path = "assets",
			file_name = "%Y-%m-%d-%H-%M-%S",
			use_absolute_path = false,
			-- Prompt for a descriptive filename (good for notes)
			prompt_for_file_name = true,
			-- Drop back into insert mode after pasting
			insert_mode_after_paste = false,
		},

		filetypes = {
			markdown = {
				-- Standard markdown image syntax with alt text cursor placement
				template = "![$CURSOR]($FILE_PATH)",
				url_encode_path = false,
			},
		},

		-- Override for your Notes vault specifically
		dirs = {
			["~/documents/.bc/batcave/Notes"] = {
				dir_path = "assets",
				prompt_for_file_name = true,
			},
		},
	},

	-- Snacks picker integration: browse & embed existing images
	-- Usage: <leader>mI → fuzzy-find any image in the vault and embed it
	config = function(_, opts)
		require("img-clip").setup(opts)

		vim.keymap.set("n", "<leader>mI", function()
			Snacks.picker.files({
				title = "Embed Image",
				ft = { "jpg", "jpeg", "png", "webp", "gif", "svg" },
				cwd = "~/documents/.bc/batcave/Notes",
				confirm = function(self, item, _)
					self:close()
					require("img-clip").paste_image({}, "./" .. item.file)
				end,
			})
		end, { desc = "Embed existing image from Notes vault" })
	end,
}
