-- Filename: filetype.lua
-- ~/.config/nvim/lua/config/core/filetype.lua  (required from init.lua)
--
-- Only declare what Neovim doesn't already know.
-- Order of resolution:  extension → filename → pattern
--
-- Ref: https://github.com/neovim/neovim/pull/16600

vim.filetype.add({

	-- ── Custom / non-default extensions ─────────────────────────────────────
	extension = {
		-- audio / video / image  ─ custom sentinels so ftplugins can handle them
		mp3 = "audio",
		flac = "audio",
		wav = "audio",
		ogg = "audio",
		opus = "audio",
		avi = "video",
		wmv = "video",
		flv = "video",
		mp4 = "video",
		mkv = "video",
		mov = "video",
		mpg = "video",
		png = "image",
		jpg = "image",
		jpeg = "image",

		-- shell dialects  (Neovim maps .sh→sh, but not zsh/bash/fish explicitly)
		zsh = "zsh",
		bash = "bash",
		fish = "fish",

		-- config catch-all for dotfiles that use .conf / .pbrt
		conf = "config",
		pbrt = "config",

		-- Wolfram Language
		wl = "mma",
		wls = "mma",

		-- SCSS/Sass: compound filetype so both scss and css ftplugins fire
		scss = "scss.css",
		sass = "scss.css",

		-- mmark is a variant of markdown not detected by default
		mmark = "markdown",

		-- ── Smart C/C++ header detection ─────────────────────────────────────
		-- .h with STL-style #include <...> → cpp; otherwise → c
		h = function(path, bufnr)
			if vim.fn.search("\\C^#include <[^>.][^>]*>$", "nw") ~= 0 then
				return "cpp"
			end
			return "c"
		end,

		-- NOTE: the following are intentionally omitted because Neovim detects
		-- them natively and overriding them here just adds maintenance burden:
		--   lua, py, rs, c, cpp, html, js, ts, tsx, jsx, cs, vim, hs, pl,
		--   r, sql, erl, diff, patch, rej, md, sh, zig
	},

	-- ── Exact filename / path → filetype ─────────────────────────────────────
	-- Keys here are matched as Lua patterns against the full absolute path.
	-- Use literal strings for exact paths; use anchors (^/$) for patterns.
	filename = {
		[".git/config"] = "gitconfig",
		["TODO"] = "markdown",

		-- Zsh config files under ~/.config/zsh/
		["~/.config/zsh/.zshrc"] = "zsh",
		["~/.config/zsh/.zshenv"] = "zsh",
		["~/.config/zsh/.zprofile"] = "zsh",
		["~/.config/zsh/.zlogin"] = "zsh",
		["~/.local/state/zsh/history"] = "zsh",

		-- ~/.zshrc (legacy path) → plain sh
		["~/.zshrc"] = "sh",

		-- mutt config
		["~/.config/mutt/muttrc"] = "muttrc",

		-- README with no extension: check first line for '#' (markdown heading)
		-- FIX: string.find(s, pattern) — args were reversed in previous version
		["README$"] = function(path, bufnr)
			local first = vim.api.nvim_buf_get_lines(bufnr, 0, 1, true)[1] or ""
			if first:find("^#") then
				return "markdown"
			end
			-- returning nil lets Neovim try the next method
		end,
	},

	-- ── Path patterns → filetype ──────────────────────────────────────────────
	-- Keys are Lua patterns matched against the full absolute path.
	-- Note: '*' in Lua is a quantifier (zero-or-more), NOT a shell glob.
	-- Use '.*' for "any chars", '%.' for a literal dot.
	pattern = {
		-- dotfiles: .zshrc, .zshenv (when NOT under ~/.config/zsh/)
		-- filename table handles the canonical XDG path; this catches the rest
		["^%.zsh%(rc|env%)?$"] = "sh",

		-- neomutt temp buffers  (was ["*mutt-*"] — that was a glob, not a pattern)
		[".*/mutt%-.*"] = "mail",

		-- calcurse notes
		["/tmp/calcurse/notes.*"] = "markdown",
		[vim.env.HOME .. "/calcurse.*"] = "markdown",

		-- .md.html preview files
		[".*%.md%.html$"] = "markdown",

		-- nameless buffers (e.g. :enew) fall back to text
		["^$"] = "text",
	},
})
