local M = {}

-- Open unsupported files
function M.open_all()
	-- Neovim's Lua API directly exposes the Vimscript executable() function
	if vim.fn.executable("handlr") == 1 then
		return "handlr"
	end
	return nil
end

return M
