-- lua/config/plugins/lsp/cs_launch_settings.lua
--
-- Reads Properties/launchSettings.json from the nearest .csproj directory and
-- injects the profiles as additional netcoredbg DAP configurations.
--
-- Usage: require("config.plugins.lsp.cs_launch_settings").inject()
-- Called from dap.lua after the base cs configurations are registered.
--
-- What this gives you:
--   * Each launchSettings profile appears as a named entry in dap.continue()
--   * applicationUrl, environmentVariables, and commandLineArgs are forwarded
--   * Falls back gracefully if no launchSettings.json exists
--
-- VSCode parity: equivalent to the "Select Launch Profile" picker in C# Dev Kit.

local M = {}

-- Walk up from `start_dir` looking for a file named `filename`.
-- Returns the directory containing it, or nil.
local function find_upward(start_dir, filename)
	local dir = start_dir
	for _ = 1, 20 do -- cap at 20 levels to avoid infinite loop at fs root
		if vim.fn.filereadable(dir .. "/" .. filename) == 1 then
			return dir
		end
		local parent = vim.fn.fnamemodify(dir, ":h")
		if parent == dir then
			break
		end
		dir = parent
	end
end

-- Parse launchSettings.json and return a list of DAP configuration tables.
-- Returns an empty list if the file is missing or unparseable.
local function load_profiles(cwd)
	-- launchSettings lives next to the .csproj, under Properties/
	local project_dir = find_upward(cwd, "*.csproj") or find_upward(cwd, "*.sln") or cwd

	-- glob returns a list; grab the first .csproj directory
	local csproj_files = vim.fn.glob(project_dir .. "/**/*.csproj", false, true)
	local settings_path

	if #csproj_files > 0 then
		local csproj_dir = vim.fn.fnamemodify(csproj_files[1], ":h")
		settings_path = csproj_dir .. "/Properties/launchSettings.json"
	else
		settings_path = project_dir .. "/Properties/launchSettings.json"
	end

	if vim.fn.filereadable(settings_path) == 0 then
		return {}
	end

	local raw = table.concat(vim.fn.readfile(settings_path), "\n")
	local ok, parsed = pcall(vim.fn.json_decode, raw)
	if not ok or type(parsed) ~= "table" then
		vim.notify("[cs_launch_settings] Failed to parse " .. settings_path, vim.log.levels.WARN)
		return {}
	end

	local profiles = parsed.profiles or {}
	local configs = {}

	for name, profile in pairs(profiles) do
		-- Only handle Project profiles (not IIS Express, Docker, etc.)
		if profile.commandName == "Project" then
			local env = {}
			-- Convert launchSettings env dict → DAP env list format
			for k, v in pairs(profile.environmentVariables or {}) do
				table.insert(env, { name = k, value = tostring(v) })
			end

			-- Build the dll path the same way the base config does
			local program = function()
				local dlls = vim.fn.glob(cwd .. "/**/bin/Debug/**/*.dll", true, true)
				dlls = vim.tbl_filter(function(d)
					return not d:match("testhost")
						and not d:match("Microsoft%.")
						and not d:match("xunit")
						and not d:match("NUnit")
				end, dlls)
				if #dlls == 1 then
					return dlls[1]
				elseif #dlls > 1 then
					return vim.fn.input("Multiple DLLs, pick: ", dlls[1], "file")
				else
					return vim.fn.input("Path to dll: ", cwd .. "/bin/Debug/", "file")
				end
			end

			local cfg = {
				type = "netcoredbg",
				name = "Profile: " .. name,
				request = "launch",
				program = program,
				cwd = "${workspaceFolder}",
				stopAtEntry = false,
				env = env,
			}

			-- Forward applicationUrl as ASPNETCORE_URLS env var if present
			if profile.applicationUrl and profile.applicationUrl ~= "" then
				table.insert(cfg.env, {
					name = "ASPNETCORE_URLS",
					value = profile.applicationUrl,
				})
			end

			-- Forward commandLineArgs if present
			if profile.commandLineArgs and profile.commandLineArgs ~= "" then
				cfg.args = vim.split(profile.commandLineArgs, "%s+")
			end

			table.insert(configs, cfg)
		end
	end

	return configs
end

-- Inject launchSettings profiles into dap.configurations.cs.
-- Call this once after your base cs DAP configurations are set up in dap.lua:
--
--   require("config.plugins.lsp.cs_launch_settings").inject()
--
-- It's safe to call multiple times — duplicate profile names are skipped.
function M.inject()
	local ok, dap = pcall(require, "dap")
	if not ok then
		return
	end

	local cwd = vim.fn.getcwd()
	local profiles = load_profiles(cwd)

	if #profiles == 0 then
		return
	end

	-- Collect existing config names to avoid duplicates on re-inject
	dap.configurations.cs = dap.configurations.cs or {}
	local existing = {}
	for _, cfg in ipairs(dap.configurations.cs) do
		existing[cfg.name] = true
	end

	local added = 0
	for _, cfg in ipairs(profiles) do
		if not existing[cfg.name] then
			table.insert(dap.configurations.cs, cfg)
			added = added + 1
		end
	end

	if added > 0 then
		vim.notify(
			string.format("[cs_launch_settings] Loaded %d profile(s) from launchSettings.json", added),
			vim.log.levels.INFO
		)
	end
end

-- Auto-inject whenever a .cs buffer is opened in a new project directory.
-- Wire this up in dap.lua or autocmds.lua:
--
--   require("config.plugins.lsp.cs_launch_settings").setup_autocmd()
--
function M.setup_autocmd()
	local group = vim.api.nvim_create_augroup("CsLaunchSettings", { clear = true })
	local last_cwd = nil

	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		pattern = { "cs", "cshtml", "razor" },
		callback = function()
			local cwd = vim.fn.getcwd()
			if cwd ~= last_cwd then
				last_cwd = cwd
				M.inject()
			end
		end,
	})
end

return M
