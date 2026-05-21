local ls = require("luasnip")
local s, t, i, f, c = ls.snippet, ls.text_node, ls.insert_node, ls.function_node, ls.choice_node

return {
	ls.add_snippets("lua", {
		s({ trig = "req", name = "require" }, {
			t("local "),
			i(1, "mod"),
			t(' = require("'),
			f(function(args)
				return args[1][1]
			end, { 1 }),
			t('")'),
		}),

		s({ trig = "lf", name = "local function" }, {
			t("local function "),
			i(1, "name"),
			t("("),
			i(2),
			t({ ")", "  " }),
			i(0),
			t({ "", "end" }),
		}),
	}),
}
