local ls = require("luasnip")
local s, t, i, f, c = ls.snippet, ls.text_node, ls.insert_node, ls.function_node, ls.choice_node

return {
	ls.add_snippets("js", {
		s({ trig = "typ", name = "type definition" }, { t("type "), i(1, "Name"), t(" {\n  "), i(0), t("\n}") }),
		s({ trig = "qry", name = "query" }, { ... }),
		s({ trig = "mut", name = "mutation" }, { ... }),
		s({ trig = "inp", name = "input type" }, { ... }),
		s({ trig = "frg", name = "fragment" }, { ... }),
		s({ trig = "res", name = "resolver skeleton (TS)" }, { ... }),
	}),
}
