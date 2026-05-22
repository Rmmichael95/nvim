-- lua/config/core/lib/mixed_comment.lua
--
-- Per-line, context-aware commenter for mixed-language files (PHP/HTML, etc.)
--
-- ── Root cause of previous failures ─────────────────────────────────────────
-- Two successive strategies failed for WordPress PHP template files:
--
--   1. ts_context_commentstring({ cursor_pos = ... })  — `cursor_pos` is not a
--      recognised option; the plugin silently ignored it and always used the real
--      cursor position, so every line got the same commentstring.
--
--   2. ts_context_commentstring({ location = ... }) +
--      parser:language_for_range()  — both query the treesitter parse-tree
--      injection BOUNDARIES, which do not align cleanly with Neovim line
--      numbers in PHP template files (injected HTML ranges start/end at byte
--      offsets, not line starts).  HTML lines near a boundary were misclassified
--      as PHP and vice-versa.
--
-- ── Solution for PHP files ───────────────────────────────────────────────────
-- Scan from line 1, track <?php / ?> state, record which line STARTS inside a
-- PHP block.  O(n) once per toggle call.  Deterministic, no treesitter needed.
--
--   PHP context  (line starts inside an unclosed <?php … block) → "// %s"
--   HTML context (line is in template space between PHP tags)   → "<!-- %s -->"
--
-- ── Solution for other mixed files ──────────────────────────────────────────
-- Fall through to ts_context_commentstring (location option) then
-- language_for_range, then vim.bo.commentstring.  These work fine for files
-- where injections are first-class (blade, JSX, etc.).
--
-- ── Usage (from an ftplugin) ─────────────────────────────────────────────────
--   require("config.core.lib.mixed_comment").setup_buf_keymaps()

local M = {}

-- ── PHP context scanner ───────────────────────────────────────────────────────

--- Walk lines 1..end_lnum once, tracking <?php / ?> transitions.
--- Returns: php_ctx[lnum] = true  →  line STARTS in PHP context
---          php_ctx[lnum] = false →  line STARTS in HTML template context
---
--- "Starts in PHP context" means we have seen a <?php or <?= that has not yet
--- been closed by a matching ?>.  Standalone template lines like
---     <?php if ( have_posts() ) : ?>
--- START in HTML context (in_php = false when we reach that line) because the
--- <?php that opens them is on the SAME line, so context_map[lnum] is snapshot
--- BEFORE we process that line's tags.  They get <!-- -->, which is appropriate:
--- HTML comments wrap the whole template-PHP tag cleanly.
---
--- Lines that are purely inside an open PHP block (e.g. the body of a loop or
--- function call block) start with in_php = true and get //.
local function build_php_ctx(bufnr, end_lnum)
	local raw = vim.api.nvim_buf_get_lines(bufnr, 0, end_lnum, false)
	local ctx = {}
	local in_php = false

	for i, line in ipairs(raw) do
		-- Snapshot context BEFORE processing this line's PHP tags.
		ctx[i] = in_php

		local pos = 1
		while pos <= #line do
			if not in_php then
				-- Find next opening tag: <?php or <?= (short echo)
				local s1 = line:find("<%?php", pos)
				local s2 = line:find("<%?=", pos)
				local open = (s1 and s2) and math.min(s1, s2) or s1 or s2
				if open then
					in_php = true
					pos = open + 2 -- advance past <?
				else
					break -- no more transitions on this line
				end
			else
				-- Find next closing tag: ?>
				local close = line:find("%?>", pos)
				if close then
					in_php = false
					pos = close + 2 -- advance past ?>
				else
					break
				end
			end
		end
	end

	return ctx
end

-- ── Treesitter / plugin fallback (non-PHP mixed files) ───────────────────────

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

	-- Try ts_context_commentstring with the correct `location` option.
	-- (Not `cursor_pos` — that key is unrecognised and silently ignored.)
	local ok, tsc = pcall(require, "ts_context_commentstring")
	if ok then
		local cs = tsc.calculate_commentstring({ location = { row, 0 } })
		if cs and cs ~= "" then
			return cs
		end
	end

	-- Try Neovim's native language_for_range as a secondary check.
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

--- Returns cs(lnum) → commentstring, choosing strategy by filetype.
--- For PHP: precomputed scan map (built once, O(n) total).
--- For others: treesitter query per line.
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

--- Split commentstring into (left_marker, right_marker), both trimmed.
---   "// %s"       → "//",   ""
---   "<!-- %s -->" → "<!--", "-->"
local function parse_cs(cs)
	local l, r = cs:match("^%s*(.-)%s*%%s%s*(.-)%s*$")
	return l or "", r or ""
end

--- True when `line` already carries comment markers from `cs`.
--- Blank lines always return true (they are skipped during toggle).
local function is_commented(line, cs)
	if vim.trim(line) == "" then
		return true
	end
	local l, r = parse_cs(cs)
	local t = vim.trim(line)
	return (l == "" or t:sub(1, #l) == l) and (r == "" or t:sub(-#r) == r)
end

--- Wrap `line` with comment markers, preserving leading indentation.
local function add_comment(line, cs)
	local l, r = parse_cs(cs)
	local indent = line:match("^%s*") or ""
	local content = line:sub(#indent + 1)
	if r ~= "" then
		return indent .. l .. " " .. content .. " " .. r
	else
		return indent .. l .. " " .. content
	end
end

--- Strip comment markers from `line`, preserving leading indentation.
local function remove_comment(line, cs)
	local l, r = parse_cs(cs)
	local indent = line:match("^%s*") or ""
	local content = vim.trim(line:sub(#indent + 1))

	-- Remove left marker + one optional space.
	if l ~= "" and content:sub(1, #l) == l then
		content = content:sub(#l + 1)
		content = content:match("^ (.*)") or content -- eat one leading space
	end

	-- Remove right marker + one optional trailing space.
	local tc = vim.trim(content)
	if r ~= "" and tc:sub(-#r) == r then
		tc = tc:sub(1, -(#r + 1))
		tc = tc:match("(.*%S)") or tc -- eat one trailing space
		content = tc
	end

	return indent .. vim.trim(content)
end

-- ── Public API ────────────────────────────────────────────────────────────────

--- Toggle comments on lines [start_lnum, end_lnum] (1-indexed, inclusive).
--- Direction: uncomment when ALL non-blank lines are already commented,
--- otherwise comment.
function M.toggle(start_lnum, end_lnum)
	local bufnr = vim.api.nvim_get_current_buf()
	local cs_for = make_cs_resolver(bufnr, end_lnum)

	-- Gather per-line data.
	local entries = {}
	for lnum = start_lnum, end_lnum do
		local text = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1] or ""
		entries[#entries + 1] = { text = text, cs = cs_for(lnum) }
	end

	-- Decide direction.
	local all_commented = true
	for _, e in ipairs(entries) do
		if vim.trim(e.text) ~= "" and not is_commented(e.text, e.cs) then
			all_commented = false
			break
		end
	end

	-- Build replacement lines.
	local new_lines = {}
	for _, e in ipairs(entries) do
		if vim.trim(e.text) == "" then
			new_lines[#new_lines + 1] = e.text
		elseif all_commented then
			new_lines[#new_lines + 1] = remove_comment(e.text, e.cs)
		else
			new_lines[#new_lines + 1] = add_comment(e.text, e.cs)
		end
	end

	vim.api.nvim_buf_set_lines(bufnr, start_lnum - 1, end_lnum, false, new_lines)
end

--- Operator callback — registered via `vim.o.operatorfunc`.
function M.operator(_type)
	local s = vim.api.nvim_buf_get_mark(0, "[")[1]
	local e = vim.api.nvim_buf_get_mark(0, "]")[1]
	M.toggle(s, e)
end

--- Install buffer-local gc / gcc keymaps that shadow mini.comment for this
--- buffer only.  Call from any mixed-language ftplugin.
function M.setup_buf_keymaps()
	local buf = vim.api.nvim_get_current_buf()
	local base = { buffer = buf, silent = true }

	-- gcc — current line
	vim.keymap.set("n", "gcc", function()
		M.toggle(vim.fn.line("."), vim.fn.line("."))
	end, vim.tbl_extend("force", base, { desc = "Toggle comment (line)" }))

	-- gc<motion> — operator
	vim.keymap.set("n", "gc", function()
		vim.o.operatorfunc = "v:lua.require'config.core.lib.mixed_comment'.operator"
		return "g@"
	end, vim.tbl_extend("force", base, { expr = true, desc = "Comment operator" }))

	-- gc — visual selection
	-- Read extents via getpos() WHILE STILL IN visual mode, before <Esc> commits
	-- the marks — '< and '> reflect the PREVIOUS selection until that point.
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
