-- lua/snippets/cpp.lua
-- LuaSnip snippet definitions for C and C++ files.
-- Auto-loaded by snippets.lua via luasnip.loaders.from_lua.
-- The _skel snippets fire automatically on BufNewFile via autocmds.lua.
-- All other snippets are manually triggered through blink.cmp or <Tab>.
--
-- DO NOT put autocmds, keymaps, or vim.api calls here — this file is
-- evaluated by the LuaSnip loader outside the normal plugin init order.

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local sn = ls.snippet_node

-- ── helpers ──────────────────────────────────────────────────────────────────

-- Derive a SCREAMING_SNAKE_CASE macro from the current filename at expand time.
-- Called inside f() so it runs when the snippet expands, not when the file loads.
local function guard_macro()
	return vim.fn.expand("%:t"):upper():gsub("[^A-Z0-9]", "_")
end

-- Mirror the text of an insert node (used for class-name repetition).
local function mirror(args)
	return args[1][1]
end

-- ── C++ snippets ──────────────────────────────────────────────────────────────
-- Applies to: .cpp .cc .cxx .hpp .hh .hxx  (filetype = cpp)

local cpp_snippets = {

	-- ── _skel ─────────────────────────────────────────────────────────────
	-- Fires automatically on BufNewFile for .hpp/.hh/.hxx via autocmds.lua.
	-- Also manually triggerable in any cpp buffer.
	-- Uses #pragma once — aligns with clangd's --fallback-style=llvm.
	s({ trig = "_skel", name = "_skel" }, {
		t({ "#pragma once", "", "" }),
		i(0),
	}),

	-- ── hguard ────────────────────────────────────────────────────────────
	-- Traditional include guard — use when you need C compatibility or when
	-- working in a codebase that bans #pragma once.
	s({ trig = "hguard", name = "traditional include guard" }, {
		t("#ifndef "),
		f(guard_macro),
		t({ "", "#define " }),
		f(guard_macro),
		t({ "", "", "" }),
		i(0),
		t({ "", "", "#endif  // " }),
		f(guard_macro),
	}),

	-- ── ns ────────────────────────────────────────────────────────────────
	s({ trig = "ns", name = "namespace block" }, {
		t("namespace "),
		i(1, "name"),
		t({ " {", "", "" }),
		i(0),
		t({ "", "", "}  // namespace " }),
		f(mirror, { 1 }),
	}),

	-- ── tpl ───────────────────────────────────────────────────────────────
	s({ trig = "tpl", name = "template prefix" }, {
		t("template <"),
		i(1, "typename T"),
		t(">"),
	}),

	-- ── cls ───────────────────────────────────────────────────────────────
	-- Full class skeleton: ctor/dtor, deleted copy+assign, private section.
	s({ trig = "cls", name = "class skeleton" }, {
		t("class "),
		i(1, "ClassName"),
		t({ " {", "public:", "    " }),
		f(mirror, { 1 }),
		t("();"),
		t({ "", "    ~" }),
		f(mirror, { 1 }),
		t("();"),
		t({ "", "", "    " }),
		f(mirror, { 1 }),
		t("(const "),
		f(mirror, { 1 }),
		t("&) = delete;"),
		t({ "", "    " }),
		f(mirror, { 1 }),
		t("& operator=(const "),
		f(mirror, { 1 }),
		t("&) = delete;"),
		t({ "", "", "private:", "    " }),
		i(2),
		t({ "", "};  // class " }),
		f(mirror, { 1 }),
	}),

	-- ── strc ──────────────────────────────────────────────────────────────
	-- Plain struct — all members public, no deleted copy (structs are usually
	-- value types that you WANT to copy).
	s({ trig = "strc", name = "struct skeleton" }, {
		t("struct "),
		i(1, "Name"),
		t({ " {", "    " }),
		i(2),
		t({ "", "};  // struct " }),
		f(mirror, { 1 }),
	}),

	-- ── ctor ──────────────────────────────────────────────────────────────
	-- Constructor + destructor pair (for inside an existing class body).
	s({ trig = "ctor", name = "constructor / destructor pair" }, {
		i(1, "ClassName"),
		t("("),
		i(2),
		t(");"),
		t({ "", "~" }),
		f(mirror, { 1 }),
		t("();"),
	}),

	-- ── fn ────────────────────────────────────────────────────────────────
	-- Free function declaration.
	s({ trig = "fn", name = "free function declaration" }, {
		i(1, "void"),
		t(" "),
		i(2, "name"),
		t("("),
		i(3),
		t(");"),
	}),

	-- ── mfn ───────────────────────────────────────────────────────────────
	-- Member function declaration, choice nodes for leading/trailing specifiers.
	s({ trig = "mfn", name = "member function declaration" }, {
		c(1, {
			t(""),
			t("virtual "),
			t("static "),
			t("[[nodiscard]] "),
		}),
		i(2, "void"),
		t(" "),
		i(3, "name"),
		t("("),
		i(4),
		t(")"),
		c(5, {
			t(";"),
			t(" const;"),
			t(" noexcept;"),
			t(" const noexcept;"),
			t(" override;"),
			t(" const override;"),
			t(" = 0;"),
		}),
	}),

	-- ── ovrd ──────────────────────────────────────────────────────────────
	-- Quick override declaration.
	s({ trig = "ovrd", name = "override method" }, {
		i(1, "void"),
		t(" "),
		i(2, "name"),
		t("("),
		i(3),
		t(")"),
		c(4, { t(" override;"), t(" const override;") }),
	}),

	-- ── main ──────────────────────────────────────────────────────────────
	s({ trig = "main", name = "main() entry point" }, {
		t({ "int main(int argc, char* argv[]) {", "    " }),
		i(0),
		t({ "", "    return 0;", "}" }),
	}),

	-- ── ifnd ──────────────────────────────────────────────────────────────
	-- Quick #if / #endif block for conditional compilation.
	s({ trig = "ifnd", name = "#ifndef block" }, {
		t("#ifndef "),
		i(1, "CONDITION"),
		t({ "", "" }),
		i(2),
		t({ "", "#endif  // " }),
		f(function(args)
			return args[1][1]
		end, { 1 }),
	}),
}

-- ── C snippets ────────────────────────────────────────────────────────────────
-- Applies to: .c .h  (filetype = c)
-- .h new-file defaults to filetype=c (see ftdetect/filetype.lua heuristic).

local c_snippets = {

	-- ── _skel ─────────────────────────────────────────────────────────────
	-- Traditional include guard — C doesn't have #pragma once as a standard,
	-- and many C codebases explicitly forbid it.
	s({ trig = "_skel", name = "_skel" }, {
		t("#ifndef "),
		f(guard_macro),
		t({ "", "#define " }),
		f(guard_macro),
		t({ "", "", "" }),
		i(0),
		t({ "", "", "#endif  /* " }),
		f(guard_macro),
		t(" */"),
	}),

	-- ── fn ────────────────────────────────────────────────────────────────
	s({ trig = "fn", name = "function declaration" }, {
		i(1, "void"),
		t(" "),
		i(2, "name"),
		t("("),
		i(3),
		t(");"),
	}),

	-- ── main ──────────────────────────────────────────────────────────────
	s({ trig = "main", name = "main() entry point" }, {
		t({ "int main(int argc, char *argv[]) {", "    " }),
		i(0),
		t({ "", "    return 0;", "}" }),
	}),

	-- ── hguard ────────────────────────────────────────────────────────────
	s({ trig = "hguard", name = "include guard (alias for _skel)" }, {
		t("#ifndef "),
		f(guard_macro),
		t({ "", "#define " }),
		f(guard_macro),
		t({ "", "", "" }),
		i(0),
		t({ "", "", "#endif  /* " }),
		f(guard_macro),
		t(" */"),
	}),

	-- ── strc ──────────────────────────────────────────────────────────────
	s({ trig = "strc", name = "struct" }, {
		t("typedef struct "),
		i(1, "Name"),
		t({ " {", "    " }),
		i(2),
		t({ "", "} " }),
		f(mirror, { 1 }),
		t(";"),
	}),
}

-- ── register ─────────────────────────────────────────────────────────────────

return {
	ls.add_snippets("cpp", cpp_snippets),
	ls.add_snippets("c", c_snippets),
}
