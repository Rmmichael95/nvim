local g = vim.g
local cmd = vim.cmd
local map = vim.keymap

-- map the leader key
g.mapleader = " "
g.maplocalleader = "\\"

-- extended text objects
cmd([[
let items = [ "<bar>", "\\", "/", ":", ".", "*", "_" ]
for item in items
  exe "nnoremap yi".item." T".item."yt".item
  exe "nnoremap ya".item." F".item."yf".item
  exe "nnoremap ci".item." T".item."ct".item
  exe "nnoremap ca".item." F".item."cf".item
  exe "nnoremap di".item." T".item."dt".item
  exe "nnoremap da".item." F".item."df".item
  exe "nnoremap vi".item." T".item."vt".item
  exe "nnoremap va".item." F".item."vf".item
endfor
]])

-- Clear search with <esc>
-- map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and Clear hlsearch" })

-- Clear search, diff update and redraw
-- taken from runtime/lua/_editor.lua
map.set(
	"n",
	"<leader>ur",
	"<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
	{ desc = "Redraw / Clear hlsearch / Diff Update" }
)

map.set("c", "<C-A>", "<Home>") -- bash like keys for the command line
map.set("c", "<C-E>", "<End>") -- bash like keys for the command line
map.set("c", "<C-K>", "<C-U>") -- bash like keys for the command line

map.set("c", "cd.", "<Cmd>lcd %:p:h<CR>") -- :cd. change working directory to that of the current file

map.set("c", "/", "/\v") -- use sane regexes

map.set("n", "<leader>y", ':if expand("%:e") == "h" | e %:r.cpp | else | e %:r.h | endif<CR>') -- switch between cpp/h files

map.set("n", "n", "nzzzv") -- keep search in center screen
map.set("n", "N", "Nzzzv") -- keep search in center screen
map.set("n", "H", "^") -- keep search in center screen
map.set("n", "L", "g") -- keep search in center screen
map.set("n", "g;", "g;zz") -- keep search in center screen
map.set("n", "g,", "g,zz") -- keep search in center screen
map.set("n", "<c-o>", "<c-o>zz") -- keep search in center screen
map.set("n", "<C-d>", "<C-d>zz") -- center page up
map.set("n", "<C-u>", "<C-u>zz") -- center page down

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map.set("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
map.set("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map.set("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map.set("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
map.set("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
map.set("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

map.set("n", ";", ":") -- easy command mode
map.set("n", "V", "V`]") -- easy linewise reselection of what you just paste

map.set("n", "q:", "<nop>") -- disable cmd history popup
map.set("n", "Q", "<nop>") -- disable cmd history popup

map.set("n", "<leader>|", "<Cmd>vsplit<CR>") -- easy vertical split
map.set("n", "<leader>-", "<Cmd>split<CR>") -- easy horizontal split
map.set("n", "<leader>=", "<C-w>=") -- easy equal splits
map.set("n", "<C-J>", "<C-W><C-J>") -- ctrl-j to move down a split
map.set("n", "<C-K>", "<C-W><C-K>") -- ctrl-k to move up a split
map.set("n", "<C-L>", "<C-W><C-L>") -- ctrl-l to move right a split
map.set("n", "<C-H>", "<C-W><C-H>") -- ctrl-h to move left a split

map.set("n", "<C-t><C-t>", "<Cmd>tabnew<CR>") -- easy new tab
map.set("n", "<C-t><C-z>", "<Cmd>tabclose<CR>") -- easy close tab
map.set("n", "<C-t><C-n>", "<Cmd>tabn<CR>") -- easy next tab
map.set("n", "<C-t><C-p>", "<Cmd>tabp<CR>") -- easy prev tab

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- Resize window using <ctrl> arrow keys
map.set("n", "<C-Up>", "<Cmd>resize +2<CR>", { desc = "Increase Window Height" })
map.set("n", "<C-Down>", "<Cmd>resize -2<CR>", { desc = "Decrease Window Height" })
map.set("n", "<C-Left>", "<Cmd>vertical resize -2<CR>", { desc = "Decrease Window Width" })
map.set("n", "<C-Right>", "<Cmd>vertical resize +2<CR>", { desc = "Increase Window Width" })

map.set("n", "<C-9>", ":bp<CR>") -- easy switch buffers
map.set("n", "<C-0>", ":bn<CR>") -- easy switch buffers
map.set("n", "<C-h>", "<C-w>h") -- easy buffer navigation
map.set("n", "<C-j>", "<C-w>j") -- easy buffer navigation
map.set("n", "<C-k>", "<C-w>k") -- easy buffer navigation
map.set("n", "<C-l>", "<C-w>l") -- easy buffer navigation
map.set("n", "vaa", "ggvGg_") -- select entire buffer
map.set("n", "Vaa", "ggVG") -- select entire buffer

-- Move Lines
map.set("n", "<A-j>", "<Cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
map.set("n", "<A-k>", "<Cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map.set("i", "<A-j>", "<esc><Cmd>m .+1<cr>==gi", { desc = "Move Down" })
map.set("i", "<A-k>", "<esc><Cmd>m .-2<cr>==gi", { desc = "Move Up" })
map.set("v", "<A-j>", "<Cmd><C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
map.set("v", "<A-k>", "<Cmd><C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

map.set("c", ",S", "w !sudo tee > /dev/null %", { noremap = false, desc = "Save as SUDO" })
map.set("n", ",q", "<Cmd>q!<CR>") -- easy quit
map.set("n", ",w", "<Cmd>w!<CR>") -- easy write
map.set("n", ",W", "<Cmd>w!!<CR>") -- force quit
map.set("n", ",z", "<Cmd>wq!<CR>") -- force save quit
map.set("n", ",d", "<Cmd>_d<CR>") -- delete to blackhole buffer
map.set("n", ",e", "<Cmd>w!<CR><Cmd>e %<Cmd>h<CR>") -- open file dir

map.set("n", "Y", "y$") -- fix Y behaviour
map.set("n", "D", "d$") -- fix D behaviour

map.set("n", ",cd", "<Cmd>cd %:p:h<CR>:pwd<CR>") -- change wd to where the file in the buffer is located w/ `,cd`

map.set("n", "<F9>", "<Cmd>call myfuncs#CycleLang()<CR>") -- call my spell check function

map.set("n", "Vit", "vitVkoj") -- fix linewise visual selection of various text objects
map.set("n", "Vat", "vatV") -- fix linewise visual selection of various text objects
map.set("n", "Vab", "vabV") -- fix linewise visual selection of various text objects
map.set("n", "VaB", "vaBV") -- fix linewise visual selection of various text objects

map.set("n", "gI", "``.") -- gi moves to "last place you exited insert mode", map gI to move to last change

map.set("n", "<leader>c", '<Cmd>w! | !compiler "%:p"<CR>')

-- better up/down
map.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map.set({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map.set({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- map.set("n", ",T", ":let _s=@/<Bar>:%s/\\s\\+$//e<Bar>%s/ \\+\\ze\\t//e<Bar>:let @/=_s<Bar>:unlet _s<CR>", opts) -- trim whitespace before tabs and eol

-- better indenting
map.set("v", "<", "<gv") -- allow multiple indentation in visual mode
map.set("v", ">", ">gv") -- allow multiple deindentation in visual mode

map.set("t", "<ESC>", "<C-\\><C-n><C-w><C-p>") -- <ESC> exits in terminal mode

-- Map vim user command from command.lua

-- Create Note
map.set("n", "<leader>]", ":Note ", { noremap = true, desc = "Create new note" })

-- List Notes
map.set(
	"n",
	"<leader>nl",
	"<Cmd>Nls " .. vim.fn.expand("<cword>") .. "<CR><CR>",
	{ noremap = true, desc = "Search notes for selected word" }
)
map.set("n", "<leader>[", ":Nls ", { noremap = true, desc = "Search notes for word" })
map.set(
	"n",
	"<localleader>,",
	"<CR><C-w>p",
	{ buffer = true, noremap = true, silent = true, desc = "Return to list quickfix window" }
)
