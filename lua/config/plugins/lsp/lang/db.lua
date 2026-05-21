-- lua/config/plugins/lsp/lang/web.lua
local lsp = require("config.util")

lsp.setup("sqls", {
	settings = {
		sqls = {
			connections = {
				{
					driver = "mysql",
					dataSourceName = "admin:password@tcp(localhost:3306)/",
				},
			},
		},
	},
})

lsp.setup("prisma", {
	filetypes = { "prisma" },
})
