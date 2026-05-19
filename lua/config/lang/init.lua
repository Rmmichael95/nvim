-- lua/config/lang/init.lua
--
-- Auto-loader: requires every *.lua file in this directory.
-- Each lang file registers its own FileType autocmd as a side effect of
-- being required — no explicit registration needed here.
--
-- Usage: one line in lua/config/core/init.lua:
--   require("config.lang")
--
-- Adding a language: drop lua/config/lang/js.lua (or whatever).
-- Removing a language: delete the file.
-- No registration, no index to update.
--
-- Each lang file is expected to call vim.api.nvim_create_autocmd("FileType", ...)
-- internally. Returning a table is optional but useful for introspection:
--   local lang = require("config.lang")
--   -- lang.js, lang.cs, etc. are the returned tables from each file

local M = {}

local lang_dir = vim.fn.stdpath("config") .. "/lua/config/lang"

for _, file in ipairs(vim.fn.glob(lang_dir .. "/*.lua", false, true)) do
	if not file:match("init%.lua$") then
		-- "…/lua/config/lang/js.lua"  →  "config.lang.js"
		local mod_name = file:gsub(vim.fn.stdpath("config") .. "/lua/", ""):gsub("/", "."):gsub("%.lua$", "")

		-- Short key for the returned table: "config.lang.js" → "js"
		local key = mod_name:match("([^.]+)$")

		local ok, mod = pcall(require, mod_name)
		if ok then
			M[key] = mod
		else
			vim.notify("config.lang: failed to load '" .. mod_name .. "'\n" .. tostring(mod), vim.log.levels.WARN)
		end
	end
end

return M
