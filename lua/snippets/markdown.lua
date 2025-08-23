local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

return {
	ls.add_snippets("markdown", {
		s({ trig = "_skel", name = "_skel" }, {
			t({
				"---",
				"title: " .. vim.fn.expand("%:t:r"),
				"Author: Ryan M Sullivan",
				"date: " .. os.date("%Y-%m-%d"),
				"---",
				"",
			}),
		}),
	}),
}
