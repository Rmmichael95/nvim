-- lua/config/plugins/cpp_tools.lua
--
-- C/C++ tooling:
--   • CppScaffold  — generate .cpp skeleton from current header (text-based, instant)
--   • CppSwitch    — toggle header ↔ source via clangd
--   • LSP document-highlight — replaces archived nvim-treesitter/nvim-treesitter-refactor
--     · CursorHold        → vim.lsp.buf.document_highlight()  (all usages lit up)
--     · CursorMoved / I   → vim.lsp.buf.clear_references()
--     · ]u / [u           → jump next / prev highlighted reference (wraps)
--     · g.                → LSP go-to-definition  (was TS refactor goto_definition)
--     · <leader>rn        → vim.lsp.buf.rename()  (clangd: cross-file; TS was file-only)
--
-- REMOVED: "nvim-treesitter/nvim-treesitter-refactor" — archived Nov 2025, no new fixes.
--          All three features it provided (highlight_definitions, smart_rename, navigation)
--          are now driven by clangd's textDocument/documentHighlight capability, which is
--          semantically richer (understands templates, macros, cross-TU includes) and needs
--          no extra plugin.

-- ═══════════════════════════════════════════════════════════════════════════
-- §1  Scaffold helpers  (UNCHANGED — keep your existing functions here)
-- ═══════════════════════════════════════════════════════════════════════════

-- [[ PASTE YOUR EXISTING §1 build_scaffold / cpp_scaffold FUNCTIONS HERE ]]
-- Nothing in §1 or §2 changes; only §3 (Plugin specs) is replaced below.

-- ═══════════════════════════════════════════════════════════════════════════
-- §2  LSP reference navigation
-- ═══════════════════════════════════════════════════════════════════════════

---Jump to the next or previous LSP reference highlight in the current buffer.
---Uses the extmark namespace that vim.lsp.buf.document_highlight() populates
---("vim_lsp_references"), so it works with zero extra plugins.
---Wraps around at buffer boundaries.
---@param dir "next"|"prev"
local function goto_reference(dir)
	-- Re-trigger highlight so the namespace is fresh if the cursor just moved.
	-- clangd responds fast enough that vim.schedule() below catches it.
	vim.lsp.buf.document_highlight()

	vim.schedule(function()
		local ns = vim.api.nvim_get_namespaces()["vim_lsp_references"]
		if not ns then
			return
		end

		-- extmark list: { {id, row, col}, ... } in buffer order
		local marks = vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, {})
		if #marks == 0 then
			return
		end

		local cursor = vim.api.nvim_win_get_cursor(0)
		local row = cursor[1] - 1 -- 0-indexed to match extmark coords
		local col = cursor[2]

		local target
		if dir == "next" then
			for _, m in ipairs(marks) do
				if m[2] > row or (m[2] == row and m[3] > col) then
					target = m
					break
				end
			end
			target = target or marks[1] -- wrap to buffer start
		else
			for i = #marks, 1, -1 do
				local m = marks[i]
				if m[2] < row or (m[2] == row and m[3] < col) then
					target = m
					break
				end
			end
			target = target or marks[#marks] -- wrap to buffer end
		end

		if target then
			-- target[2] is 0-indexed row; nvim_win_set_cursor expects 1-indexed
			vim.api.nvim_win_set_cursor(0, { target[2] + 1, target[3] })
		end
	end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- §3  Plugin specs
-- ═══════════════════════════════════════════════════════════════════════════

return {
	{
		-- Config-only stub: `dir` points to your existing config directory
		-- (always present, nothing installed).  lazy.nvim triggers `config`
		-- when a C/C++ file is opened, exactly like the old ft-scoped refactor spec.
		dir = vim.fn.stdpath("config"),
		name = "cpp-lsp-extras",
		ft = { "c", "cpp" },

		config = function()
			-- ── User commands ──────────────────────────────────────────────────
			vim.api.nvim_create_user_command("CppScaffold", cpp_scaffold, {
				desc = "Generate .cpp with skeleton definitions from the current header",
			})

			vim.api.nvim_create_user_command("CppSwitch", function()
				vim.cmd("ClangdSwitchSourceHeader")
			end, {
				desc = "Switch between header and source (clangd)",
			})

			-- ── LspAttach: clangd keymaps + document-highlight ─────────────────
			vim.api.nvim_create_autocmd("LspAttach", {
				-- Match every C/C++ filename pattern clangd recognises.
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

					-- ── clangd extras ──────────────────────────────────────────
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

					-- ── Scaffold ───────────────────────────────────────────────
					-- Generate .cpp from current header (text-based, instant)
					k(
						"n",
						"<leader>cG",
						"<cmd>CppScaffold<CR>",
						vim.tbl_extend("force", o, { desc = "C++: scaffold .cpp from header" })
					)

					-- ── Refactoring via clangd code actions ────────────────────
					-- "Implement all" — clangd scans the paired header and generates
					-- empty definitions for every unimplemented declaration.
					-- Run AFTER :CppScaffold for anything the text parser missed
					-- (templates, complex macros, etc.).
					k("n", "<leader>cI", function()
						vim.lsp.buf.code_action({
							filter = function(a)
								return a.isPreferred
							end,
							apply = true,
						})
					end, vim.tbl_extend("force", o, { desc = "C++: implement all (clangd)" }))

					-- ── LSP document-highlight ─────────────────────────────────
					-- Replaces nvim-treesitter-refactor's highlight_definitions.
					-- clangd's textDocument/documentHighlight is semantically richer:
					-- it understands templates, macros, and cross-TU include chains
					-- in ways that tree-sitter's AST walk cannot.
					if client:supports_method("textDocument/documentHighlight") then
						local hl_aug = vim.api.nvim_create_augroup("cpp_lsp_highlight_" .. ev.buf, { clear = true })

						-- Light up every reference to the symbol under the cursor.
						vim.api.nvim_create_autocmd("CursorHold", {
							buffer = ev.buf,
							group = hl_aug,
							callback = vim.lsp.buf.document_highlight,
						})

						-- Clear highlights the moment the cursor moves or insert starts.
						vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter" }, {
							buffer = ev.buf,
							group = hl_aug,
							callback = vim.lsp.buf.clear_references,
						})

						-- ]u / [u — jump between references (replaces TS goto_next/prev_usage)
						k("n", "]u", function()
							goto_reference("next")
						end, vim.tbl_extend("force", o, { desc = "C++: next reference" }))

						k("n", "[u", function()
							goto_reference("prev")
						end, vim.tbl_extend("force", o, { desc = "C++: prev reference" }))

						-- g. — LSP go-to-definition (replaces TS refactor goto_definition)
						-- Keeps the same mnemonic; now goes through clangd so it works
						-- across translation units, not just the current file.
						k(
							"n",
							"g.",
							vim.lsp.buf.definition,
							vim.tbl_extend("force", o, { desc = "C++: go to definition (LSP)" })
						)

						-- <leader>tR — LSP rename (replaces TS smart_rename)
						-- TS smart_rename was file-scoped; clangd rename is cross-file.
						-- <leader>rn from your generic lsp keymap does the same thing;
						-- keep <leader>tR as a muscle-memory alias if you prefer.
						k(
							"n",
							"<leader>tR",
							vim.lsp.buf.rename,
							vim.tbl_extend("force", o, { desc = "C++: rename symbol (LSP)" })
						)
					end
				end,
			})
		end,
	},
}
