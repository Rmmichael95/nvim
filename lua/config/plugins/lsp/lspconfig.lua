return {
	"neovim/nvim-lspconfig",
	version = "1.32.0",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"saghen/blink.cmp",
		"williamboman/mason.nvim",
		"folke/lazydev.nvim",
		"echasnovski/mini.icons",
		"p00f/clangd_extensions.nvim",
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

		vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

		local capabilities = vim.lsp.protocol.make_client_capabilities()
		capabilities.textDocument.completion.completionItem.snippetSupport = true
		capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)

		-- configure svelte server
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
		})
		-- configure emmet language server
		vim.lsp.enable("emmet_ls")
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
		-- configure graphql language server
		vim.lsp.enable("graphql")
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
		})
		vim.lsp.enable("ltex")
		vim.lsp.config("ltex", {
			capabilities = capabilities,
		})
		vim.lsp.enable("phpactor")
		vim.lsp.config("phpactor", {
			capabilities = capabilities,
		})
		vim.lsp.enable("pyright")
		vim.lsp.config("pyright", {
			capabilities = capabilities,
		})
		vim.lsp.enable("r_language_server")
		vim.lsp.config("r_language_server", {
			capabilities = capabilities,
		})
		vim.lsp.enable("rust_analyzer")
		vim.lsp.config("rust_analyzer", {
			capabilities = capabilities,
		})
		vim.lsp.enable("svelte")
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
							"/home/ryanm/.config/composer/vendor/php-stubs/",
							"/home/ryanm/.config/composer/vendor/wpsyntex/",
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
				-- Buffer local mappings.
				-- See `:help vim.lsp.*` for documentation on any of the below functions
				local opts = { buffer = ev.buf, silent = true }

				-- set keybinds
				vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)

				vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, bufopts)

				opts.desc = "See available code actions"
				keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

				opts.desc = "Smart rename"
				keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

				opts.desc = "Show line diagnostics"
				keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

				opts.desc = "Show documentation for what is under cursor"
				keymap.set("n", "H", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

				opts.desc = "Restart LSP"
				keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
			end,
		})
	end,
}
