return {
	"stevearc/conform.nvim",
	lazy = true,
	cmd = "ConformInfo",
	event = { "BufWritePre" },
	dependencies = {
		"williamboman/mason.nvim",
	},
	keys = {
		{
			"<leader>mp",
			function()
				require("conform").format({
					lsp_fallback = true,
					async = false,
					timeout_ms = 1000,
				})
			end,
			desc = "Format file or range (in visual mode)",
		},
	},
	config = function()
		require("conform").setup({
			formatters = {
				phpcbf = {
					-- command = "phpcbf",
					-- command = vim.fn.stdpath("data") .. "/mason/bin/phpcbf",
					--command = vim.fn.getcwd() .. "/vendor/bin/phpcbf",
					command = "~/.config/composer/vendor/bin/phpcbf",
					args = { "-q", "--standard=WordPress", "--report-json", "$FILENAME" },
				},
				prettier_md = {
					command = "prettier",
					args = { "--prose-wrap", "preserve", "--parser", "markdown" },
					stdin = true,
				},
				prettier_mdx = {
					command = "prettier",
					args = { "--prose-wrap", "preserve", "--parser", "mdx" },
					stdin = true,
				},
				-- mdsf: formats code blocks embedded inside markdown using their
				-- own language formatters (prettier for js/ts, stylua for lua, etc.)
				-- Requires: cargo install mdsf
				-- Config:   mdsf.json at repo root or ~/.config/mdsf/mdsf.json
				mdsf = {
					command = "mdsf",
					args = { "format", "--stdin" },
					stdin = true,
				},
				["markdown-toc"] = {
					condition = function(_, ctx)
						for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
							if line:find("<!%-%- toc %-%->") then
								return true
							end
						end
					end,
				},
				csharpier = {
					command = "csharpier",
				},
				codespell = {
					command = vim.fn.stdpath("data") .. "/mason/bin/codespell",
					args = { "--check-filenames", "--skip", "node_modules/.git" },
				},
			},
			formatters_by_ft = {
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				svelte = { "prettier" },
				c = { "clang-format" },
				cpp = { "clang-format" },
				css = { "prettier" },
				cs = { "csharpier" },
				php = { "phpcbf" },
				-- php = { "php_cs_fixer" },
				html = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier_md", "mdsf", "markdown-toc" },
				["markdown.mdx"] = { "prettier_mdx", "mdsf", "markdown-toc" },
				graphql = { "prettier" },
				liquid = { "prettier" },
				tex = { "latexindent" },
				lua = { "stylua" },
				python = { "isort", "black" },
				sh = { "shfmt" },
				["_"] = { "trim_whitespace" },
			},
			format_on_save = {
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			},
		})
	end,
}
