-- lua/config/plugins/lsp/lang/r_lang.lua
local lsp = require("config.util")

lsp.setup("r_language_server", {
	root_dir = function(fname)
		local util = require("lspconfig.util")
		return util.root_pattern("DESCRIPTION", "NAMESPACE", ".Rbuildignore")(fname)
			or util.find_git_ancestor(fname)
			or vim.loop.os_homedir()
	end,
})
