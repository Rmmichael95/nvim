local ls = require("luasnip")
local s, t, i, f, c = ls.snippet, ls.text_node, ls.insert_node, ls.function_node, ls.choice_node

return {
	ls.add_snippets("python", {

		s({ trig = "_skel", name = "_skel" }, {
			t({ "#!/usr/bin/env python3", '"""', "" }),
			i(1, vim.fn.expand("%:t:r")), -- fix: use f() here
			t({ "", '"""', "", "" }),
			i(0),
		}),

		s({ trig = "def", name = "function" }, {
			t("def "),
			i(1, "name"),
			t("("),
			i(2),
			t({ "):", "    " }),
			i(0),
		}),

		s({ trig = "cls", name = "class" }, {
			t("class "),
			i(1, "Name"),
			c(2, { t(""), t(":") }),
			t({ ":", '    """' }),
			i(3),
			t({ '"""', "    ", "    def __init__(self" }),
			i(4),
			t({ "):", "        " }),
			i(0),
		}),

		s({ trig = "main", name = "__main__ guard" }, {
			t({ 'if __name__ == "__main__":', "    " }),
			i(0),
		}),

		s({ trig = "dc", name = "dataclass" }, {
			t({ "from dataclasses import dataclass", "", "@dataclass", "class " }),
			i(1, "Name"),
			t({ ":", "    " }),
			i(0),
		}),
	}),
}
