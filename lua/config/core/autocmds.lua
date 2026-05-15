local home = os.getenv("HOME")
local aucmd = vim.api.nvim_create_autocmd

vim.lsp.log.set_level(vim.log.levels.WARN)

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
	if not (vim.fn.line("$") == 1 and vim.fn.getline(1) == "") then
		return
	end

	local ok, ls = pcall(require, "luasnip")
	if not ok then
		return
	end

	-- ft is set by now (vim.schedule ran after filetype detection)
	-- fall back to "markdown" in case detection is still pending
	local ft = vim.bo.ft ~= "" and vim.bo.ft or "markdown"
	local snippets = ls.get_snippets(ft)
	if not snippets then
		return
	end

	for _, snip in ipairs(snippets) do
		if snip.name == "_skel" then
			vim.cmd("startinsert")
			ls.snip_expand(snip)
			return
		end
	end
end

aucmd("BufNewFile", {
	pattern = "*.md", -- scope at event level, no dir check needed
	callback = function()
		vim.schedule(load_document_skeleton) -- defer past filetype detection
	end,
})

-- ── autocmds.lua patch ──────────────────────────────────────────────────────
--
-- Add these lines directly after the existing markdown BufNewFile block:
--
--   aucmd("BufNewFile", {
--       pattern = "*.md",
--       callback = function()
--           vim.schedule(load_document_skeleton)
--       end,
--   })
--
-- ↓↓↓ INSERT BELOW THAT BLOCK ↓↓↓

aucmd("BufNewFile", {
	-- .hpp / .hh / .hxx → filetype=cpp → _skel expands #pragma once
	-- .h                 → filetype=c   → _skel expands traditional guard
	-- (filetype for empty .h defaults to "c" per your ftdetect heuristic)
	pattern = { "*.h", "*.hpp", "*.hh", "*.hxx" },
	callback = function()
		vim.schedule(load_document_skeleton) -- reuses the existing local function
	end,
})
