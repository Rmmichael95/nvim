local ls = require("luasnip")
local s, t, i, f, c = ls.snippet, ls.text_node, ls.insert_node, ls.function_node, ls.choice_node

return {
	ls.add_snippets("lua", {
		-- Python skeleton on new file
		aucmd("BufNewFile", {
			pattern = "*.py",
			callback = function()
				vim.schedule(load_document_skeleton)
			end,
		}),

		-- R skeleton on new file
		aucmd("BufNewFile", {
			pattern = { "*.r", "*.R" },
			callback = function()
				vim.schedule(load_document_skeleton)
			end,
		}),
	}),
}
