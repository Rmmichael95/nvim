-- lua/config/plugins/markdown.lua
return {
	-- ─────────────────────────────────────────────────────────────────────────
	-- render-markdown.nvim  —  rich in-buffer rendering
	-- ─────────────────────────────────────────────────────────────────────────
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown", "norg", "rmd", "org", "codecompanion", "Avante" },
		opts = {
			-- ── Code blocks ─────────────────────────────────────────────────
			code = {
				sign = false,
				width = "block",
				right_pad = 1,
			},

			-- ── Headings ────────────────────────────────────────────────────
			heading = {
				sign = false,
				-- render a left-side icon per heading level; empty = use default icons
				-- swap for {} to remove them entirely
				icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
				-- full-width background highlight per level
				width = "full",
			},

			-- ── Checkboxes / task lists ─────────────────────────────────────
			checkbox = {
				enabled = true,
				unchecked = { icon = "󰄱 " },
				checked = { icon = "󰱒 " },
				-- custom states: [ ] [~] [x] [-]
				custom = {
					in_progress = { raw = "[~]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
					cancelled = { raw = "[-]", rendered = "󰅙 ", highlight = "RenderMarkdownError" },
				},
			},

			-- ── Tables ──────────────────────────────────────────────────────
			pipe_table = {
				enabled = true,
				style = "full", -- "full" draws box-drawing chars for the whole table
				cell = "trimmed",
			},

			-- ── Callouts (> [!NOTE], > [!TIP], etc.) ────────────────────────
			-- These are the Obsidian-style callout blocks
			callout = {
				note = { raw = "[!NOTE]", rendered = "󰋽 Note", highlight = "RenderMarkdownInfo" },
				tip = { raw = "[!TIP]", rendered = "󰌶 Tip", highlight = "RenderMarkdownSuccess" },
				important = { raw = "[!IMPORTANT]", rendered = "󰅾 Important", highlight = "RenderMarkdownHint" },
				warning = { raw = "[!WARNING]", rendered = "󰀪 Warning", highlight = "RenderMarkdownWarn" },
				caution = { raw = "[!CAUTION]", rendered = "󰳦 Caution", highlight = "RenderMarkdownError" },
				-- Extras often used in GitHub docs
				abstract = { raw = "[!ABSTRACT]", rendered = "󰨸 Abstract", highlight = "RenderMarkdownInfo" },
				todo = { raw = "[!TODO]", rendered = "󰗡 Todo", highlight = "RenderMarkdownTodo" },
				question = { raw = "[!QUESTION]", rendered = "󰘥 Question", highlight = "RenderMarkdownWarn" },
			},

			-- ── Horizontal rules ─────────────────────────────────────────────
			dash = { enabled = true, icon = "─", width = "full" },

			-- ── Bullet lists ─────────────────────────────────────────────────
			bullet = {
				enabled = true,
				icons = { "●", "○", "◆", "◇" },
			},

			-- ── Inline code ──────────────────────────────────────────────────
			inline_highlight = { enabled = true },

			-- ── Front-matter (YAML/TOML between --- delimiters) ──────────────
			-- hides the raw --- and renders it as a subtle block
			-- renders on ft=markdown if the first line is ---
		},
		config = function(_, opts)
			require("render-markdown").setup(opts)

			-- Snacks toggle: <leader>um  (already exists, keep it)
			Snacks.toggle({
				name = "Render Markdown",
				get = function()
					return require("render-markdown.state").enabled
				end,
				set = function(enabled)
					local m = require("render-markdown")
					if enabled then
						m.enable()
					else
						m.disable()
					end
				end,
			}):map("<leader>um")
		end,
	},

	-- ─────────────────────────────────────────────────────────────────────────
	-- Snacks extras specifically for markdown buffers
	-- ─────────────────────────────────────────────────────────────────────────
	{
		-- Attach heading-aware keymaps when entering a markdown buffer
		"folke/snacks.nvim",
		optional = true,
		keys = {
			-- ── Outline / heading picker ─────────────────────────────────────
			-- Jump to any heading in the current markdown file
			{
				"<leader>mh",
				function()
					Snacks.picker.treesitter({
						filter = { kind = { "heading" } },
					})
				end,
				ft = "markdown",
				desc = "Markdown headings (outline)",
			},

			-- ── Quick markdown scratch ───────────────────────────────────────
			-- Opens a persistent scratch buffer (saved across sessions) for
			-- markdown notes — great for quick jots without leaving Neovim
			{
				"<leader>ms",
				function()
					Snacks.scratch({
						name = "markdown-scratch",
						ft = "markdown",
						icon = "󰎞 ",
						win = {
							width = 0.6,
							height = 0.7,
							border = "rounded",
							title = " Markdown Scratch",
							title_pos = "center",
							wo = {
								spell = true,
								wrap = true,
								conceallevel = 2,
							},
						},
					})
				end,
				desc = "Markdown scratch pad",
			},

			-- ── Search links in current buffer ───────────────────────────────
			-- Grep only link syntax [text](url) / [[wiki]] in current file
			{
				"<leader>ml",
				function()
					Snacks.picker.grep_buffers({
						search = "\\[.+\\]\\(.*\\)|\\[\\[.+\\]\\]",
						regex = true,
						ft = "markdown",
					})
				end,
				ft = "markdown",
				desc = "Markdown links in buffer",
			},

			-- ── Grep all markdown files in the Notes directory ───────────────
			-- (extends the existing 'nl keybinding in snacks.lua)
			{
				"<leader>mn",
				function()
					Snacks.picker.grep({
						cwd = "~/documents/.bc/batcave/Notes/",
						no_ignore = false,
						hidden = false,
						previewer = true,
					})
				end,
				desc = "Grep Notes directory",
			},
		},
	},
}
