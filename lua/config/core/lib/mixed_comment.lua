-- lua/config/core/lib/mixed_comment.lua
--
-- Per-line, context-aware commenter for mixed-language files (PHP/HTML, etc.)
--
-- ── Why treesitter is not used for PHP ──────────────────────────────────────
-- Two prior strategies failed:
--   cursor_pos  → unrecognised option, silently ignored; cursor position used
--                 for every line → every line got same commentstring.
--   location    → treesitter injection boundaries are byte offsets, not line
--                 boundaries; language_for_range misclassified lines near PHP/
--                 HTML transitions.
-- The PHP filetype now uses a simple <?php / ?> tag scanner instead.
--
-- ── Standalone PHP tag rule ──────────────────────────────────────────────────
-- Lines that are ONLY a PHP structural tag (<?php, <?=, ?>) are left unchanged.
-- Two insoluble PHP spec constraints make it impossible to comment them:
--
--   <!-- <?php --> causes a syntax error: PHP ignores HTML comments, enters PHP
--                  mode on <?php, then sees " -->" as invalid PHP code.
--
--   // ?>          does NOT suppress the close tag: per the PHP manual, ?>
--                  "breaks out of PHP mode" even when preceded by //
--                  ("// or # cannot influence that").
--
-- Leaving structural tags in place is semantically correct. Standalone <?php
-- and ?> carry no logic — they are just mode-switch markers.  The PHP code
-- BETWEEN them is disabled by // comments, leaving an empty PHP block that
-- does nothing.
--
-- ── Usage ────────────────────────────────────────────────────────────────────
--   require("config.core.lib.mixed_comment").setup_buf_keymaps()

local M = {}

-- ── Standalone PHP tag detection ─────────────────────────────────────────────

--- True when the line's only content is a PHP open or close tag.
--- These lines are skipped entirely during comment/uncomment (see module header).
local function is_php_tag_only(line)
	local t = vim.trim(line)
	-- Match: <?php, <?=, or ?> with nothing else on the line.
	return t == "<?php" or t == "<?=" or t == "?>"
end

-- ── PHP context scanner ───────────────────────────────────────────────────────

--- Walk lines 1..end_lnum once, tracking <?php / ?> transitions.
--- Returns php_ctx[lnum] = true  when that line STARTS in PHP context.
---
--- "Starts in PHP context" = an unclosed <?php or <?= tag has been seen before
--- this line, with no intervening ?>.
---
--- Important: ctx[lnum] is snapshotted BEFORE we process that line's own tags,
--- so a line that OPENS a new PHP block (standalone "<?php") is marked HTML
--- context (false) — it will be skipped by is_php_tag_only() rather than
--- wrapped in <!-- -->.  A line that CLOSES a block ("?>") is marked PHP
--- context (true) — it will also be skipped by is_php_tag_only().
local function build_php_ctx(bufnr, end_lnum)
	local raw = vim.api.nvim_buf_get_lines(bufnr, 0, end_lnum, false)
	local ctx = {}
	local in_php = false

	for i, line in ipairs(raw) do
		ctx[i] = in_php -- snapshot BEFORE processing this line's tags

		local pos = 1
		while pos <= #line do
			if not in_php then
				local s1 = line:find("<%?php", pos)
				local s2 = line:find("<%?=", pos)
				local open = (s1 and s2) and math.min(s1, s2) or s1 or s2
				if open then
					in_php = true
					pos = open + 2
				else
					break
				end
			else
				local close = line:find("%?>", pos)
				if close then
					in_php = false
					pos = close + 2
				else
					break
				end
			end
		end
	end

	return ctx
end

-- ── Treesitter / plugin fallback (non-PHP filetypes) ─────────────────────────

local LANG_CS = {
	php = "// %s",
	html = "<!-- %s -->",
	javascript = "// %s",
	typescript = "// %s",
	tsx = "// %s",
	jsx = "// %s",
	css = "/* %s */",
	scss = "// %s",
	lua = "-- %s",
	python = "# %s",
	bash = "# %s",
	c = "// %s",
	cpp = "// %s",
}

local function cs_via_treesitter(bufnr, lnum)
	local row = lnum - 1

	local ok, tsc = pcall(require, "ts_context_commentstring")
	if ok then
		local cs = tsc.calculate_commentstring({ location = { row, 0 } })
		if cs and cs ~= "" then
			return cs
		end
	end

	local ts_ok, parser = pcall(vim.treesitter.get_parser, bufnr)
	if ts_ok and parser then
		local lt = parser:language_for_range({ row, 0, row, 0 })
		if lt then
			local cs = LANG_CS[lt:lang()]
			if cs then
				return cs
			end
		end
	end

	return vim.bo[bufnr].commentstring
end

-- ── Commentstring resolver factory ────────────────────────────────────────────

local function make_cs_resolver(bufnr, end_lnum)
	if vim.bo[bufnr].filetype == "php" then
		local php_ctx = build_php_ctx(bufnr, end_lnum)
		return function(lnum)
			return php_ctx[lnum] and "// %s" or "<!-- %s -->"
		end
	else
		return function(lnum)
			return cs_via_treesitter(bufnr, lnum)
		end
	end
end

-- ── Line-level comment helpers ────────────────────────────────────────────────

local function parse_cs(cs)
	local l, r = cs:match("^%s*(.-)%s*%%s%s*(.-)%s*$")
	return l or "", r or ""
end

local function is_commented(line, cs)
	if vim.trim(line) == "" then
		return true
	end
	local l, r = parse_cs(cs)
	local t = vim.trim(line)
	return (l == "" or t:sub(1, #l) == l) and (r == "" or t:sub(-#r) == r)
end

local function add_comment(line, cs)
	local l, r = parse_cs(cs)
	local indent = line:match("^%s*") or ""
	local content = line:sub(#indent + 1)
	return r ~= "" and (indent .. l .. " " .. content .. " " .. r) or (indent .. l .. " " .. content)
end

local function remove_comment(line, cs)
	local l, r = parse_cs(cs)
	local indent = line:match("^%s*") or ""
	local content = vim.trim(line:sub(#indent + 1))

	if l ~= "" and content:sub(1, #l) == l then
		content = content:sub(#l + 1)
		content = content:match("^ (.*)") or content
	end
	local tc = vim.trim(content)
	if r ~= "" and tc:sub(-#r) == r then
		tc = tc:sub(1, -(#r + 1))
		tc = tc:match("(.*%S)") or tc
		content = tc
	end
	return indent .. vim.trim(content)
end

-- ── Public API ────────────────────────────────────────────────────────────────

function M.toggle(start_lnum, end_lnum)
	local bufnr = vim.api.nvim_get_current_buf()
	local cs_for = make_cs_resolver(bufnr, end_lnum)

	-- Gather per-line data.
	local entries = {}
	for lnum = start_lnum, end_lnum do
		local text = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1] or ""
		entries[#entries + 1] = {
			text = text,
			cs = cs_for(lnum),
			skip = is_php_tag_only(text), -- standalone tag: pass through unchanged
		}
	end

	-- Decide direction: uncomment when ALL non-skip, non-blank lines are commented.
	local all_commented = true
	for _, e in ipairs(entries) do
		if not e.skip and vim.trim(e.text) ~= "" and not is_commented(e.text, e.cs) then
			all_commented = false
			break
		end
	end

	-- Build replacement lines.
	local new_lines = {}
	for _, e in ipairs(entries) do
		if e.skip or vim.trim(e.text) == "" then
			-- Standalone PHP structural tag or blank line: preserve exactly.
			new_lines[#new_lines + 1] = e.text
		elseif all_commented then
			new_lines[#new_lines + 1] = remove_comment(e.text, e.cs)
		else
			new_lines[#new_lines + 1] = add_comment(e.text, e.cs)
		end
	end

	vim.api.nvim_buf_set_lines(bufnr, start_lnum - 1, end_lnum, false, new_lines)
end

function M.operator(_type)
	local s = vim.api.nvim_buf_get_mark(0, "[")[1]
	local e = vim.api.nvim_buf_get_mark(0, "]")[1]
	M.toggle(s, e)
end

function M.setup_buf_keymaps()
	local buf = vim.api.nvim_get_current_buf()
	local base = { buffer = buf, silent = true }

	vim.keymap.set("n", "gcc", function()
		M.toggle(vim.fn.line("."), vim.fn.line("."))
	end, vim.tbl_extend("force", base, { desc = "Toggle comment (line)" }))

	vim.keymap.set("n", "gc", function()
		vim.o.operatorfunc = "v:lua.require'config.core.lib.mixed_comment'.operator"
		return "g@"
	end, vim.tbl_extend("force", base, { expr = true, desc = "Comment operator" }))

	-- Read visual extents BEFORE <Esc> — '< and '> only reflect the previous
	-- selection until Neovim exits visual mode and commits them.
	vim.keymap.set("v", "gc", function()
		local anchor = vim.fn.getpos("v")
		local cursor = vim.fn.getpos(".")
		local s = math.min(anchor[2], cursor[2])
		local e = math.max(anchor[2], cursor[2])
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
		M.toggle(s, e)
	end, vim.tbl_extend("force", base, { desc = "Toggle comment (visual)" }))
end

return M
