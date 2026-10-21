-- after/ftplugin/cs.lua
-- Buffer-local environment for C# files.
--
-- Coordinates with:
--   roslyn.nvim        (LSP — completions, inlay hints, code lens)
--   conform.nvim       (csharpier formats on save)
--   nvim-dap           (netcoredbg debugger)
--   neotest-vstest     (xUnit/NUnit/MSTest runner)
--   overseer.nvim      (dotnet-build / dotnet-watch tasks)
--   nvim-treesitter    (c_sharp + razor parsers)
--   luasnip            (lua/snippets/cshape.lua)

-- ── Indentation (.NET standard: 4 spaces, no tabs) ───────────────────────────
vim.bo.tabstop = 4
vim.bo.softtabstop = 4
vim.bo.shiftwidth = 4
vim.bo.expandtab = true

-- ── Line length ───────────────────────────────────────────────────────────────
-- csharpier enforces its own line length (default 120); textwidth=0 prevents
-- Neovim from hard-wrapping mid-type and fighting the formatter on save.
vim.bo.textwidth = 0

-- ── Comment style ─────────────────────────────────────────────────────────────
-- gcc / gc motions use this. C# uses // for line comments.
vim.bo.commentstring = "// %s"

-- ── Format options ────────────────────────────────────────────────────────────
-- 'r'  — insert comment leader on <Enter> in insert mode
-- 'q'  — allow gq to format comments
-- 'j'  — remove comment leader when joining lines with J
-- No 'c' or 't' — csharpier handles wrapping, not Neovim
vim.bo.formatoptions = "rqj"

-- Prevent gq from hard-wrapping; csharpier on save is the formatter.
vim.bo.formatexpr = ""

-- ── Folding ───────────────────────────────────────────────────────────────────
-- Treesitter folds are set globally in treesitter.lua. C# benefits from them
-- (class bodies, method bodies, #region blocks). No override needed unless you
-- want to start with all folds open:
vim.wo.foldenable = false -- start unfolded; toggle with zi

-- ── Spell checking ────────────────────────────────────────────────────────────
-- Off for code files; codespell via conform/lint handles typos in strings.
vim.wo.spell = false

-- ── Auto Indentation ────────────────────────────────────────────────────────────
-- Treesitter's indent query is thin/unreliable for c_sharp — override the
-- global treesitter indentexpr (set in treesitter.lua) with Vim's built-in
-- C-style indent engine, which handles C#'s brace/case syntax correctly.
vim.bo.indentexpr = ""
vim.bo.cindent = true

-- ── Buffer-local keymaps ─────────────────────────────────────────────────────
local map = function(lhs, rhs, desc)
	vim.keymap.set("n", lhs, rhs, { buffer = true, silent = true, desc = desc })
end

-- Quick access to dotnet tasks without leaving the buffer
map("<leader>mb", "<Cmd>OverseerRun dotnet-build<CR>", "dotnet build")
map("<leader>mw", "<Cmd>OverseerRun dotnet-watch<CR>", "dotnet watch (pick subcommand)")
--map("<leader>mt", "<Cmd>OverseerRun dotnet-watch test<CR>", "dotnet watch test")
map("<leader>mt", function()
	require("overseer").run_task({ name = "dotnet-watch", params = { subcommand = "test" } })
end, "dotnet watch test")

-- Inlay hints toggle (Roslyn provides these; can be noisy in crowded files)
map("<leader>uh", function()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
end, "Toggle inlay hints")
