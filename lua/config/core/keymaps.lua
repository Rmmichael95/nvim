local g = vim.g
local cmd = vim.cmd
local map = vim.keymap

-- map the leader key
g.mapleader = " "
g.maplocalleader = "\\"

-- Toggle maximize current split
local _maximized = false
map.set("n", "<leader>wm", function()
	_maximized = not _maximized
	if _maximized then
		vim.cmd("wincmd _")
		vim.cmd("wincmd |")
	else
		vim.cmd("wincmd =")
	end
end, { desc = "Toggle maximize split" })

-- Clear search with <esc>
map.set({ "i", "n", "s" }, "<esc>", function()
	vim.cmd("noh")
	-- if using blink.cmp or luasnip, stop snippet session here
	return "<esc>"
end, { expr = true })

-- Clear search, diff update and redraw
-- taken from runtime/lua/_editor.lua
map.set(
	"n",
	"<leader>ur",
	"<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
	{ desc = "Redraw / Clear hlsearch / Diff Update" }
)

-- J normally jerks your cursor rightward
map.set("n", "J", "mzJ`z", { desc = "Join lines, preserve cursor" })
-- S is normally covered by cc
map.set("n", "S", "i<cr><esc>^mwgk:silent! s/\\v +$//<cr>:noh<cr>`w", { desc = "Split line at cursor" })
-- You never want Ex mode. Make Q useful
map.set("n", "Q", "gqip", { desc = "Reformat paragraph" })
map.set("v", "Q", "gq", { desc = "Reformat selection" })
-- Great for typing constants without Capslock
map.set("i", "<C-u>", "<esc>mzgUiw`za", { desc = "Uppercase current word" })
--  Prevent Accidental Undo in Visual Mode
vim.keymap.set("v", "u", "<nop>", { desc = "Disabled: use gu to lowercase" })
vim.keymap.set("v", "gu", "u", { desc = "Lowercase selection" })

-- map.set("n", "q:", "<nop>") -- disable cmd history popup
-- map.set("n", "Q", "gq") -- disable cmd history popup

map.set("c", "<C-A>", "<Home>") -- bash like keys for the command line
map.set("c", "<C-E>", "<End>") -- bash like keys for the command line
map.set("c", "<C-K>", "<C-U>") -- bash like keys for the command line

map.set("c", "cd.", "<Cmd>lcd %:p:h<CR>") -- :cd. change working directory to that of the current file

-- Very Magic Mode
-- map.set("c", "/", "/\\v") -- use sane regexes

map.set("n", "n", "nzzzv") -- keep search in center screen
map.set("n", "N", "Nzzzv") -- keep search in center screen
map.set("n", "H", "^") -- keep search in center screen
map.set("n", "L", "g_") -- keep search in center screen
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

map.set("n", "]q", "<cmd>cnext<CR>zz", { desc = "Next quickfix" })
map.set("n", "[q", "<cmd>cprev<CR>zz", { desc = "Prev quickfix" })
map.set("n", "]Q", "<cmd>clast<CR>zz", { desc = "Last quickfix" })
map.set("n", "[Q", "<cmd>cfirst<CR>zz", { desc = "First quickfix" })

vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- Resize window using <ctrl> arrow keys
map.set("n", "<C-Up>", "<Cmd>resize +2<CR>", { desc = "Increase Window Height" })
map.set("n", "<C-Down>", "<Cmd>resize -2<CR>", { desc = "Decrease Window Height" })
map.set("n", "<C-Left>", "<Cmd>vertical resize -2<CR>", { desc = "Decrease Window Width" })
map.set("n", "<C-Right>", "<Cmd>vertical resize +2<CR>", { desc = "Increase Window Width" })

map.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map.set("n", "[b", "<cmd>bprevious<cr>")
map.set("n", "]b", "<cmd>bnext<cr>")
map.set("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to last buffer" })
map.set("n", "<C-h>", "<C-w>h") -- easy buffer navigation
map.set("n", "<C-j>", "<C-w>j") -- easy buffer navigation
map.set("n", "<C-k>", "<C-w>k") -- easy buffer navigation
map.set("n", "<C-l>", "<C-w>l") -- easy buffer navigation
-- Select Entire Buffer
vim.keymap.set("n", "vaa", "ggvGg_", { desc = "Select entire buffer (charwise)" })
vim.keymap.set("n", "Vaa", "ggVG", { desc = "Select entire buffer (linewise)" })

-- Move Lines
map.set("n", "<A-j>", "<Cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
map.set("n", "<A-k>", "<Cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map.set("i", "<A-j>", "<esc><Cmd>m .+1<cr>==gi", { desc = "Move Down" })
map.set("i", "<A-k>", "<esc><Cmd>m .-2<cr>==gi", { desc = "Move Up" })
map.set("v", "<A-j>", "<Cmd><C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
map.set("v", "<A-k>", "<Cmd><C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

map.set("c", ",S", "<Cmd>w !sudo tee > /dev/null %<CR>", { noremap = false, desc = "Save as SUDO" })
map.set("n", ",q", "<Cmd>q!<CR>") -- easy quit
map.set("n", ",w", "<Cmd>w!<CR>") -- easy write
map.set("n", ",W", "<Cmd>w!!<CR>") -- force quit
map.set("n", ",z", "<Cmd>wq!<CR>") -- force save quit
map.set("n", ",d", "<Cmd>_d<CR>") -- delete to blackhole buffer
map.set("n", ",e", "<Cmd>w!<CR>:e<CR>") -- reload file
map.set({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })

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

-- vim-unimpaired style keymaps
map.set("n", "]q", "<cmd>cnext<cr>", { desc = "Next quickfix" })
map.set("n", "[q", "<cmd>cprev<cr>", { desc = "Prev quickfix" })
map.set("n", "]l", "<cmd>lnext<cr>", { desc = "Next loclist" })
map.set("n", "[l", "<cmd>lprev<cr>", { desc = "Prev loclist" })

-- better indenting
map.set("v", "<", "<gv") -- allow multiple indentation in visual mode
map.set("v", ">", ">gv") -- allow multiple deindentation in visual mode
map.set("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Below" })
map.set("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })

map.set("t", "<ESC>", "<C-\\><C-n><C-w><C-p>") -- <ESC> exits in terminal mode

-- Adding these means each ,.;: is a separate undo step — huge for prose/code editing
map.set("i", ",", ",<c-g>u")
map.set("i", ".", ".<c-g>u")
map.set("i", ";", ";<c-g>u")

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

-- keymaps.lua: add these two lines
map.set({ "n", "i" }, "<leader><leader>", "<Esc>:keepp /<++><CR>ca<", { desc = "Jump to placeholder <++>" })
map.set("n", "<leader>Z", function()
	Snacks.zen()
end, { desc = "Zen mode" })

-- Trigger AI Semantic Search with prompt
vim.keymap.set("n", "<leader>sa", function()
	vim.ui.input({ prompt = "AI Concept Search: " }, function(input)
		if input and input ~= "" then
			vim.cmd("Nai " .. input)
		end
	end)
end, { desc = "AI Semantic Note Search" })

map.set("n", "<leader>xl", function()
	local success, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
	if not success and err then
		vim.notify(err, vim.log.levels.ERROR)
	end
end, { desc = "Location List" })

map.set("n", "<leader>xq", function()
	local success, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
	if not success and err then
		vim.notify(err, vim.log.levels.ERROR)
	end
end, { desc = "Quickfix List" })
