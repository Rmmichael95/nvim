-- lua/config/plugins/cpp_tools.lua
-- C/C++ developer-experience layer.
--
-- Provides:
--   :CppScaffold   — parse current header, write a .cpp with skeleton definitions
--   :CppSwitch     — jump between header and .cpp (via clangd)
--   treesitter-refactor — highlight usages, smart-rename within file, goto next/prev usage
--   LspAttach keymaps (c/cpp only) for clangd extras and the commands above
--
-- Install: drop this file into lua/config/plugins/ — lazy.nvim picks it up automatically.

-- ═══════════════════════════════════════════════════════════════════════════
-- §1  Scaffold — build .cpp definitions from a header's text
-- ═══════════════════════════════════════════════════════════════════════════
--
-- Strategy: single-pass line accumulator.
--   • Strip block comments, line comments, preprocessor lines.
--   • Track { } depth to know when we enter/leave a class/struct scope.
--   • Accumulate tokens until we hit a `;` to form one statement.
--   • Filter to function declarations only (see `is_func_decl`).
--   • Rewrite each declaration into a definition by:
--       - removing virtual / explicit / inline / static / [[nodiscard]] prefixes
--       - removing override / final suffixes
--       - injecting ClassName:: before the function name
--       - replacing `;` with `\n{\n\n}`

local function build_scaffold(bufnr)
	local raw = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local text = table.concat(raw, "\n")

	-- ── strip comments ───────────────────────────────────────────────────
	text = text:gsub("/%*.-%*/", " ") -- block comments
	text = text:gsub("//[^\n]*", "") -- line comments (keep newline)
	text = text:gsub("#[^\n]*", "") -- preprocessor

	local lines = vim.split(text, "\n")

	-- ── state ────────────────────────────────────────────────────────────
	local class_stack = {} -- { { name="Foo", depth=N }, ... }
	local brace_depth = 0
	local stmt_buf = {} -- accumulates tokens for the current statement
	local results = {} -- { text=..., class_ctx={ {name,...}, ... } }

	local function flush_stmt()
		if #stmt_buf == 0 then
			return
		end
		local stmt = table.concat(stmt_buf, " "):gsub("%s+", " "):match("^%s*(.-)%s*$")
		stmt_buf = {}
		if stmt == "" then
			return
		end
		table.insert(results, { text = stmt, class_ctx = vim.deepcopy(class_stack) })
	end

	for _, line in ipairs(lines) do
		local trimmed = line:match("^%s*(.-)%s*$")
		if trimmed == "" then
			goto continue
		end

		-- Detect class/struct opening on this line
		local cs = trimmed:match("^class%s+(%a[%w_]*)")
			or trimmed:match("^struct%s+(%a[%w_]*)")
			or line:match("%f[%a]class%s+(%a[%w_]*)")
			or line:match("%f[%a]struct%s+(%a[%w_]*)")

		-- Count braces
		local opens = select(2, trimmed:gsub("{", ""))
		local closes = select(2, trimmed:gsub("}", ""))

		if trimmed:find("{") then
			-- A brace means either the start of a class body or an inline definition.
			-- Either way flush whatever was accumulating — it's not a bare declaration.
			stmt_buf = {}
			brace_depth = brace_depth + opens - closes
			if cs and opens > 0 then
				table.insert(class_stack, { name = cs, depth = brace_depth })
			end
		elseif trimmed:find("}") then
			stmt_buf = {}
			brace_depth = brace_depth + opens - closes -- opens=0 here typically
			-- Pop class context if we've closed its scope
			while #class_stack > 0 and brace_depth < class_stack[#class_stack].depth do
				table.remove(class_stack)
			end
		elseif trimmed:find(";") then
			-- End of a statement
			table.insert(stmt_buf, trimmed)
			flush_stmt()
		else
			-- Mid-statement line (multi-line declaration)
			table.insert(stmt_buf, trimmed)
		end

		::continue::
	end

	-- ── filter to function declarations ──────────────────────────────────
	local function is_func_decl(s)
		if not s:find("%(") then
			return false
		end -- no parameter list
		if s:find("^%s*using%s") then
			return false
		end -- using declaration
		if s:find("^%s*typedef%s") then
			return false
		end
		if s:find("^%s*friend%s") then
			return false
		end
		if s:find("= 0%s*;?%s*$") then
			return false
		end -- pure virtual
		if s:find("= delete%s*;") then
			return false
		end
		if s:find("= default%s*;") then
			return false
		end
		if s:find("constexpr%s") then
			return false
		end -- def must stay in header
		if s:find("consteval%s") then
			return false
		end
		if s:find("{") then
			return false
		end -- inline definition
		if not s:find(";%s*$") then
			return false
		end
		return true
	end

	-- ── rewrite declaration → definition ─────────────────────────────────
	local function decl_to_def(decl, class_ctx)
		local s = decl

		-- Remove trailing semicolon
		s = s:match("^%s*(.-)%s*;%s*$") or s

		-- Strip leading specifiers that don't appear in out-of-line definitions
		for _, kw in ipairs({
			"virtual ",
			"explicit ",
			"inline ",
			"static ",
			"%[%[nodiscard%]%] ",
		}) do
			s = s:gsub("^%s*" .. kw, "")
		end

		-- Strip trailing override / final (keep const, noexcept, ref-qualifiers)
		s = s:gsub("%s+override%s*$", "")
		s = s:gsub("%s+final%s*$", "")
		s = s:match("^%s*(.-)%s*$")

		-- ── Locate the opening paren of the parameter list ────────────────
		-- Skip parens that follow "operator" (e.g. operator()).
		local paren_pos = nil
		do
			local search = 1
			while true do
				local p = s:find("%(", search)
				if not p then
					break
				end
				local pre_slice = s:sub(1, p - 1)
				if not pre_slice:match("operator%s*$") then
					paren_pos = p
					break
				end
				search = p + 1
			end
		end

		if not paren_pos then
			return nil
		end

		local before = s:sub(1, paren_pos - 1):match("^%s*(.-)%s*$")
		local after = s:sub(paren_pos) -- "(params) const noexcept" etc.

		-- ── Extract function name from "before" ───────────────────────────
		-- Handles: operator overloads, destructors (~), regular names.
		local pre_name, func_name

		if before:find("operator") then
			-- "bool operator==" → pre="bool ", fname="operator=="
			pre_name, func_name = before:match("^(.*%f[%a])?(operator.-)%s*$")
			if not func_name then
				pre_name, func_name = "", before
			end
		else
			-- Last identifier-like token (including ~Dtor)
			pre_name, func_name = before:match("^(.*[^%w_~])([~]?[%a_][%w_]*)%s*$")
			if not func_name then
				-- No non-identifier prefix: constructor with no return type
				func_name = before:match("^([~]?[%a_][%w_]*)%s*$")
				pre_name = ""
			end
		end

		if not func_name or func_name == "" then
			return nil
		end

		-- ── Build class:: prefix ──────────────────────────────────────────
		local scope = ""
		if #class_ctx > 0 then
			-- Already scoped? (shouldn't happen in a header, but be safe)
			if not (pre_name or ""):find("::") then
				local names = {}
				for _, cls in ipairs(class_ctx) do
					table.insert(names, cls.name)
				end
				scope = table.concat(names, "::") .. "::"
			end
		end

		return (pre_name or "") .. scope .. func_name .. after .. "\n{\n\n}"
	end

	-- ── assemble output ───────────────────────────────────────────────────
	local defs = {}
	for _, entry in ipairs(results) do
		if is_func_decl(entry.text) then
			local def = decl_to_def(entry.text, entry.class_ctx)
			if def then
				table.insert(defs, def)
			end
		end
	end

	return defs
end

-- ═══════════════════════════════════════════════════════════════════════════
-- §2  :CppScaffold command
-- ═══════════════════════════════════════════════════════════════════════════

local function cpp_scaffold()
	local ext = vim.fn.expand("%:e")
	if ext ~= "h" and ext ~= "hpp" and ext ~= "hh" and ext ~= "hxx" then
		vim.notify("CppScaffold: must be called from a header file (.h/.hpp/.hh/.hxx)", vim.log.levels.ERROR)
		return
	end

	local header_path = vim.fn.expand("%:p")
	local header_name = vim.fn.expand("%:t")
	local cpp_path = header_path:gsub("%." .. ext .. "$", ".cpp")
	local header_bufnr = vim.api.nvim_get_current_buf()

	if vim.fn.filereadable(cpp_path) == 1 then
		vim.notify(
			"CppScaffold: .cpp already exists — opening " .. vim.fn.fnamemodify(cpp_path, ":t"),
			vim.log.levels.INFO
		)
		vim.cmd("edit " .. vim.fn.fnameescape(cpp_path))
		return
	end

	-- Build scaffold from current buffer text
	local defs = build_scaffold(header_bufnr)

	-- Compose file content
	local lines = { '#include "' .. header_name .. '"', "" }
	for _, def in ipairs(defs) do
		-- Each def is already "RetType Class::name(params)\n{\n\n}"
		-- Split on \n so we can table.insert line by line
		for _, dl in ipairs(vim.split(def, "\n")) do
			table.insert(lines, dl)
		end
		table.insert(lines, "") -- blank line between definitions
	end

	-- Write and open
	local fh = io.open(cpp_path, "w")
	if not fh then
		vim.notify("CppScaffold: cannot write " .. cpp_path, vim.log.levels.ERROR)
		return
	end
	fh:write(table.concat(lines, "\n"))
	fh:close()

	vim.cmd("edit " .. vim.fn.fnameescape(cpp_path))

	local count = #defs
	vim.notify(
		string.format(
			"CppScaffold: %s — %d definition%s scaffolded",
			vim.fn.fnamemodify(cpp_path, ":t"),
			count,
			count == 1 and "" or "s"
		),
		vim.log.levels.INFO
	)

	-- Offer clangd's "implement all" as a follow-up for anything the parser missed.
	if count == 0 then
		vim.notify(
			"CppScaffold: no declarations found — run <leader>cI once clangd attaches "
				.. "to let clangd scaffold from the header",
			vim.log.levels.WARN
		)
	end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- §3  Plugin specs
-- ═══════════════════════════════════════════════════════════════════════════

return {
	-- ── nvim-treesitter-refactor ─────────────────────────────────────────
	-- Adds: highlight-usages under cursor, within-file smart-rename,
	-- goto-next-usage / goto-prev-usage navigation.
	-- Complements clangd's cross-file LSP rename (<leader>rn).
	{
		"nvim-treesitter/nvim-treesitter-refactor",
		dependencies = { "neovim-treesitter/nvim-treesitter" },
		-- Lazy-load when a C/C++ buffer is opened; safe to widen the ft list
		-- if you want refactor features in other languages too.
		ft = { "c", "cpp" },
		config = function()
			-- Merge refactor config into treesitter; does not clobber
			-- the highlight / indent opts already set in treesitter.lua.
			require("nvim-treesitter").setup({
				refactor = {
					-- Highlight all occurrences of the symbol under the cursor.
					-- Cleared automatically when the cursor moves off the symbol.
					highlight_definitions = {
						enable = true,
						clear_on_cursor_move = true,
					},

					-- Scope highlight is visually noisy in large files; off by default.
					highlight_current_scope = { enable = false },

					-- Smart rename: renames all occurrences within the current file
					-- using treesitter (fast, no LSP round-trip, no waiting for indexer).
					-- For cross-file rename use <leader>rn (LSP).
					smart_rename = {
						enable = true,
						keymaps = { smart_rename = "<leader>tR" },
					},

					-- Navigation between usages of the symbol under the cursor.
					navigation = {
						enable = true,
						keymaps = {
							goto_definition = "g.", -- TS definition (fast fallback)
							goto_next_usage = "]u",
							goto_previous_usage = "[u",
						},
					},
				},
			})

			-- ── Register commands + keymaps (scoped to C/C++ via LspAttach) ──
			--
			-- Commands are global but only make sense in a header buffer.
			vim.api.nvim_create_user_command("CppScaffold", cpp_scaffold, {
				desc = "Generate .cpp with skeleton definitions from the current header",
			})

			vim.api.nvim_create_user_command("CppSwitch", function()
				vim.cmd("ClangdSwitchSourceHeader")
			end, {
				desc = "Switch between header and source (clangd)",
			})

			-- LspAttach autocmd scoped to C/C++ filetypes.
			-- These keymaps surface clangd's extra commands that aren't
			-- wired up in the generic lspconfig.lua LspAttach handler.
			vim.api.nvim_create_autocmd("LspAttach", {
				-- Match both old-style (*.cpp) and new-style filetype-based attach
				pattern = {
					"*.c",
					"*.h",
					"*.cpp",
					"*.cc",
					"*.cxx",
					"*.hpp",
					"*.hh",
					"*.hxx",
				},
				callback = function(ev)
					local client = vim.lsp.get_client_by_id(ev.data.client_id)
					if not client or client.name ~= "clangd" then
						return
					end

					local o = { buffer = ev.buf, silent = true }
					local k = vim.keymap.set

					-- ── clangd extras ──────────────────────────────────────
					-- Switch header ↔ source
					k(
						"n",
						"<leader>cH",
						"<cmd>ClangdSwitchSourceHeader<CR>",
						vim.tbl_extend("force", o, { desc = "C++: switch header/source" })
					)

					-- AST viewer (clangd_extensions)
					k("n", "<leader>cA", "<cmd>ClangdAST<CR>", vim.tbl_extend("force", o, { desc = "C++: AST view" }))

					-- Type hierarchy (clangd_extensions)
					k(
						"n",
						"<leader>cT",
						"<cmd>ClangdTypeHierarchy<CR>",
						vim.tbl_extend("force", o, { desc = "C++: type hierarchy" })
					)

					-- Symbol info panel (clangd_extensions)
					k(
						"n",
						"<leader>cS",
						"<cmd>ClangdSymbolInfo<CR>",
						vim.tbl_extend("force", o, { desc = "C++: symbol info" })
					)

					-- Memory usage (clangd pch/index overhead, useful for large projects)
					k(
						"n",
						"<leader>cM",
						"<cmd>ClangdMemoryUsage<CR>",
						vim.tbl_extend("force", o, { desc = "C++: clangd memory usage" })
					)

					-- ── Scaffold ───────────────────────────────────────────
					-- Generate .cpp from the current header (text-based, instant)
					k(
						"n",
						"<leader>cG",
						"<cmd>CppScaffold<CR>",
						vim.tbl_extend("force", o, { desc = "C++: scaffold .cpp from header" })
					)

					-- ── Refactoring via clangd code actions ────────────────
					-- "Implement all" — clangd scans the paired header and
					-- generates empty definitions for every unimplemented declaration.
					-- Most useful AFTER running :CppScaffold to catch anything
					-- the text parser missed (templates, complex macros, etc.).
					k("n", "<leader>cI", function()
						vim.lsp.buf.code_action({
							filter = function(action)
								local title = (action.title or ""):lower()
								return title:find("implement") ~= nil or (action.kind or ""):find("implement") ~= nil
							end,
							apply = true,
						})
					end, vim.tbl_extend("force", o, { desc = "C++: implement all (clangd)" }))

					-- "Sort #includes" code action
					k("n", "<leader>cO", function()
						vim.lsp.buf.code_action({
							filter = function(action)
								local title = (action.title or ""):lower()
								return title:find("sort") ~= nil and title:find("include") ~= nil
							end,
							apply = true,
						})
					end, vim.tbl_extend("force", o, { desc = "C++: sort #includes (clangd)" }))

					-- "Remove unused includes" code action
					k("n", "<leader>cU", function()
						vim.lsp.buf.code_action({
							filter = function(action)
								local title = (action.title or ""):lower()
								return title:find("remove") ~= nil and title:find("unused") ~= nil
							end,
							apply = true,
						})
					end, vim.tbl_extend("force", o, { desc = "C++: remove unused includes" }))

					-- ── Inlay hints toggle ─────────────────────────────────
					-- Inlay hints are enabled globally on LspAttach in lspconfig.lua.
					-- This binding lets you toggle them per-buffer when they clutter.
					k("n", "<leader>ch", function()
						vim.lsp.inlay_hint.enable(
							not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }),
							{ bufnr = ev.buf }
						)
					end, vim.tbl_extend("force", o, { desc = "C++: toggle inlay hints" }))
				end,
			})
		end,
	},
}
