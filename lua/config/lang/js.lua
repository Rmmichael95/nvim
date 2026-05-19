-- lua/config/lang/js.lua
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
	group = vim.api.nvim_create_augroup("lang_js", { clear = true }),
	callback = function()
		vim.bo.tabstop = 2
		vim.bo.softtabstop = 2
		vim.bo.shiftwidth = 2
		vim.bo.expandtab = true
		vim.bo.formatexpr = ""
		vim.bo.textwidth = 0
		vim.wo.conceallevel = 0
		vim.bo.commentstring = "// %s"

		local map = function(lhs, rhs, desc)
			vim.keymap.set("n", lhs, rhs, { buffer = true, silent = true, desc = desc })
		end
		-- keymaps...
	end,
})
