-- after/ftplugin/markdown.lua
-- Buffer-local environment for markdown files.
--
-- Coordinates with:
--   render-markdown.nvim  (conceallevel, wrap needed for rendering)
--   conform.nvim          (prettier_md + mdsf handle formatting)
--   marksman              (LSP — wiki-links, outline, go-to-def)
--   markdownlint-cli2     (lint)
--   Snacks keymaps        (<leader>mh/ml/mn/ms defined in render-markdown.lua)
--   autocmds.lua          (BufNewFile skeleton expansion)

-- ── Prose / display ──────────────────────────────────────────────────────────
vim.wo.wrap = true -- soft-wrap long lines (prose, not code)
vim.wo.linebreak = true -- break at word boundaries, not mid-word
vim.wo.breakindent = true -- wrapped continuation aligns with indent

-- render-markdown.nvim needs conceallevel ≥ 1 to substitute icons.
-- Global is already 2 from options.lua; this makes it explicit and
-- buffer-local so toggling with <leader>uc doesn't leak between windows.
vim.wo.conceallevel = 2

-- ── Spell checking ───────────────────────────────────────────────────────────
vim.wo.spell = true
vim.bo.spelllang = "en"

-- ── Indentation ──────────────────────────────────────────────────────────────
-- Markdown spec: 4-space indent for nested lists / code fences
vim.bo.tabstop = 2 -- visual width of a tab character
vim.bo.softtabstop = 2 -- spaces inserted on <Tab> in insert mode
vim.bo.shiftwidth = 2 -- indent step for >>/<<
vim.bo.expandtab = true -- always spaces, never tabs

-- ── Format options ───────────────────────────────────────────────────────────
-- Prose writing: auto-wrap comments, don't auto-wrap code lines.
-- 'r'  — insert comment leader on <Enter>
-- 'q'  — allow gq to format comments
-- 'n'  — recognize numbered lists
-- 'j'  — remove comment leader when joining lines
-- No 'c' or 't' — let prettier/mdsf handle hard-wrapping, not Neovim
vim.bo.formatoptions = "rqnj"

-- Prevent Neovim's built-in gq from hard-wrapping prose; defer to conform
-- (same pattern used in vimscript.lua for vimscript buffers)
vim.bo.formatexpr = ""

-- textwidth = 0 disables Neovim's automatic hard-wrap on insert.
-- prettier_md uses --prose-wrap=preserve so it respects existing newlines.
vim.bo.textwidth = 0

-- ── Folding ───────────────────────────────────────────────────────────────────
-- Treesitter folds are set globally; override for markdown to use heading folds
-- if you prefer.  Comment out to fall back to the global treesitter expr.
-- vim.wo.foldmethod = "expr"
-- vim.wo.foldexpr   = "v:lua.vim.treesitter.foldexpr()"
vim.wo.foldenable = false -- start with all folds open (matches global)

-- ── Keymaps (buffer-local) ───────────────────────────────────────────────────
local map = function(lhs, rhs, desc)
	vim.keymap.set("n", lhs, rhs, { buffer = true, silent = true, desc = desc })
end

-- Toggle checkbox: [ ] ↔ [x]
map("<leader>mx", function()
	local line = vim.api.nvim_get_current_line()
	local toggled = line:gsub("%[%s%]", "[x]"):gsub("%[x%]", "[ ]")
	-- if first gsub matched, we're done; if second matched from [x]→[ ], done
	-- but that would flip twice — use exclusive logic:
	if line:find("%[%s%]") then
		toggled = line:gsub("%[%s%]", "[x]", 1)
	elseif line:find("%[x%]") then
		toggled = line:gsub("%[x%]", "[ ]", 1)
	else
		toggled = line -- nothing to toggle
	end
	vim.api.nvim_set_current_line(toggled)
end, "Toggle checkbox")

-- Insert a markdown link from clipboard ([ text ](clipboard))
map("<leader>mp", function()
	local url = vim.fn.getreg("+"):gsub("%s+", "")
	if url == "" then
		vim.notify("Clipboard empty", vim.log.levels.WARN)
		return
	end
	local word = vim.fn.expand("<cword>")
	local replacement = string.format("[%s](%s)", word, url)
	vim.cmd("normal! ciw" .. replacement)
end, "Paste URL as markdown link")
