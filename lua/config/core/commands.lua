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

-- Add to the bottom of commands.lua

command("Nai", function(opts)
	-- Concatenate all arguments into a single string for multi-word queries
	local query = table.concat(opts.fargs, " ")

	if not _G.Snacks then
		print("Snacks.nvim is required for AI search.")
		return
	end

	Snacks.picker.files({
		title = "Semantic Search: " .. query,
		-- Hijack the default 'fd' or 'rg' command to use our local NPU script
		cmd = "npu-search",
		args = { query },
		-- Tell Snacks not to re-sort the initial results, preserving the NPU's cosine similarity ranking
		sort = { empty = true },
	})
end, { nargs = "*" })
