return {
	-- ── Highlight patterns (TODO/FIXME/HACK/NOTE + hex colors) ──────────────
	{
		"echasnovski/mini.hipatterns",
		event = "BufReadPre",
		config = function()
			local hipatterns = require("mini.hipatterns")
			hipatterns.setup({
				highlighters = {
					fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
					hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
					todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
					note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
					hex_color = hipatterns.gen_highlighter.hex_color(),
				},
			})
		end,
	},

	-- ── Trailing whitespace highlighting + trim keymap ───────────────────────
	{
		"echasnovski/mini.trailspace",
		event = "BufReadPre",
		opts = {
			only_in_normal_buffers = true,
		},
		keys = {
			{
				"<leader>W",
				function()
					require("mini.trailspace").trim()
				end,
				desc = "Trim trailing whitespace",
			},
			{
				"<leader>WL",
				function()
					require("mini.trailspace").trim_last_lines()
				end,
				desc = "Trim trailing empty lines",
			},
		},
	},

	-- ── Context-aware commentstring (needed for JSX, PHP, etc.) ─────────────
	-- Provides correct comment syntax in mixed-language files.
	-- enable_autocmd = false because mini.comment calls it manually.
	{
		"JoosepAlviste/nvim-ts-context-commentstring",
		lazy = true,
		opts = {
			enable_autocmd = false,
		},
	},

	-- lua/config/plugins/mini.lua  ── mini.ai block ──────────────────────────────
	{
		"echasnovski/mini.ai",
		event = "VeryLazy",
		dependencies = {
			-- Provides @function.outer/inner, @class.outer/inner, @conditional.*,
			-- @loop.* capture groups that gen_spec.treesitter() resolves against.
			-- Works alongside your neovim-treesitter fork — it only adds .scm query
			-- files to the runtime path, no module conflicts.
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		opts = function()
			local ai = require("mini.ai")
			return {
				-- ── CRITICAL: default is 50 ─────────────────────────────────────────
				-- Anything under this many lines from the cursor is invisible to
				-- mini.ai. A 60-line C++ method silently falls through to the next
				-- candidate. 500 covers all realistic function sizes without
				-- noticeable search latency.
				n_lines = 500,

				custom_textobjects = {
					-- ── Symmetric delimiter pairs ─────────────────────────────────
					-- REMOVED: ["/"] — greedy pair on "/" fires inside every // comment
					--   line and Lua/TS string paths. More dangerous than useful.
					-- REMOVED: [":"] — fights std::, Lua table keys, and TS type
					--   annotations constantly. Not worth the false-positive rate.
					["|"] = ai.gen_spec.pair("|", "|", { type = "greedy" }),
					["."] = ai.gen_spec.pair(".", ".", { type = "greedy" }),
					["*"] = ai.gen_spec.pair("*", "*", { type = "greedy" }),
					["_"] = ai.gen_spec.pair("_", "_", { type = "greedy" }),
					["\\"] = ai.gen_spec.pair("\\", "\\", { type = "greedy" }),

					-- ── Treesitter: function definition ───────────────────────────
					-- Overrides mini.ai's built-in 'f' (function *call*) with
					-- function *definition* — far more useful for edit/nav.
					--   vif  = select body only (inside braces)
					--   vaf  = select full def  (return type + signature + body)
					--   cif  = change body, leave signature intact
					-- Works across all your TS parsers: C++, Lua, Python, TS, Rust,
					-- PHP, C#, Zig, R.
					f = ai.gen_spec.treesitter({
						a = { "@function.outer" },
						i = { "@function.inner" },
					}),

					-- ── Treesitter: class / struct ────────────────────────────────
					-- 'c' = class or struct body.
					--   vic  = select members only
					--   vac  = select full declaration incl. name and specifiers
					--   dac  = delete the entire class (with confirmation via undo)
					-- Covers: class (C++/C#/Python/TS/PHP/Rust), struct (C/C++/Rust/Zig),
					-- table (Lua), module (R).
					c = ai.gen_spec.treesitter({
						a = { "@class.outer" },
						i = { "@class.inner" },
					}),

					-- ── Treesitter: control-flow block ────────────────────────────
					-- 'o' = conditional (if/else/switch) or loop (for/while).
					-- Multiple captures: mini.ai picks the nearest enclosing one.
					--   vio  = select body (the branch you're inside)
					--   vao  = select full block including condition/header
					--   dao  = delete a whole branch/loop cleanly
					o = ai.gen_spec.treesitter({
						a = { "@conditional.outer", "@loop.outer" },
						i = { "@conditional.inner", "@loop.inner" },
					}),

					-- ── Number literal ────────────────────────────────────────────
					-- 'D' (Digit) = any contiguous digit sequence.
					-- Built with a plain pattern spec — no treesitter needed.
					--   viD  = select the number (e.g. `42`, `3.14`, `0xFF` digits)
					--   ciD  = change a numeric literal in-place
					--   yiD  = yank a literal to paste elsewhere
					-- High-value in C++ (template args, enum values, array sizes),
					-- CSS/SCSS (px/rem values), SQL (WHERE clauses), config files.
					D = { "%d+" },
				},

				search_method = "cover_or_next",
			}
		end,
	},

	-- ── Commenting with treesitter context awareness ─────────────────────────
	{
		"echasnovski/mini.comment",
		version = "*",
		-- VeryLazy lets mini.comment register its own gc/gcc/etc. mappings at startup.
		-- Do NOT add a keys = {} table here — mini.comment owns those mappings
		-- via opts.mappings and calling its internal API directly causes errors.
		event = "VeryLazy",
		dependencies = {
			"JoosepAlviste/nvim-ts-context-commentstring",
		},
		opts = {
			options = {
				custom_commentstring = function()
					return require("ts_context_commentstring").calculate_commentstring() or vim.bo.commentstring
				end,
			},
			mappings = {
				-- These are mini.comment's built-in mapping names — do not duplicate
				-- them in a keys = {} block or you will get conflicting handlers.
				comment = "gc",
				comment_line = "gcc",
				comment_visual = "gc",
				textobject = "gc",
			},
		},
	},

	-- ── Icons (Nerd Fonts v3, mocks nvim-web-devicons for plugin compat) ─────
	{
		"echasnovski/mini.icons",
		lazy = true,
		opts = {
			file = {
				[".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
				["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
			},
			filetype = {
				dotenv = { glyph = "", hl = "MiniIconsYellow" },
			},
			-- neotest state icons — pulled via MiniIcons.get("lsp", "neotest_*")
			-- in neotest.lua. Uses catppuccin-themed diagnostic highlights.
			lsp = {
				neotest_passed = { glyph = "", hl = "DiagnosticOk" },
				neotest_failed = { glyph = "", hl = "DiagnosticError" },
				neotest_running = { glyph = "", hl = "DiagnosticWarn" },
				neotest_skipped = { glyph = "", hl = "DiagnosticHint" },
				neotest_unknown = { glyph = "", hl = "DiagnosticInfo" },
				neotest_watching = { glyph = "󰈈", hl = "DiagnosticInfo" },
			},
		},
		init = function()
			-- Make mini.icons respond to require("nvim-web-devicons") calls
			-- so plugins that depend on it work without installing it separately.
			package.preload["nvim-web-devicons"] = function()
				require("mini.icons").mock_nvim_web_devicons()
				return package.loaded["nvim-web-devicons"]
			end
		end,
		config = function(_, opts)
			-- FIX: opts MUST be passed to setup() or all custom entries are ignored.
			-- Previously this function only called tweak_lsp_kind, so the file,
			-- filetype, and lsp overrides in opts were silently discarded.
			require("mini.icons").setup(opts)
			-- Prepend icons to LSP completion kind labels (Array, Function, etc.)
			require("mini.icons").tweak_lsp_kind("replace")
		end,
	},

	-- ── Auto pairs ───────────────────────────────────────────────────────────
	{
		"echasnovski/mini.pairs",
		version = "*",
		event = "InsertEnter", -- only needed in insert mode
		opts = {
			modes = { insert = true, command = false, terminal = false },
			mappings = {
				["("] = { action = "open", pair = "()", neigh_pattern = "[^\\]." },
				["["] = { action = "open", pair = "[]", neigh_pattern = "[^\\]." },
				["{"] = { action = "open", pair = "{}", neigh_pattern = "[^\\]." },
				[")"] = { action = "close", pair = "()", neigh_pattern = "[^\\]." },
				["]"] = { action = "close", pair = "[]", neigh_pattern = "[^\\]." },
				["}"] = { action = "close", pair = "{}", neigh_pattern = "[^\\]." },
				['"'] = { action = "closeopen", pair = '""', neigh_pattern = "[^\\].", register = { cr = false } },
				["'"] = { action = "closeopen", pair = "''", neigh_pattern = "[^%a\\].", register = { cr = false } },
				["`"] = { action = "closeopen", pair = "``", neigh_pattern = "[^\\].", register = { cr = false } },
			},
		},
	},

	-- ── Surround operations (sa/sd/sc/sf/sF/sh/sn) ──────────────────────────
	{
		"echasnovski/mini.surround",
		version = "*",
		-- FIX: removed `recommended = true` — not a valid lazy.nvim spec field
		keys = {
			{ "sa", desc = "Add surrounding" },
			{ "sd", desc = "Delete surrounding" },
			{ "sc", desc = "Replace surrounding" },
			{ "sf", desc = "Find surrounding (right)" },
			{ "sF", desc = "Find surrounding (left)" },
			{ "sh", desc = "Highlight surrounding" },
			{ "sn", desc = "Update n_lines" },
		},
		opts = {
			custom_surroundings = nil,
			highlight_duration = 500,
			mappings = {
				add = "sa",
				delete = "sd",
				find = "sf",
				find_left = "sF",
				highlight = "sh",
				replace = "sc",
				update_n_lines = "sn",
				suffix_last = "l",
				suffix_next = "n",
			},
			n_lines = 20,
			respect_selection_type = false,
			search_method = "cover",
			silent = false,
		},
	},
}
