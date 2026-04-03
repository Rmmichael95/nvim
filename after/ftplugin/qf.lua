-- In an autocmds.lua file or replacing the keymap line:
vim.api.nvim_create_autocmd("FileType", {
	pattern = "qf",
	callback = function(event)
		vim.keymap.set(
			"n",
			"<localleader>,",
			"<CR><C-w>p",
			{ buffer = event.buf, silent = true, desc = "Return to list quickfix window" }
		)
	end,
})
