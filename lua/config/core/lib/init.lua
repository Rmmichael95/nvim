-- lua/config/core/lib/init.lua
--
-- Auto-loader: requires every *.lua file in this directory and merges
-- its returned table into a single module.
--
-- Usage from anywhere in the config:
--   local lib = require("config.core.lib")
--   lib.spell.cycle_lang()
--   lib.files.open_all()
--
-- Or destructured:
--   local cycle_lang = require("config.core.lib").spell.cycle_lang
--
-- Adding a function: drop a new file in lua/config/core/lib/ that
-- returns a table of functions. No registration needed — it is picked
-- up automatically on next startup (or :source init.lua).

local M = {}

local lib_dir = vim.fn.stdpath("config") .. "/lua/config/core/lib"

for _, file in ipairs(vim.fn.glob(lib_dir .. "/*.lua", false, true)) do
	-- Skip self to avoid infinite recursion
	if not file:match("init%.lua$") then
		-- "…/lua/config/core/lib/spell.lua"  →  "config.core.lib.spell"
		local mod_name = file:gsub(vim.fn.stdpath("config") .. "/lua/", ""):gsub("/", "."):gsub("%.lua$", "")

		-- Derive a short key from the filename: "config.core.lib.spell" → "spell"
		local key = mod_name:match("([^.]+)$")

		local ok, mod = pcall(require, mod_name)
		if ok then
			M[key] = mod
		else
			vim.notify("config.core.lib: failed to load '" .. mod_name .. "'\n" .. tostring(mod), vim.log.levels.WARN)
		end
	end
end

return M
