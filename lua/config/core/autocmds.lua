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

-- smart cursorline
local cline = vim.api.nvim_create_augroup("CursorLine", { clear = true })
aucmd({ "WinLeave", "InsertEnter" }, { group = cline, pattern = "*", command = "set nocursorline" })
aucmd({ "WinEnter", "InsertLeave" }, { group = cline, pattern = "*", command = "set cursorline" })

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

local trailing = vim.api.nvim_create_augroup("Trailing", { clear = true })
aucmd("InsertEnter", {
	group = trailing,
	pattern = "*",
	callback = function()
		vim.opt.listchars:remove("trail")
	end,
})

aucmd("InsertLeave", {
	group = trailing,
	pattern = "*",
	callback = function()
		vim.opt.listchars:append({ trail = "⌴" })
	end,
})

local vcs_conflict = vim.api.nvim_create_augroup("VCSConflictMarkers", { clear = true })
vim.api.nvim_create_autocmd("BufWinEnter", {
	group = vcs_conflict,
	pattern = "*",
	desc = "Highlight VCS conflict markers",
	callback = function()
		vim.fn.matchadd("ErrorMsg", [[^\(<\|=\|>\)\{7\}\([^=].\+\)\?$]])
	end,
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

-- Python skeleton on new file
aucmd("BufNewFile", {
	pattern = "*.py",
	callback = function()
		vim.schedule(load_document_skeleton)
	end,
})

-- R skeleton on new file
aucmd("BufNewFile", {
	pattern = { "*.r", "*.R" },
	callback = function()
		vim.schedule(load_document_skeleton)
	end,
})

aucmd("BufNewFile", {
	pattern = { "*.php" },
	callback = function()
		vim.schedule(load_document_skeleton)
	end,
})

aucmd("BufNewFile", {
	pattern = { "*.html", "*.htm" },
	callback = function()
		vim.schedule(load_document_skeleton)
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

aucmd("BufReadPost", {
	group = vim.api.nvim_create_augroup("last_loc", { clear = true }),
	callback = function(event)
		local exclude = { "gitcommit" }
		local buf = event.buf
		if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
			return
		end
		vim.b[buf].lazyvim_last_loc = true
		local mark = vim.api.nvim_buf_get_mark(buf, '"')
		local lcount = vim.api.nvim_buf_line_count(buf)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

aucmd("FileType", {
	group = vim.api.nvim_create_augroup("close_with_q", { clear = true }),
	pattern = {
		"help",
		"lspinfo",
		"notify",
		"qf",
		"startuptime",
		"checkhealth",
		"neotest-output",
		"neotest-summary",
		"gitsigns-blame",
		"tsplayground",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
	end,
})

aucmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("auto_create_dir", { clear = true }),
	callback = function(event)
		if event.match:match("^%w%w+:[\\/][\\/]") then
			return
		end
		local file = vim.uv.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})

aucmd("VimResized", {
	group = vim.api.nvim_create_augroup("resize_splits", { clear = true }),
	callback = function()
		vim.cmd("tabdo wincmd =")
	end,
})

aucmd("FileType", {
	group = vim.api.nvim_create_augroup("wrap_spell", { clear = true }),
	pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.spell = true
	end,
})

-- Automatically make new Perl files executable on save
aucmd("BufWritePost", {
	pattern = "*.pl",
	callback = function()
		local fname = vim.fn.expand("%:p")
		-- Only target your specific learning directory paths if desired
		if string.match(fname, "perl") then
			vim.fn.system("chmod +x " .. vim.fn.shellescape(fname))
		end
	end,
})
