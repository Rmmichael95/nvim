local ls = require("luasnip")
local s, t, i, f, c = ls.snippet, ls.text_node, ls.insert_node, ls.function_node, ls.choice_node

return {
	ls.add_snippets("js", {
		s({ trig = "rfc", name = "React functional component" }, { ... }),
		s({ trig = "usc", name = "use client directive" }, { t('"use client"\n\n') }),
		s({ trig = "uss", name = "use server directive" }, { t('"use server"\n\n') }),
		s({ trig = "cn", name = "cn() className helper" }, { t("cn("), i(1), t(")") }),
		s({ trig = "npage", name = "Next.js page component" }, { ... }),
		s({ trig = "nlyt", name = "Next.js layout component" }, { ... }),
		s({ trig = "napi", name = "Next.js API route handler" }, { ... }),
	}),
}
