-- lua/config/plugins/lsp/lang/system.lua
-- Miscellaneous servers that need no special configuration
local lsp = require("config.util")

lsp.setup("yamlls")
lsp.setup("vimls")
lsp.setup("zls")
lsp.setup("wasm_language_tools")
lsp.setup("systemd_ls")
