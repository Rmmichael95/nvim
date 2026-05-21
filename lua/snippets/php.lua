local ls = require("luasnip")
local s, t, i, f, c = ls.snippet, ls.text_node, ls.insert_node, ls.function_node, ls.choice_node

return {
	ls.add_snippets("php", {
		-- lua/snippets/php.lua  (high priority)
		s({ trig = "_skel", name = "WP plugin/theme file header" }, { ... }),
		s({ trig = "aact", name = "add_action" }, {
			t("add_action( '"),
			i(1, "hook"),
			t("', '"),
			i(2, "callback"),
			t("' );"),
		}),
		s({ trig = "aflt", name = "add_filter" }, { ... }),
		s({ trig = "rpt", name = "register_post_type" }, { ... }),
		s({ trig = "rtax", name = "register_taxonomy" }, { ... }),
		s({ trig = "shrt", name = "add_shortcode" }, { ... }),
		s({ trig = "wpq", name = "WP_Query skeleton" }, { ... }),
		s({ trig = "acff", name = "get_field (ACF)" }, { ... }),
		s({ trig = "meta", name = "add_meta_box" }, { ... }),
	}),
}
