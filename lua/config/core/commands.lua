local cmd = vim.cmd
local command = vim.api.nvim_create_user_command

command("Nls", function(opts)
	cmd("vimgrep " .. opts.fargs[1] .. " ~/documents/.bc/batcave/Notes/**/*.md | redraw! | cw")
end, { nargs = 1 })

command("Note", function(opts)
	cmd("exe" .. '"e! ~/documents/.bc/batcave/Notes/' .. opts.fargs[1] .. '.md"')
end, { nargs = 1 })

command("Rts", function(opts)
	cmd("<Cmd>'<,'>!pandoc -f markdown -t rst<CR>")
end, {})
