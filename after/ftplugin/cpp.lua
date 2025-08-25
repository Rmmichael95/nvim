local g = vim.g
local o = vim.opt -- set options
local cmd = vim.cmd
local map = vim.keymap

o.tabstop = 2 -- number of spaces in a tab
o.softtabstop = 2 -- make spaces feel like tabs backspacing
o.shiftwidth = 2 -- read help to set up later

-- switch cpp to header with vimscript
-- map.set("n", "<leader>ch", '<Cmd>if expand("%:e") == "h" | e %:r.cpp | else | e %:r.h | endif<CR>')

-- switch cpp to header with lsp
map.set("n", "<leader>ch", "<Cmd>LspClangdSwitchSourceHeader<CR>")
