-- lua/snippets/cpp.lua
-- LuaSnip snippet definitions for C and C++ files.
-- Auto-loaded by snippets.lua via luasnip.loaders.from_lua.
-- The _skel snippets fire automatically on BufNewFile via autocmds.lua.
-- All other snippets are triggered through blink.cmp or <Tab>.
--
-- Style: LLVM (--fallback-style=llvm via clangd)
--   • Same-line opening braces    void foo() {
--   • 4-space indentation
--   • clangd + CppScaffold handle .cpp generation from headers
--   • clangd implement-all (<leader>cI) handles interface boilerplate
--   • --header-insertion=iwyu manages #includes — don't duplicate
--
-- C++20 features (concept, std::format, ranges) are included because
-- your Clang/LLVM toolchain supports them fully.

local ls = require("luasnip")
local s, t, i, f, c = ls.snippet, ls.text_node, ls.insert_node, ls.function_node, ls.choice_node

-- ── helpers ──────────────────────────────────────────────────────────────────

-- Derives SCREAMING_SNAKE_CASE macro from the current filename at expand time.
-- Wrapped in f() so it runs at snippet expansion, not at file load.
local function guard_macro()
	return vim.fn.expand("%:t"):upper():gsub("[^A-Z0-9]", "_")
end

-- Mirrors the text of an insert node.
local function mirror(args)
	return args[1][1]
end

-- Lowercases the first letter of an insert node (for snake_case from PascalCase).
local function lower_first(args)
	local name = args[1][1]
	if name == "" then
		return ""
	end
	return name:sub(1, 1):lower() .. name:sub(2)
end

-- ── C++ snippets ──────────────────────────────────────────────────────────────

local cpp_snippets = {

	-- ══════════════════════════════════════════════════════════════════════════
	-- FILE SKELETONS
	-- ══════════════════════════════════════════════════════════════════════════

	-- _skel: #pragma once — fires on BufNewFile for .hpp/.hh/.hxx.
	-- Aligns with clangd's --fallback-style=llvm.
	s({ trig = "_skel", name = "#pragma once header skeleton" }, {
		t({ "#pragma once", "", "" }),
		i(0),
	}),

	-- hguard: traditional include guard — use when #pragma once is banned.
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

	-- ══════════════════════════════════════════════════════════════════════════
	-- PREPROCESSOR
	-- ══════════════════════════════════════════════════════════════════════════

	-- inc: #include with system vs local choice.
	s({ trig = "inc", name = "#include" }, {
		t("#include "),
		c(1, {
			s("", { t("<"), i(1, "header"), t(">") }),
			s("", { t('"'), i(1, "header.h"), t('"') }),
		}),
	}),

	-- def: #define macro — value or function-like.
	s({ trig = "def", name = "#define macro" }, {
		t("#define "),
		i(1, "MACRO_NAME"),
		t(" "),
		i(0, "value"),
	}),

	-- ifdef: conditional compilation block.
	s({ trig = "ifdef", name = "#ifdef / #endif block" }, {
		t("#ifdef "),
		i(1, "CONDITION"),
		t({ "", "" }),
		i(0),
		t({ "", "#endif  // " }),
		f(mirror, { 1 }),
	}),

	-- ifnd: #ifndef guard block — for conditional feature inclusion.
	s({ trig = "ifnd", name = "#ifndef block" }, {
		t("#ifndef "),
		i(1, "CONDITION"),
		t({ "", "" }),
		i(0),
		t({ "", "#endif  // " }),
		f(mirror, { 1 }),
	}),

	-- attr: C++ attributes — placed before declarations.
	s({ trig = "attr", name = "C++ attribute" }, {
		c(1, {
			t("[[nodiscard]]"),
			s("", { t('[[deprecated("'), i(1, "use X instead"), t('")]]') }),
			t("[[maybe_unused]]"),
			t("[[noreturn]]"),
			t("[[likely]]"),
			t("[[unlikely]]"),
			t("[[nodiscard, maybe_unused]]"),
		}),
		t(" "),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- NAMESPACES
	-- ══════════════════════════════════════════════════════════════════════════

	-- ns: named namespace with trailing comment.
	s({ trig = "ns", name = "namespace block" }, {
		t("namespace "),
		i(1, "name"),
		t({ " {", "", "" }),
		i(0),
		t({ "", "", "}  // namespace " }),
		f(mirror, { 1 }),
	}),

	-- nsanon: anonymous namespace — preferred over `static` in .cpp files.
	s({ trig = "nsanon", name = "anonymous namespace (.cpp)" }, {
		t({ "namespace {", "", "" }),
		i(0),
		t({ "", "", "}  // namespace" }),
	}),

	-- nsinl: inline namespace — for library versioning (ABI-transparent).
	s({ trig = "nsinl", name = "inline namespace (versioning)" }, {
		t("inline namespace "),
		i(1, "v1"),
		t({ " {", "", "" }),
		i(0),
		t({ "", "", "}  // namespace " }),
		f(mirror, { 1 }),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- TEMPLATES
	-- ══════════════════════════════════════════════════════════════════════════

	-- tpl: template prefix — prepend to a class or function declaration.
	s({ trig = "tpl", name = "template prefix" }, {
		t("template <"),
		i(1, "typename T"),
		t(">"),
	}),

	-- tplf: full template function definition.
	s({ trig = "tplf", name = "template function definition" }, {
		t("template <"),
		i(1, "typename T"),
		t(">"),
		t({ "", "" }),
		i(2, "auto"),
		t(" "),
		i(3, "name"),
		t("("),
		i(4, "T value"),
		t(") {"),
		t({ "", "    " }),
		i(0),
		t({ "", "}" }),
	}),

	-- tplc: template class skeleton.
	s({ trig = "tplc", name = "template class" }, {
		t("template <"),
		i(1, "typename T"),
		t(">"),
		t({ "", "class " }),
		i(2, "ClassName"),
		t(" {"),
		t({ "", "public:", "    explicit " }),
		f(mirror, { 2 }),
		t("("),
		i(3),
		t(");"),
		t({ "", "    ~" }),
		f(mirror, { 2 }),
		t("() = default;"),
		t({ "", "", "private:", "    " }),
		i(0),
		t({ "", "};  // class " }),
		f(mirror, { 2 }),
	}),

	-- concept: C++20 concept definition.
	s({ trig = "concept", name = "C++20 concept" }, {
		t("template <typename "),
		i(1, "T"),
		t(">"),
		t({ "", "concept " }),
		i(2, "ConceptName"),
		t(" = "),
		c(3, {
			-- simple type-trait expression
			s("", { t("std::"), i(1, "is_integral_v<"), f(mirror, { 1 }), t(">") }),
			-- requires clause
			s("", {
				t({ "requires(", "    " }),
				f(mirror, { 1 }),
				t(" "),
				i(1, "t"),
				t({ ") {", "    { " }),
				i(2, "t + t"),
				t(" } -> std::convertible_to<"),
				f(mirror, { 1 }),
				t(">;"),
				t({ "", "}" }),
			}),
		}),
		t(";"),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- TYPES
	-- ══════════════════════════════════════════════════════════════════════════

	-- cls: Rule-of-Zero class — ctor/dtor + deleted copy + deleted move.
	-- Use when the class manages a resource that must not be shared.
	-- CppScaffold (<leader>cG) generates the paired .cpp.
	s({ trig = "cls", name = "class (Rule of Zero — deleted copy/move)" }, {
		t("class "),
		i(1, "ClassName"),
		t(" {"),
		t({ "", "public:", "    explicit " }),
		f(mirror, { 1 }),
		t("("),
		i(2),
		t(");"),
		t({ "", "    ~" }),
		f(mirror, { 1 }),
		t("();"),
		t({ "", "", "    " }),
		f(mirror, { 1 }),
		t("(const "),
		f(mirror, { 1 }),
		t("&)            = delete;"),
		t({ "", "    " }),
		f(mirror, { 1 }),
		t("& operator=(const "),
		f(mirror, { 1 }),
		t("&) = delete;"),
		t({ "", "    " }),
		f(mirror, { 1 }),
		t("("),
		f(mirror, { 1 }),
		t("&&)                 = delete;"),
		t({ "", "    " }),
		f(mirror, { 1 }),
		t("& operator=("),
		f(mirror, { 1 }),
		t("&&)      = delete;"),
		t({ "", "", "private:", "    " }),
		i(0),
		t({ "", "};  // class " }),
		f(mirror, { 1 }),
	}),

	-- cls5: Rule-of-Five class — explicit move semantics.
	-- Use when the class manages a unique resource but moves are cheap/valid.
	s({ trig = "cls5", name = "class (Rule of Five — explicit move)" }, {
		t("class "),
		i(1, "ClassName"),
		t(" {"),
		t({ "", "public:", "    explicit " }),
		f(mirror, { 1 }),
		t("("),
		i(2),
		t(");"),
		t({ "", "    ~" }),
		f(mirror, { 1 }),
		t("();"),
		t({ "", "" }),
		t({ "", "    " }),
		f(mirror, { 1 }),
		t("(const "),
		f(mirror, { 1 }),
		t("&)            = delete;"),
		t({ "", "    " }),
		f(mirror, { 1 }),
		t("& operator=(const "),
		f(mirror, { 1 }),
		t("&) = delete;"),
		t({ "", "" }),
		t({ "", "    " }),
		f(mirror, { 1 }),
		t("("),
		f(mirror, { 1 }),
		t("&&) noexcept;"),
		t({ "", "    " }),
		f(mirror, { 1 }),
		t("& operator=("),
		f(mirror, { 1 }),
		t("&&) noexcept;"),
		t({ "", "", "private:", "    " }),
		i(0),
		t({ "", "};  // class " }),
		f(mirror, { 1 }),
	}),

	-- clsabs: pure abstract base class (interface pattern).
	-- clangd's implement-all (<leader>cI) fills in derived class bodies.
	s({ trig = "clsabs", name = "abstract base class (interface)" }, {
		t("class "),
		i(1, "IName"),
		t(" {"),
		t({ "", "public:", "    virtual ~" }),
		f(mirror, { 1 }),
		t("() = default;"),
		t({ "", "", "    virtual " }),
		i(2, "void"),
		t(" "),
		i(3, "method"),
		t("("),
		i(4),
		t(") = 0;"),
		t({ "", "", "    " }),
		f(mirror, { 1 }),
		t("(const "),
		f(mirror, { 1 }),
		t("&)            = delete;"),
		t({ "", "    " }),
		f(mirror, { 1 }),
		t("& operator=(const "),
		f(mirror, { 1 }),
		t("&) = delete;"),
		t({ "", "};  // class " }),
		f(mirror, { 1 }),
	}),

	-- strc: struct — value type, compiler-managed copy/move.
	s({ trig = "strc", name = "struct (value type)" }, {
		t("struct "),
		i(1, "Name"),
		t(" {"),
		t({ "", "    " }),
		i(0),
		t({ "", "};  // struct " }),
		f(mirror, { 1 }),
	}),

	-- enum: scoped enum class with optional underlying type.
	s({ trig = "enum", name = "enum class (scoped)" }, {
		t("enum class "),
		i(1, "Name"),
		c(2, {
			t(""),
			s("", {
				t(" : "),
				c(1, { t("uint8_t"), t("uint16_t"), t("uint32_t"), t("int"), t("uint64_t") }),
			}),
		}),
		t({ " {", "    " }),
		i(3, "Value1,"),
		t({ "", "    " }),
		i(0, "Value2,"),
		t({ "", "};" }),
	}),

	-- alias: type alias — prefer over typedef in C++.
	s({ trig = "alias", name = "using type alias" }, {
		t("using "),
		i(1, "Name"),
		t(" = "),
		i(2, "Type"),
		t(";"),
	}),

	-- aliastpl: alias template.
	s({ trig = "aliastpl", name = "alias template" }, {
		t("template <"),
		i(1, "typename T"),
		t(">"),
		t({ "", "using " }),
		i(2, "Name"),
		t(" = "),
		i(3, "std::vector"),
		t("<"),
		f(mirror, { 1 }),
		t(">;"),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- FUNCTIONS
	-- ══════════════════════════════════════════════════════════════════════════

	-- fn: free function declaration (header / forward decl).
	s({ trig = "fn", name = "free function declaration" }, {
		i(1, "void"),
		t(" "),
		i(2, "name"),
		t("("),
		i(3),
		t(");"),
	}),

	-- fnd: free function definition (LLVM style, same-line brace).
	s({ trig = "fnd", name = "free function definition" }, {
		i(1, "void"),
		t(" "),
		i(2, "name"),
		t("("),
		i(3),
		t(") {"),
		t({ "", "    " }),
		i(0),
		t({ "", "}" }),
	}),

	-- mfn: member function declaration with leading/trailing specifier choice nodes.
	s({ trig = "mfn", name = "member function declaration" }, {
		c(1, {
			t(""),
			t("[[nodiscard]] "),
			t("virtual "),
			t("static "),
			t("explicit "),
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
			t(" noexcept override;"),
			t(" const noexcept override;"),
			t(" = 0;"),
			t(" = default;"),
			t(" = delete;"),
		}),
	}),

	-- ovrd: quick override declaration.
	s({ trig = "ovrd", name = "override method" }, {
		i(1, "void"),
		t(" "),
		i(2, "name"),
		t("("),
		i(3),
		t(")"),
		c(4, { t(" override;"), t(" const override;"), t(" noexcept override;") }),
	}),

	-- ctor: constructor + destructor pair for inside an existing class body.
	s({ trig = "ctor", name = "constructor / destructor pair" }, {
		t("explicit "),
		i(1, "ClassName"),
		t("("),
		i(2),
		t(");"),
		t({ "", "~" }),
		f(mirror, { 1 }),
		t("();"),
	}),

	-- main: main() entry point.
	s({ trig = "main", name = "main() entry point" }, {
		t({ "int main(int argc, char* argv[]) {", "    " }),
		i(0),
		t({ "", "    return 0;", "}" }),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- LAMBDAS
	-- ══════════════════════════════════════════════════════════════════════════

	-- lmb: lambda with capture list and parameters.
	s({ trig = "lmb", name = "lambda expression" }, {
		t("["),
		c(1, { t(""), t("&"), t("="), t("&, this"), t("=, this") }),
		t("]("),
		i(2),
		t(") {"),
		t({ "", "    " }),
		i(0),
		t({ "", "}" }),
	}),

	-- lmba: lambda with explicit return type.
	s({ trig = "lmba", name = "lambda with explicit return type" }, {
		t("["),
		c(1, { t(""), t("&"), t("=") }),
		t("]("),
		i(2),
		t(") -> "),
		i(3, "auto"),
		t(" {"),
		t({ "", "    " }),
		i(0),
		t({ "", "}" }),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- CONTROL FLOW
	-- ══════════════════════════════════════════════════════════════════════════

	-- rng: range-based for loop — idiomatic C++11+.
	s({ trig = "rng", name = "range-based for loop" }, {
		t("for ("),
		c(1, { t("auto&"), t("const auto&"), t("auto&&"), t("auto") }),
		t(" "),
		i(2, "elem"),
		t(" : "),
		i(3, "container"),
		t(") {"),
		t({ "", "    " }),
		i(0),
		t({ "", "}" }),
	}),

	-- try: try / catch — catches std::exception by default.
	s({ trig = "try", name = "try / catch (std::exception)" }, {
		t({ "try {", "    " }),
		i(1),
		t({ "", "} catch (const " }),
		c(2, {
			t("std::exception"),
			t("std::runtime_error"),
			t("std::invalid_argument"),
			t("std::out_of_range"),
		}),
		t("& e) {"),
		t({ "", "    " }),
		i(0, "// handle or rethrow"),
		t({ "", "}" }),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- SMART POINTERS
	-- ══════════════════════════════════════════════════════════════════════════

	-- mkup: std::make_unique — preferred over `new` for unique ownership.
	s({ trig = "mkup", name = "std::make_unique" }, {
		t("auto "),
		i(1, "ptr"),
		t(" = std::make_unique<"),
		i(2, "Type"),
		t(">("),
		i(3),
		t(");"),
	}),

	-- mksp: std::make_shared — shared ownership.
	s({ trig = "mksp", name = "std::make_shared" }, {
		t("auto "),
		i(1, "ptr"),
		t(" = std::make_shared<"),
		i(2, "Type"),
		t(">("),
		i(3),
		t(");"),
	}),

	-- wkptr: std::weak_ptr from a shared_ptr — break circular ownership.
	s({ trig = "wkptr", name = "std::weak_ptr from shared_ptr" }, {
		t("std::weak_ptr<"),
		i(1, "Type"),
		t("> "),
		i(2, "weak"),
		t(" = "),
		i(3, "shared"),
		t(";"),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- CASTS
	-- ══════════════════════════════════════════════════════════════════════════

	-- cast: C++ named cast — choice node for all four kinds.
	-- Prefer in this order: static > dynamic > const > reinterpret.
	s({ trig = "cast", name = "C++ named cast" }, {
		c(1, {
			t("static_cast"),
			t("dynamic_cast"),
			t("const_cast"),
			t("reinterpret_cast"),
		}),
		t("<"),
		i(2, "Type"),
		t(">("),
		i(3, "expr"),
		t(")"),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- C++20 UTILITIES
	-- ══════════════════════════════════════════════════════════════════════════

	-- fmt: std::format — type-safe string formatting (C++20).
	-- Requires: #include <format>  (clangd + iwyu will add it automatically).
	s({ trig = "fmt", name = "std::format (C++20)" }, {
		t('std::format("'),
		i(1, "{}"),
		t('", '),
		i(2, "value"),
		t(")"),
	}),

	-- fmtprt: std::print to stdout (C++23).
	s({ trig = "fmtprt", name = "std::print (C++23)" }, {
		t('std::print("'),
		i(1, "{}\\n"),
		t('", '),
		i(2, "value"),
		t(");"),
	}),

	-- sa: static_assert — compile-time assertion.
	s({ trig = "sa", name = "static_assert" }, {
		t("static_assert("),
		i(1, "condition"),
		c(2, {
			t(")"),
			s("", { t(', "'), i(1, "message"), t('")') }),
		}),
		t(";"),
	}),

	-- expect: [[nodiscard]] + expected return pattern (std::expected C++23).
	s({ trig = "expect", name = "std::expected return type (C++23)" }, {
		t("std::expected<"),
		i(1, "T"),
		t(", "),
		i(2, "std::string"),
		t("> "),
		i(3, "name"),
		t("("),
		i(4),
		t(") {"),
		t({ "", "    " }),
		i(0),
		t({ "", "}" }),
	}),
}

-- ── C snippets ────────────────────────────────────────────────────────────────
-- Applies to: .c .h  (filetype = c)
-- .h defaults to filetype=c per ftdetect/filetype.lua heuristic.

local c_snippets = {

	-- ══════════════════════════════════════════════════════════════════════════
	-- FILE SKELETONS
	-- ══════════════════════════════════════════════════════════════════════════

	-- _skel: traditional include guard (C89/C99 compatible — no #pragma once).
	s({ trig = "_skel", name = "C include guard + ABSPATH guard" }, {
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

	-- hguard: same as _skel, manually triggerable alias.
	s({ trig = "hguard", name = "C include guard" }, {
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

	-- ══════════════════════════════════════════════════════════════════════════
	-- PREPROCESSOR
	-- ══════════════════════════════════════════════════════════════════════════

	-- inc: #include with system vs local choice.
	s({ trig = "inc", name = "#include" }, {
		t("#include "),
		c(1, {
			s("", { t("<"), i(1, "stdio.h"), t(">") }),
			s("", { t('"'), i(1, "header.h"), t('"') }),
		}),
	}),

	-- def: #define macro.
	s({ trig = "def", name = "#define macro" }, {
		t("#define "),
		i(1, "MACRO"),
		t(" "),
		i(0, "value"),
	}),

	-- ifdef: #ifdef / #endif conditional block.
	s({ trig = "ifdef", name = "#ifdef / #endif" }, {
		t("#ifdef "),
		i(1, "CONDITION"),
		t({ "", "" }),
		i(0),
		t({ "", "#endif  /* " }),
		f(mirror, { 1 }),
		t(" */"),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- TYPES
	-- ══════════════════════════════════════════════════════════════════════════

	-- strc: typedef struct — idiomatic C pattern.
	s({ trig = "strc", name = "typedef struct" }, {
		t("typedef struct "),
		i(1, "Name"),
		t("_ {"),
		t({ "", "    " }),
		i(0),
		t({ "", "} " }),
		f(mirror, { 1 }),
		t(";"),
	}),

	-- enum: C enum (unscoped, values leak into enclosing scope).
	s({ trig = "enum", name = "typedef enum" }, {
		t("typedef enum {"),
		t({ "", "    " }),
		i(1, "VALUE_A,"),
		t({ "", "    " }),
		i(2, "VALUE_B,"),
		t({ "", "} " }),
		i(3, "EnumName"),
		t(";"),
	}),

	-- cb: callback / function pointer typedef.
	s({ trig = "cb", name = "function pointer typedef (callback)" }, {
		t("typedef "),
		i(1, "void"),
		t(" (*"),
		i(2, "CallbackName"),
		t(")("),
		i(3, "void* ctx"),
		t(");"),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- FUNCTIONS
	-- ══════════════════════════════════════════════════════════════════════════

	-- fn: function declaration.
	s({ trig = "fn", name = "function declaration" }, {
		i(1, "void"),
		t(" "),
		i(2, "name"),
		t("("),
		i(3),
		t(");"),
	}),

	-- fnd: function definition (LLVM style).
	s({ trig = "fnd", name = "function definition" }, {
		i(1, "void"),
		t(" "),
		i(2, "name"),
		t("("),
		i(3),
		t(") {"),
		t({ "", "    " }),
		i(0),
		t({ "", "}" }),
	}),

	-- main: main() entry point.
	s({ trig = "main", name = "main() entry point" }, {
		t({ "int main(int argc, char *argv[]) {", "    " }),
		i(0),
		t({ "", "    return 0;", "}" }),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- CONTROL FLOW
	-- ══════════════════════════════════════════════════════════════════════════

	-- forloop: classic index-based for loop.
	s({ trig = "forloop", name = "for loop (index)" }, {
		t("for ("),
		i(1, "size_t"),
		t(" "),
		i(2, "i"),
		t(" = 0; "),
		f(mirror, { 2 }),
		t(" < "),
		i(3, "n"),
		t("; ++"),
		f(mirror, { 2 }),
		t(") {"),
		t({ "", "    " }),
		i(0),
		t({ "", "}" }),
	}),

	-- while: while loop.
	s({ trig = "while", name = "while loop" }, {
		t("while ("),
		i(1, "condition"),
		t(") {"),
		t({ "", "    " }),
		i(0),
		t({ "", "}" }),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- MEMORY
	-- ══════════════════════════════════════════════════════════════════════════

	-- alloc: malloc with null-check — the safe C allocation pattern.
	s({ trig = "alloc", name = "malloc + null check" }, {
		i(1, "Type"),
		t(" *"),
		i(2, "ptr"),
		t(" = malloc(sizeof("),
		f(mirror, { 1 }),
		t(") * "),
		i(3, "n"),
		t(");"),
		t({ "", "if (!" }),
		f(mirror, { 2 }),
		t(") {"),
		t({ "", "    " }),
		i(0, "/* handle allocation failure */"),
		t({ "", "}" }),
	}),

	-- allocz: calloc — zero-initialised allocation.
	s({ trig = "allocz", name = "calloc (zero-initialised)" }, {
		i(1, "Type"),
		t(" *"),
		i(2, "ptr"),
		t(" = calloc("),
		i(3, "n"),
		t(", sizeof("),
		f(mirror, { 1 }),
		t("));"),
		t({ "", "if (!" }),
		f(mirror, { 2 }),
		t(") {"),
		t({ "", "    " }),
		i(0, "/* handle allocation failure */"),
		t({ "", "}" }),
	}),

	-- free: free + null guard.
	s({ trig = "freep", name = "free + null-clear" }, {
		t("free("),
		i(1, "ptr"),
		t("); "),
		f(mirror, { 1 }),
		t(" = NULL;"),
	}),

	-- memcpy: checked memcpy pattern.
	s({ trig = "memcpy", name = "memcpy" }, {
		t("memcpy("),
		i(1, "dest"),
		t(", "),
		i(2, "src"),
		t(", sizeof("),
		i(3, "Type"),
		t(") * "),
		i(4, "n"),
		t(");"),
	}),

	-- memset: memset to zero.
	s({ trig = "memset", name = "memset to zero" }, {
		t("memset("),
		i(1, "ptr"),
		t(", 0, sizeof("),
		c(2, {
			s("", { t("*"), f(mirror, { 1 }) }), -- sizeof(*ptr)
			i(nil, "Type"), -- sizeof(Type)
		}),
		t("));"),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- I/O
	-- ══════════════════════════════════════════════════════════════════════════

	-- printf: printf to stdout.
	s({ trig = "printf", name = "printf" }, {
		t('printf("'),
		i(1, "%s\\n"),
		t('", '),
		i(0, "value"),
		t(");"),
	}),

	-- fprintf: fprintf to stderr — for error messages.
	s({ trig = "fprintf", name = "fprintf to stderr" }, {
		t('fprintf(stderr, "'),
		i(1, "error: %s\\n"),
		t('", '),
		i(0, "msg"),
		t(");"),
	}),

	-- file: FILE* open / use / close pattern.
	s({ trig = "file", name = "FILE* open / use / close" }, {
		t("FILE *"),
		i(1, "fp"),
		t(" = fopen("),
		i(2, '"path"'),
		t(", "),
		c(3, { t('"r"'), t('"w"'), t('"a"'), t('"rb"'), t('"wb"') }),
		t(");"),
		t({ "", "if (!" }),
		f(mirror, { 1 }),
		t(") {"),
		t({ "", '    fprintf(stderr, "fopen failed\\n");' }),
		t({ "", "    return" }),
		c(4, { t(" -1;"), t(" NULL;"), t(";") }),
		t({ "", "}" }),
		t({ "", "", "/* use " }),
		f(mirror, { 1 }),
		t(" */"),
		t({ "", "// " }),
		i(0),
		t({ "", "", "fclose(" }),
		f(mirror, { 1 }),
		t(");"),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- ERROR HANDLING
	-- ══════════════════════════════════════════════════════════════════════════

	-- errchk: errno + strerror pattern — check after a syscall.
	s({ trig = "errchk", name = "errno / strerror check" }, {
		t("if ("),
		i(1, "result"),
		t(" == "),
		c(2, { t("-1"), t("NULL"), t("0") }),
		t(") {"),
		t({ "", '    fprintf(stderr, "' }),
		i(3, "operation"),
		t({ ': %s\\n", strerror(errno));' }),
		t({ "", "    " }),
		i(0),
		t({ "", "}" }),
	}),

	-- assert: assert() with an explanatory comment.
	s({ trig = "assert", name = "assert()" }, {
		t("assert("),
		i(1, "condition"),
		t(");"),
		t("  /* "),
		i(2, "invariant description"),
		t(" */"),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- UTILITY
	-- ══════════════════════════════════════════════════════════════════════════

	-- arrlen: compile-time array length macro (C99 / GNU).
	s({ trig = "arrlen", name = "array length macro" }, {
		t("#define ARRAY_LEN(a) (sizeof(a) / sizeof((a)[0]))"),
	}),

	-- null: NULL pointer check guard.
	s({ trig = "null", name = "NULL pointer check" }, {
		t("if ("),
		i(1, "ptr"),
		t(" == NULL) {"),
		t({ "", "    " }),
		i(0),
		t({ "", "}" }),
	}),

	-- min / max: safe MIN/MAX macros (avoids double-evaluation with typeof).
	s({ trig = "minmax", name = "MIN/MAX macros (typeof, no double-eval)" }, {
		t({
			"#define MIN(a, b) __extension__ ({  \\",
			"    __typeof__(a) _a = (a);         \\",
			"    __typeof__(b) _b = (b);         \\",
			"    _a < _b ? _a : _b; })",
			"#define MAX(a, b) __extension__ ({  \\",
			"    __typeof__(a) _a = (a);         \\",
			"    __typeof__(b) _b = (b);         \\",
			"    _a > _b ? _a : _b; })",
		}),
	}),
}

-- ── register ─────────────────────────────────────────────────────────────────

return {
	ls.add_snippets("cpp", cpp_snippets),
	ls.add_snippets("c", c_snippets),
}
