local M = {}

-- CycleLang
function M.cycle_lang()
	local langs = { "", "en_us", "fr" }
	-- vim.o.spelllang is the modern equivalent of &spl
	local current_lang = vim.o.spelllang

	-- Lua tables are 1-indexed, so we find our current position
	local current_idx = 1
	for i, lang in ipairs(langs) do
		if lang == current_lang then
			current_idx = i
			break
		end
	end

	-- Modulo math to cycle to the next index
	local next_idx = (current_idx % #langs) + 1
	local next_lang = langs[next_idx]

	vim.o.spelllang = next_lang

	if next_lang == "" then
		vim.opt.spell = false
	else
		vim.opt.spell = true
		-- Clear existing highlight and set the new one
		vim.cmd("hi clear SpellWrong")
		vim.api.nvim_set_hl(0, "SpellWrong", { underline = true, ctermfg = 9 })
	end
end

return M
