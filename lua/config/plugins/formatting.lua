return {
	"stevearc/conform.nvim",
	lazy = true,
	cmd = "ConformInfo",
	event = { "BufWritePost", "InsertLeave" },
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
					command = "/home/ryanm/.config/composer/vendor/bin/phpcbf",
					args = { "-q", "--standard=WordPress", "--report-json", "$FILENAME" },
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
				["markdownlint-cli2"] = {
					condition = function(_, ctx)
						local diag = vim.tbl_filter(function(d)
							return d.source == "markdownlint"
						end, vim.diagnostic.get(ctx.buf))
						return #diag > 0
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
				markdown = { "prettier", "markdownlint-cli2", "markdown-toc" },
				["markdown.mdx"] = { "prettier", "markdownlint-cli2", "markdown-toc" },
				graphql = { "prettier" },
				liquid = { "prettier" },
				tex = { "latexindent" },
				lua = { "stylua" },
				python = { "isort", "black" },
				sh = { "shfmt" },
				["*"] = { "codespell" },
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
