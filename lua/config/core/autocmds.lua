local home = os.getenv("HOME")
local aucmd = vim.api.nvim_create_autocmd

-- auto reload vimrc when editing it
aucmd("bufwritepost", {
	pattern = {
		"/home/ryanm/.config/nvim/*.lua",
		"/home/ryanm/.config/.config/nvim/**/*.lua",
		"/home/ryanm/.config/nvim/lua/**/*.lua",
		"/home/ryanm/.config/nvim/lua/plugins/**/*.lua",
	},
	command = "source " .. home .. "/.config/nvim/init.lua",
})

-- vertically center document when entering insert mode
aucmd("InsertEnter", {
	pattern = "*",
	command = "norm! zz",
})

-- toggle relative number off insert/on normal
local numberToggle = vim.api.nvim_create_augroup("NumberToggle", { clear = true })
aucmd({ "InsertLeave", "BufEnter", "BufRead" }, {
	pattern = "*",
	group = numberToggle,
	command = "set rnu",
})
aucmd("InsertEnter", {
	pattern = "*",
	group = numberToggle,
	command = "set nornu",
})

-- open file with existing swp in readonly mode
-- local noSimultanousEdits = vim.api.nvim_create_augroup("NoSimultaneousEdits", { clear = true })
-- aucmd({ "BufEnter", "BufRead" }, {
-- 	pattern = "*",
-- 	group = noSimultanousEdits,
-- 	command = [[SwapExists * let v:swapchoice = o]],
-- })
-- aucmd({ "BufEnter", "BufRead" }, {
-- 	pattern = "*",
-- 	group = noSimultanousEdits,
-- 	command = [[SwapExists * echomsg]],
-- })
-- aucmd({ "BufEnter", "BufRead" }, {
-- 	pattern = "*",
-- 	group = noSimultanousEdits,
-- 	command = [[SwapExists * echo Duplicate edit session (readonly)]],
-- })
-- aucmd({ "BufEnter", "BufRead" }, {
-- 	pattern = "*",
-- 	group = noSimultanousEdits,
-- 	command = [[SwapExists * echohl None]],
-- })
-- aucmd({ "BufEnter", "BufRead" }, {
-- 	pattern = "*",
-- 	group = noSimultanousEdits,
-- 	command = [[SwapExists * sleep 2]],
-- })

-- aucmd("BufEnter", {
-- 	pattern = "*",
-- 	command = "match ExtraWhitespace /\\s\\+$\\| \\+\\ze\\t/",
-- })
aucmd({ "BufEnter", "BufNewFile", "BufRead" }, {
	pattern = "dashboard",
	command = "highlight ExtraWhitespace guibg=0",
})

-- highlight whitespace before tabs and eol in darkred
-- cmd("highlight ExtraWhitespace guibg=darkred")
-- cmd([[autocmd BufEnter * match ExtraWhitespace /\s\+$\| \+\ze\t/]])
-- cmd("autocmd FileType dashboard highlight ExtraWhitespace guibg=0")

-- In your Neovim configuration (e.g., init.lua)
local function load_document_skeleton()
	local current_file = vim.fn.expand("%:p")
	local documents_dir = "~/documents/.bc/batcave/Notes/" -- Adjust this path as needed

	-- Check if the file is in the documents directory and if the buffer is empty
	if current_file:find(documents_dir, 1, true) and (vim.fn.line("$") == 1 and vim.fn.getline(1) == "") then
		local snippets = require("luasnip").get_snippets()[vim.bo.ft] -- Get snippets for current filetype
		if snippets then
			for _, snip in ipairs(snippets) do
				if snip.name == "_skel" then -- Check for your skeleton snippet
					require("luasnip").snip_expand(snip)
					return
				end
			end
		end
	end
end

aucmd("BufNewFile", {
	callback = load_document_skeleton,
})
