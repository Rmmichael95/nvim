local ls = require("luasnip")
local s, t, i, f, c = ls.snippet, ls.text_node, ls.insert_node, ls.function_node, ls.choice_node

return {
	ls.add_snippets("r", {

		s({ trig = "_skel", name = "_skel" }, {
			t({ "#' ", "" }),
			i(1, "Title"),
			t({ "", "#' @author Ryan M Sullivan", "#' @date " .. os.date("%Y-%m-%d"), "", "" }),
			i(0),
		}),

		s({ trig = "fn", name = "function" }, {
			i(1, "name"),
			t(" <- function("),
			i(2),
			t({ ") {", "  " }),
			i(0),
			t({ "", "}" }),
		}),

		s({ trig = "lib", name = "library" }, {
			t("library("),
			i(1),
			t(")"),
		}),
	}),
}
