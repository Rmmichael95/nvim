local cmd = vim.cmd
local command = vim.api.nvim_create_user_command

-- highlight 81st column darkred on lines that run long
cmd([[autocmd BufEnter,FocusGained,BufWinEnter,WinEnter * match ColorColumn "\%81v."]])
cmd("highlight ColorColumn guibg=darkred")

command("Nls", function(opts)
	cmd("vimgrep " .. opts.fargs[1] .. " ~/documents/.bc/batcave/Notes/**/*.md | redraw! | cw")
end, { nargs = 1 })

command("Note", function(opts)
	cmd("exe" .. '"e! ~/documents/.bc/batcave/Notes/' .. opts.fargs[1] .. '.md"')
end, { nargs = 1 })

command("Rts", function(opts)
	cmd("<Cmd>'<,'>!pandoc -f markdown -t rst<CR>")
end, {})
