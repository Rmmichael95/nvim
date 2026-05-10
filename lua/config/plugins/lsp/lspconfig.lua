return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"saghen/blink.cmp",
			"williamboman/mason.nvim",
			"folke/lazydev.nvim",
			"echasnovski/mini.icons",
			"p00f/clangd_extensions.nvim",
			"Issafalcon/neotest-dotnet",
			"R-nvim/R.nvim",
			"shunsambongi/neotest-testthat",
			"Nsidorenco/neotest-vstest",
			{ "antosha417/nvim-lsp-file-operations", config = true },
		},
		opts = {
			-- options for vim.diagnostic.config()
			---@type vim.diagnostic.Opts
			diagnostics = {
				underline = true,
				update_in_insert = false,
				virtual_text = {
					spacing = 4,
					source = "if_many",
					prefix = "icons",
					-- this will set set the prefix to a function that returns the diagnostics icon based on the severity
					-- this only works on a recent 0.10.0 build. Will be set to "●" when not supported
					-- prefix = "icons",
				},
				severity_sort = true,
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = " ",
						[vim.diagnostic.severity.WARN] = " ",
						[vim.diagnostic.severity.HINT] = "󰠠 ",
						[vim.diagnostic.severity.INFO] = " ",
					},
				},
			},
			-- Enable lsp cursor word highlighting
			document_highlight = {
				enabled = true,
			},
			servers = {
				clangd = {
					init_options = {
						usePlaceholders = true,
						completeUnimported = true,
						clangdFileStatus = true,
					},
					cmd = {
						"clangd",
						"--background-index",
						"--clang-tidy",
						"--header-insertion=iwyu",
						"--completion-style=detailed",
						"--function-arg-placeholders",
						"--fallback-style=llvm",
					},
				},
			},
		},
		config = function(_, opts)
			-- diagnostics signs
			if vim.fn.has("nvim-0.10.0") == 0 then
				if type(opts.diagnostics.signs) ~= "boolean" then
					for severity, icon in pairs(opts.diagnostics.signs.text) do
						local name = vim.diagnostic.severity[severity]:lower():gsub("^%l", string.upper)
						name = "DiagnosticSign" .. name
						vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
					end
				end
			end

			if type(opts.diagnostics.virtual_text) == "table" and opts.diagnostics.virtual_text.prefix == "icons" then
				opts.diagnostics.virtual_text.prefix = vim.fn.has("nvim-0.10.0") == 0 and "●"
					or function(diagnostic)
						local icons = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
						for d, icon in pairs(icons) do
							if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
								return icon
							end
						end
					end
			end

			local on_attach = function(_, bufnr)
				local function opts(desc)
					return { buffer = bufnr, desc = "LSP " .. desc }
				end
			end

			vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities.textDocument.completion.completionItem.snippetSupport = true
			capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)

			vim.lsp.enable("bashls")
			vim.lsp.config("bashls", {
				capabilities = capabilities,
			})
			vim.lsp.enable("clangd")
			vim.lsp.config("clangd", {
				capabilities = capabilities,
				cmd = {
					"clangd",
					"--background-index",
					"--clang-tidy",
					"--header-insertion=iwyu",
					"--completion-style=detailed",
					"--function-arg-placeholders=1",
					"--fallback-style=llvm",
				},
				init_options = {
					usePlaceholders = true,
					completeUnimported = true,
					clangdFileStatus = true,
				},
				require("clangd_extensions").setup({
					ast = {
						-- These are unicode, should be available in any font
						role_icons = {
							type = "",
							declaration = "",
							expression = "",
							specifier = "",
							statement = "",
							["template argument"] = "",
						},
						kind_icons = {
							Compound = "",
							Recovery = "",
							TranslationUnit = "",
							PackExpansion = "",
							TemplateTypeParm = "",
							TemplateTemplateParm = "",
							TemplateParamObject = "",
						},
					},
				}),
			})
			vim.lsp.enable("cssls")
			vim.lsp.config("cssls", {
				capabilities = capabilities,
				filetypes = { "css", "scss", "less" },
				settings = {
					scss = { validate = true },
					css = { validate = true },
					less = { validate = true },
				},
			})
			-- configure emmet language server
			-- vim.lsp.enable("emmet_ls")
			vim.lsp.config("emmet_ls", {
				capabilities = capabilities,
				filetypes = {
					"html",
					"typescriptreact",
					"javascriptreact",
					"css",
					"sass",
					"scss",
					"less",
					"svelte",
				},
				init_options = {
					html = {
						options = {
							-- For possible options, see: https://github.com/emmetio/emmet/blob/master/src/config.ts#L79-L267
							["bem.enabled"] = true,
						},
					},
				},
			})
			vim.lsp.enable("emmet-language-server")
			vim.lsp.config("emmet-language-server", {
				capabilities = capabilities,
			})

			vim.lsp.enable("tailwindcss")
			vim.lsp.config("tailwindcss", {
				capabilities = capabilities,
				filetypes = {
					"html",
					"css",
					"scss",
					"less",
					"javascript",
					"javascriptreact",
					"javascript.jsx",
					"typescript",
					"typescriptreact",
					"typescript.tsx",
					"svelte",
					"vue",
					"astro",
					"php",
				},
				settings = {
					tailwindCSS = {
						-- Teach tailwind to understand jsx className values
						includeLanguages = {
							typescript = "javascript",
							typescriptreact = "javascript",
							javascriptreact = "javascript",
						},
						-- Detect tailwind classes inside utility functions (cva, cn, clsx, etc.)
						experimental = {
							classRegex = {
								{ "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
								{ "cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
								{ "cn\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
								{ "clsx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
								{ "twMerge\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
								"class:([\\w\\d\\-/:]+)",
							},
						},
						validate = true,
					},
				},
			})
			vim.lsp.enable("perlnavigator")
			vim.lsp.config("wasm_language_tools", {
				capabilities = capabilities,
			})
			vim.lsp.enable("wasm_language_tools")
			vim.lsp.config("systemd_ls", {
				capabilities = capabilities,
			})
			-- configure graphql language server
			-- vim.lsp.enable("graphql")
			vim.lsp.config("graphql", {
				capabilities = capabilities,
				filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
			})
			vim.lsp.enable("html")
			vim.lsp.config("html", {
				capabilities = capabilities,
				filetypes = { "html", "templ", "php" },
			})
			vim.lsp.enable("jsonls")
			vim.lsp.config("jsonls", {
				capabilities = capabilities,
				-- lazy-load schemastore when needed
				-- on_new_config = function(new_config)
				-- 	new_config.settings.json.schemas = new_config.settings.json.schemas or {}
				-- 	vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
				-- end,
				settings = {
					json = {
						format = {
							enable = true,
						},
						validate = { enable = true },
					},
				},
			})
			vim.lsp.enable("ltex")
			vim.lsp.config("ltex", {
				capabilities = capabilities,
			})
			--vim.lsp.enable("phpactor")
			vim.lsp.config("phpactor", {
				capabilities = capabilities,
			})
			vim.lsp.enable("pyright")
			vim.lsp.config("pyright", {
				capabilities = capabilities,
			})
			vim.lsp.enable("ruff")
			vim.lsp.config("ruff", {
				capabilities = capabilities,
				cmd_env = { RUFF_TRACE = "messages" },
				init_options = {
					settings = {
						logLevel = "error",
					},
				},
				on_attach(function(client, _)
					-- Disable hover in favor of Pyright
					client.server_capabilities.hoverProvider = false
				end),
			})
			vim.lsp.enable("r_language_server")
			vim.lsp.config("r_language_server", {
				capabilities = capabilities,
				root_dir = function(fname)
					return require("lspconfig.util").root_pattern("DESCRIPTION", "NAMESPACE", ".Rbuildignore")(fname)
						or require("lspconfig.util").find_git_ancestor(fname)
						or vim.loop.os_homedir()
				end,
			})
			vim.lsp.enable("rust_analyzer")
			vim.lsp.config("rust_analyzer", {
				capabilities = capabilities,
			})
			-- vim.lsp.enable("svelte")
			vim.lsp.config("svelte", {
				capabilities = capabilities,
			})
			vim.lsp.enable("texlab")
			vim.lsp.config("texlab", {
				capabilities = capabilities,
			})
			vim.lsp.enable("ts_ls")
			vim.lsp.config("ts_ls", {
				capabilities = capabilities,
				filetypes = {
					"javascript",
					"javascriptreact",
					"javascript.jsx",
					"typescript",
					"typescriptreact",
					"typescript.tsx",
				},
				settings = {
					typescript = {
						inlayHints = {
							includeInlayParameterNameHints = "all",
							includeInlayParameterNameHintsWhenArgumentMatchesName = false,
							includeInlayFunctionParameterTypeHints = true,
							includeInlayVariableTypeHints = true,
							includeInlayVariableTypeHintsWhenTypeMatchesName = false,
							includeInlayPropertyDeclarationTypeHints = true,
							includeInlayFunctionLikeReturnTypeHints = true,
							includeInlayEnumMemberValueHints = true,
						},
						preferences = {
							importModuleSpecifier = "relative",
						},
					},
					javascript = {
						inlayHints = {
							includeInlayParameterNameHints = "all",
							includeInlayParameterNameHintsWhenArgumentMatchesName = false,
							includeInlayFunctionParameterTypeHints = true,
							includeInlayVariableTypeHints = true,
							includeInlayPropertyDeclarationTypeHints = true,
							includeInlayFunctionLikeReturnTypeHints = true,
							includeInlayEnumMemberValueHints = true,
						},
					},
				},
			})
			vim.lsp.enable("vimls")
			vim.lsp.config("vimls", {
				capabilities = capabilities,
			})
			vim.lsp.enable("yamlls")
			vim.lsp.config("yamlls", {
				capabilities = capabilities,
			})
			vim.lsp.enable("zls")
			vim.lsp.config("zls", {
				capabilities = capabilities,
			})
			-- configure lua server (with special settings)
			vim.lsp.enable("lua_ls")
			vim.lsp.config("lua_ls", {
				capabilities = capabilities,
				settings = {
					Lua = {
						-- make the language server recognize "vim" global
						diagnostics = {
							globals = { "vim" },
						},
						completion = {
							callSnippet = "Replace",
						},
					},
				},
			})
			-- vim.lsp.enable("intelephense")
			vim.lsp.config("intelephense", {
				capabilities = capabilities,
				settings = {
					intelephense = {
						stubs = {
							"amqp",
							"apache",
							"apcu",
							"bcmath",
							"blackfire",
							"bz2",
							"calendar",
							"cassandra",
							"com_dotnet",
							"Core",
							"couchbase",
							"crypto",
							"ctype",
							"cubrid",
							"curl",
							"date",
							"dba",
							"decimal",
							"dom",
							"ds",
							"enchant",
							"Ev",
							"event",
							"exif",
							"fann",
							"FFI",
							"ffmpeg",
							"fileinfo",
							"filter",
							"fpm",
							"ftp",
							"gd",
							"gearman",
							"geoip",
							"geos",
							"gettext",
							"gmagick",
							"gmp",
							"gnupg",
							"grpc",
							"hash",
							"http",
							"ibm_db2",
							"iconv",
							"igbinary",
							"imagick",
							"imap",
							"inotify",
							"interbase",
							"intl",
							"json",
							"judy",
							"ldap",
							"leveldb",
							"libevent",
							"libsodium",
							"libxml",
							"lua",
							"lzf",
							"mailparse",
							"mapscript",
							"mbstring",
							"mcrypt",
							"memcache",
							"memcached",
							"meminfo",
							"meta",
							"ming",
							"mongo",
							"mongodb",
							"mosquitto-php",
							"mqseries",
							"msgpack",
							"mssql",
							"mysql",
							"mysql_xdevapi",
							"mysqli",
							"ncurses",
							"newrelic",
							"oauth",
							"oci8",
							"odbc",
							"openssl",
							"parallel",
							"Parle",
							"pcntl",
							"pcov",
							"pcre",
							"pdflib",
							"PDO",
							"pdo_ibm",
							"pdo_mysql",
							"pdo_pgsql",
							"pdo_sqlite",
							"pgsql",
							"Phar",
							"phpdbg",
							"posix",
							"pspell",
							"pthreads",
							"radius",
							"rar",
							"rdkafka",
							"readline",
							"recode",
							"redis",
							"Reflection",
							"regex",
							"rpminfo",
							"rrd",
							"SaxonC",
							"session",
							"shmop",
							"SimpleXML",
							"snmp",
							"soap",
							"sockets",
							"sodium",
							"solr",
							"SPL",
							"SplType",
							"SQLite",
							"sqlite3",
							"sqlsrv",
							"ssh2",
							"standard",
							"stats",
							"stomp",
							"suhosin",
							"superglobals",
							"svn",
							"sybase",
							"sync",
							"sysvmsg",
							"sysvsem",
							"sysvshm",
							"tidy",
							"tokenizer",
							"uopz",
							"uv",
							"v8js",
							"wddx",
							"win32service",
							"winbinder",
							"wincache",
							"xcache",
							"xdebug",
							"xhprof",
							"xml",
							"xmlreader",
							"xmlrpc",
							"xmlwriter",
							"xsl",
							"xxtea",
							"yaf",
							"yaml",
							"yar",
							"zend",
							"Zend OPcache",
							"ZendCache",
							"ZendDebugger",
							"ZendUtils",
							"zip",
							"zlib",
							"zmq",
							"zookeeper",
							"wordpress",
							"woocommerce",
							"acf-pro",
							"wordpress-globals",
							"wp-cli",
							"genesis",
							"polylang",
						},
						environment = {
							includePaths = {
								"~/.config/composer/vendor/php-stubs/",
								"~/.config/composer/vendor/wpsyntex/",
							}, -- this line forces the composer path for the stubs in case inteliphense can't find it...
							-- root_dir = vim.loop.cwd,
						},
						files = {
							maxSize = 5000000,
						},
					},
				},
			})

			local keymap = vim.keymap -- for conciseness

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					local opts = { buffer = ev.buf, silent = true }
					local client = vim.lsp.get_client_by_id(ev.data.client_id)

					-- existing keymaps stay as-is...
					keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)

					-- capability-gated keymaps (ADD these)
					if client and client:supports_method("textDocument/rename") then
						keymap.set(
							"n",
							"<leader>rn",
							vim.lsp.buf.rename,
							vim.tbl_extend("force", opts, { desc = "Smart rename" })
						)
					end
					if client and client:supports_method("textDocument/codeAction") then
						keymap.set(
							{ "n", "v" },
							"<leader>ca",
							vim.lsp.buf.code_action,
							vim.tbl_extend("force", opts, { desc = "Code actions" })
						)
					end

					-- ADD: inlay hints (works for both Roslyn and ts_ls)
					if client and client:supports_method("textDocument/inlayHint") then
						vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
					end

					-- ADD: code lenses (Roslyn shows reference/impl counts inline)
					if client and client:supports_method("textDocument/codeLens") then
						vim.lsp.codelens.enable(true, { bufnr = ev.buf })
					end

					-- ADD: toggle inlay hints keymap
					keymap.set("n", "<leader>uh", function()
						vim.lsp.inlay_hint.enable(
							not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }),
							{ bufnr = ev.buf }
						)
					end, vim.tbl_extend("force", opts, { desc = "Toggle inlay hints" }))

					-- ADD: run code lens keymap
					keymap.set(
						"n",
						"<leader>cc",
						vim.lsp.codelens.run,
						vim.tbl_extend("force", opts, { desc = "Run codelens" })
					)
				end,
			})
		end,
	},
	{
		"R-nvim/R.nvim",
		lazy = false,
		opts = {
			-- Create a table with the options to be passed to setup()
			R_args = { "--quiet", "--no-save" },
			hook = {
				on_filetype = function()
					-- This function will be called at the FileType event
					-- of files supported by R.nvim. This is an
					-- opportunity to create mappings local to buffers.
					vim.keymap.set("n", "<Enter>", "<Plug>RDSendLine", { buffer = true })
					vim.keymap.set("v", "<Enter>", "<Plug>RSendSelection", { buffer = true })

					local wk = require("which-key")
					wk.add({
						buffer = true,
						mode = { "n", "v" },
						{ "<localleader>a", group = "all" },
						{ "<localleader>b", group = "between marks" },
						{ "<localleader>c", group = "chunks" },
						{ "<localleader>f", group = "functions" },
						{ "<localleader>g", group = "goto" },
						{ "<localleader>i", group = "install" },
						{ "<localleader>k", group = "knit" },
						{ "<localleader>p", group = "paragraph" },
						{ "<localleader>q", group = "quarto" },
						{ "<localleader>r", group = "r general" },
						{ "<localleader>s", group = "split or send" },
						{ "<localleader>t", group = "terminal" },
						{ "<localleader>v", group = "view" },
					})
				end,
			},
			pdfviewer = "",
		},
		config = function(_, opts)
			vim.g.rout_follow_colorscheme = true
			require("r").setup(opts)
			require("r.pdf.generic").open = vim.ui.open
		end,
	},
	{
		"nvim-neotest/neotest",
		optional = true,
		dependencies = {
			"shunsambongi/neotest-testthat",
		},
		opts = {
			adapters = {
				["neotest-testthat"] = {},
			},
		},
	},
}
