-- after/ftplugin/erl.lua
vim.keymap.set(
	"i",
	"<tab>",
	"<c-r>=myfuncs#Smart_TabComplete()<CR>",
	{ buffer = true, silent = true, desc = "Erlang smart tab-complete" }
)
