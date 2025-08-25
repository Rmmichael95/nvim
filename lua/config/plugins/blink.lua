return {
	"saghen/blink.cmp",
	event = "InsertEnter",
	dependencies = {
		{
			"L3MON4D3/LuaSnip",
			-- follow latest release.
			version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
		},
		"mikavilpas/blink-ripgrep.nvim",
		"kristijanhusak/vim-dadbod-completion",
		"echasnovski/mini.icons",
	},
	-- use a release tag to download pre-built binaries
	version = "*",
	-- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
	-- build = 'cargo build --release',
	-- If you use nix, you can build from source using latest nightly rust with:
	-- build = 'nix run .#build-plugin',

	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		-- 'default' for mappings similar to built-in completion
		-- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
		-- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
		-- See the full "keymap" documentation for information on defining your own keymap.
		-- keymap = { preset = "default" },
		keymap = {
			["<c-x>"] = { "show", "show_documentation", "hide_documentation" },
			["<c-e>"] = { "cancel", "fallback" },
			["<tab>"] = { "snippet_forward", "accept", "fallback" },
			["<c-l>"] = { "select_and_accept", "fallback" },
			["<c-k>"] = { "select_prev", "fallback" },
			["<up>"] = { "select_prev", "fallback" },
			["<c-j>"] = { "select_next", "fallback" },
			["<down>"] = { "select_next", "fallback" },
		},

		snippets = { preset = "luasnip" },

		appearance = {
			-- Sets the fallback highlight groups to nvim-cmp's highlight groups
			-- Useful for when your theme doesn't support blink.cmp
			-- Will be removed in a future release
			use_nvim_cmp_as_default = true,
			-- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
			-- Adjusts spacing to ensure icons are aligned
			nerd_font_variant = "mono",
		},
		completion = {
			-- 'prefix' will fuzzy match on the text before the cursor
			-- 'full' will fuzzy match on the text before *and* after the cursor
			-- example: 'foo_|_bar' will match 'foo_' for 'prefix' and 'foo__bar' for 'full'
			keyword = { range = "full" },
			accept = {
				-- experimental auto-brackets support
				auto_brackets = {
					enabled = true,
				},
			},
			menu = {
				draw = {
					padding = { 0, 1 }, -- padding only on right side; for lspkind
					components = {
						kind_icon = { -- for lspkind
							text = function(ctx)
								return " " .. ctx.kind_icon .. ctx.icon_gap .. " "
							end,
						},
						-- kind_icon = { -- for mini.icons
						-- 	text = function(ctx)
						-- 		local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
						-- 		return kind_icon
						-- 	end,
						-- 	-- (optional) use highlights from mini.icons
						-- 	highlight = function(ctx)
						-- 		local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
						-- 		return hl
						-- 	end,
						-- },
						-- kind = { -- for mini.icons
						-- 	-- (optional) use highlights from mini.icons
						-- 	highlight = function(ctx)
						-- 		local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
						-- 		return hl
						-- 	end,
						-- },
					},
					treesitter = { "lsp" },
					columns = {
						{ "label", "label_description", gap = 1 },
						{ "kind_icon", "kind" },
					},
				},
			},
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 200,
			},
			ghost_text = {
				enabled = vim.g.ai_cmp,
			},
		},

		-- Default list of enabled providers defined so that you can extend it
		-- elsewhere in your config, without redefining it, due to `opts_extend`
		sources = {
			-- adding any nvim-cmp sources here will enable them
			-- with blink.compat
			default = { "lsp", "path", "snippets", "buffer", "ripgrep" },
			per_filetype = {
				sql = { "dadbod" },
				-- optionally inherit from the `default` sources
				-- lua = { inherit_defaults = true, "lazydev" },
			},
			providers = {
				dadbod = { module = "vim_dadbod_completion.blink" },
				ripgrep = {
					module = "blink-ripgrep",
					name = "Ripgrep",
					-- see the full configuration below for all available options
					---@module "blink-ripgrep"
					---@type blink-ripgrep.Options
					opts = {
						backend = {
							-- The backend to use for searching. Defaults to "ripgrep".
							-- Available options:
							-- - "ripgrep", always use ripgrep
							-- - "gitgrep", always use git grep
							-- - "gitgrep-or-ripgrep", use git grep if possible, otherwise
							--   use ripgrep. Uses the same options as the gitgrep backend
							use = "gitgrep-or-ripgrep",

							-- Whether to set up custom highlight-groups for the icons used
							-- in the completion items. Defaults to `true`, which means this
							-- is enabled.
							customize_icon_highlight = true,

							ripgrep = {
								-- For many options, see `rg --help` for an exact description of
								-- the values that ripgrep expects.

								-- The number of lines to show around each match in the preview
								-- (documentation) window. For example, 5 means to show 5 lines
								-- before, then the match, and another 5 lines after the match.
								context_size = 5,

								-- The maximum file size of a file that ripgrep should include
								-- in its search. Useful when your project contains large files
								-- that might cause performance issues.
								-- Examples:
								-- "1024" (bytes by default), "200K", "1M", "1G", which will
								-- exclude files larger than that size.
								max_filesize = "1M",

								-- Enable fallback to neovim cwd if project_root_marker is not
								-- found. Default: `true`, which means to use the cwd.
								project_root_fallback = true,

								-- The casing to use for the search in a format that ripgrep
								-- accepts. Defaults to "--ignore-case". See `rg --help` for
								-- all the available options ripgrep supports, but you can try
								-- "--case-sensitive" or "--smart-case".
								search_casing = "--ignore-case",

								-- (advanced) Any additional options you want to give to
								-- ripgrep. See `rg -h` for a list of all available options.
								-- Might be helpful in adjusting performance in specific
								-- situations. If you have an idea for a default, please open
								-- an issue!
								--
								-- Not everything will work (obviously).
								additional_rg_options = {},

								-- Absolute root paths where the rg command will not be
								-- executed. Usually you want to exclude paths using gitignore
								-- files or ripgrep specific ignore files, but this can be used
								-- to only ignore the paths in blink-ripgrep.nvim, maintaining
								-- the ability to use ripgrep for those paths on the command
								-- line. If you need to find out where the searches are
								-- executed, enable `debug` and look at `:messages`.
								ignore_paths = {},

								-- Any additional paths to search in, in addition to the
								-- project root. This can be useful if you want to include
								-- dictionary files (/usr/share/dict/words), framework
								-- documentation, or any other reference material that is not
								-- available within the project root.
								additional_paths = {},
							},
						},
					},
				},
			},
		},
		-- Experimental signature help support
		signature = { enabled = true },
	},
	opts_extend = {
		"sources.completion.enabled_providers",
		"sources.compat",
		"sources.default",
	},
	config = function(_, opts)
		require("blink.cmp").setup(opts)
	end,
}
