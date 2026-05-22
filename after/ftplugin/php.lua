-- after/ftplugin/php.lua
-- Buffer-local environment for PHP files.
--
-- Coordinates with:
--   intelephense / phpactor  (LSP — completions, refactoring, WP stubs)
--   phpcs / phpcbf           (WPCS lint + format via conform)
--   nvim-ts-context-commentstring + mixed_comment  (per-line PHP/HTML commenting)
--   luasnip                  (lua/snippets/php.lua)

-- ── Indentation (WordPress Coding Standards: tabs, displayed as 4 cols) ──────
vim.bo.tabstop = 4
vim.bo.softtabstop = 4
vim.bo.shiftwidth = 4
vim.bo.expandtab = false -- WP standard: hard tabs, not spaces

-- ── Per-line context-aware commenting for mixed PHP / HTML ───────────────────
--
-- Why: mini.comment's custom_commentstring hook is called ONCE per gc/gcc
-- invocation (at the cursor's position), then that single commentstring is
-- applied to every line in the selection.  When a visual block spans both a
-- PHP region (needs  // comment ) and an HTML region (needs <!-- comment -->),
-- every line ends up with the wrong style.
--
-- mixed_comment fixes this by calling ts_context_commentstring individually
-- for each line in the selection, so the correct markers are used per-line.
-- The buffer-local gc / gcc mappings installed here shadow mini.comment's
-- global ones for PHP buffers only — all other filetypes are unaffected.
require("config.core.lib.mixed_comment").setup_buf_keymaps()
