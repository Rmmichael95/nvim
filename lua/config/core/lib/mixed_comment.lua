-- lua/config/core/lib/mixed_comment.lua
--
-- Per-line, context-aware commenter for mixed-language files (PHP/HTML, etc.)
--
-- ── Why this exists ──────────────────────────────────────────────────────────
-- mini.comment calls custom_commentstring ONCE for the whole visual selection
-- (at the cursor's position), then applies that single style to every line.
-- In a mixed PHP/HTML file, selecting across a language boundary means every
-- line ends up with whichever language the cursor happened to land in.
--
-- ── What this does ───────────────────────────────────────────────────────────
-- Iterates every line in the selection and asks ts_context_commentstring for
-- the commentstring at *that specific line*, so:
--   PHP lines  → // comment
--   HTML lines → <!-- comment -->
-- ...even inside the same visual block.
--
-- ── Usage (from an ftplugin) ─────────────────────────────────────────────────
--   require("config.core.lib.mixed_comment").setup_buf_keymaps()

local M = {}

-- ── Internal helpers ─────────────────────────────────────────────────────────

--- Return the commentstring appropriate for line `lnum` (1-indexed).
--- Falls back to vim.bo.commentstring if treesitter context isn't available.
local function cs_at(lnum)
	local ok, tsc = pcall(require, "ts_context_commentstring")
	if ok then
		-- cursor_pos is 0-indexed row; col 0 is fine for language detection
		local cs = tsc.calculate_commentstring({ cursor_pos = { lnum - 1, 0 } })
		if cs and cs ~= "" then
			return cs
		end
	end
	return vim.bo.commentstring
end

--- Split a commentstring into its trimmed left and right markers.
---   "// %s"        → "//",  ""
---   "<!-- %s -->"  → "<!--", "-->"
---   "/* %s */"    → "/*",   "*/"
local function parse_cs(cs)
	local left, right = cs:match("^%s*(.-)%s*%%s%s*(.-)%s*$")
	return left or "", right or ""
end

--- Return true if `line` is already commented according to `cs`.
--- Blank lines are treated as "already handled" so they are skipped cleanly.
local function is_commented(line, cs)
	if vim.trim(line) == "" then
		return true
	end
	local left, right = parse_cs(cs)
	local trimmed = vim.trim(line)
	local left_ok = left == "" or trimmed:sub(1, #left) == left
	local right_ok = right == "" or trimmed:sub(-#right) == right
	return left_ok and right_ok
end

--- Wrap `line` in comment markers, preserving its leading indentation.
local function add_comment(line, cs)
	local left, right = parse_cs(cs)
	local indent = line:match("^%s*") or ""
	local content = line:sub(#indent + 1)
	if right ~= "" then
		return indent .. left .. " " .. content .. " " .. right
	else
		return indent .. left .. " " .. content
	end
end

--- Strip comment markers from `line`, preserving indentation.
local function remove_comment(line, cs)
	local left, right = parse_cs(cs)
	local indent = line:match("^%s*") or ""
	local content = vim.trim(line:sub(#indent + 1))

	-- Strip left marker + one optional space
	if left ~= "" and content:sub(1, #left) == left then
		content = content:sub(#left + 1)
		content = content:match("^ (.*)") or content
	end
	-- Strip right marker + one optional trailing space
	local trimmed_content = vim.trim(content)
	if right ~= "" and trimmed_content:sub(-#right) == right then
		trimmed_content = trimmed_content:sub(1, -(#right + 1))
		trimmed_content = trimmed_content:match("(.*%S)") or trimmed_content
		content = trimmed_content
	end

	return indent .. vim.trim(content)
end

-- ── Public API ────────────────────────────────────────────────────────────────

--- Toggle comments on lines [start_lnum, end_lnum] (1-indexed, inclusive).
--- Each line is commented/uncommented with its own language-appropriate style.
function M.toggle(start_lnum, end_lnum)
	local bufnr = vim.api.nvim_get_current_buf()

	-- Collect per-line info: raw text + the correct commentstring for that line.
	local entries = {}
	for lnum = start_lnum, end_lnum do
		local text = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1] or ""
		entries[#entries + 1] = { lnum = lnum, text = text, cs = cs_at(lnum) }
	end

	-- Toggle direction: uncomment only when EVERY non-blank line is already commented.
	local all_commented = true
	for _, e in ipairs(entries) do
		if vim.trim(e.text) ~= "" and not is_commented(e.text, e.cs) then
			all_commented = false
			break
		end
	end

	-- Build the replacement lines.
	local new_lines = {}
	for _, e in ipairs(entries) do
		if vim.trim(e.text) == "" then
			-- Preserve blank lines exactly.
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
--- The motion type argument ('line', 'char', 'block') is always treated as linewise.
function M.operator(_type)
	local start_lnum = vim.api.nvim_buf_get_mark(0, "[")[1]
	local end_lnum = vim.api.nvim_buf_get_mark(0, "]")[1]
	M.toggle(start_lnum, end_lnum)
end

--- Install buffer-local gc / gcc keymaps that use this per-line commenter.
--- Shadows mini.comment's global mappings for this buffer only —
--- all other filetypes are completely unaffected.
function M.setup_buf_keymaps()
	local buf = vim.api.nvim_get_current_buf()
	local base = { buffer = buf, silent = true }

	-- gcc → comment/uncomment current line
	vim.keymap.set("n", "gcc", function()
		local lnum = vim.fn.line(".")
		M.toggle(lnum, lnum)
	end, vim.tbl_extend("force", base, { desc = "Toggle comment (line)" }))

	-- gc<motion> → comment motion target (operates linewise)
	vim.keymap.set("n", "gc", function()
		vim.o.operatorfunc = "v:lua.require'config.core.lib.mixed_comment'.operator"
		return "g@"
	end, vim.tbl_extend("force", base, { expr = true, desc = "Comment operator" }))

	-- gc in visual mode → comment/uncomment selection
	-- NOTE: Read visual extents via getpos("v") / getpos(".") while STILL in
	-- visual mode, BEFORE feeding <Esc>. The marks '< and '> only reflect the
	-- *previous* visual selection until Neovim exits visual mode and commits them.
	vim.keymap.set("v", "gc", function()
		local anchor = vim.fn.getpos("v") -- anchor of current visual selection
		local cursor = vim.fn.getpos(".") -- cursor end of current visual selection
		local start_lnum = math.min(anchor[2], cursor[2])
		local end_lnum = math.max(anchor[2], cursor[2])

		-- Exit visual mode so marks are committed, then apply toggle.
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
		M.toggle(start_lnum, end_lnum)
	end, vim.tbl_extend("force", base, { desc = "Toggle comment (visual)" }))
end

return M
