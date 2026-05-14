-- lua/snippets/markdown.lua
-- LuaSnip snippet definitions for markdown files.
-- This file is executed by LuaSnip's from_lua loader in its own context.
-- Do NOT put autocmds, keymaps, or any Neovim API calls here that depend
-- on variables from other files (e.g. aucmd from autocmds.lua).

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
	ls.add_snippets("markdown", {

		-- _skel: manual trigger if you ever want to re-insert the frontmatter
		-- Auto-insertion on BufNewFile is handled in autocmds.lua
		s({ trig = "_skel", name = "_skel" }, {
			t({
				"---",
				"title: ",
			}),
			i(1, vim.fn.expand("%:t:r")),
			t({ "", "author: Ryan M Sullivan", "date: " .. os.date("%Y-%m-%d"), "tags: []", "---", "", "" }),
			i(0),
		}),
	}),
}
