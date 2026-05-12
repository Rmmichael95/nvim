-- lua/config/plugins/lsp/lang/php.lua
local lsp = require("config.util")

lsp.setup("intelephense", {
	settings = {
		intelephense = {
			stubs = {
				-- Core PHP (Linux/web relevant only)
				"apache",
				"bcmath",
				"calendar",
				"Core",
				"ctype",
				"curl",
				"date",
				"dom",
				"ds",
				"exif",
				"FFI",
				"fileinfo",
				"filter",
				"fpm",
				"ftp",
				"gd",
				"gettext",
				"gmagick",
				"gmp",
				"gnupg",
				"hash",
				"http",
				"iconv",
				"imagick",
				"imap",
				"igbinary",
				"intl",
				"json",
				"ldap",
				"libxml",
				"mailparse",
				"mbstring",
				"memcache",
				"memcached",
				"meta",
				"msgpack",
				"mysqli",
				"oauth",
				"openssl",
				"pcntl",
				"pcre",
				"PDO",
				"pdo_mysql",
				"pdo_pgsql",
				"pdo_sqlite",
				"pgsql",
				"Phar",
				"posix",
				"rdkafka",
				"redis",
				"Reflection",
				"regex",
				"session",
				"SimpleXML",
				"soap",
				"sockets",
				"sodium",
				"solr",
				"SPL",
				"sqlite3",
				"ssh2",
				"standard",
				"tidy",
				"tokenizer",
				"xhprof",
				"xml",
				"xmlreader",
				"xmlwriter",
				"xsl",
				"yaml",
				"zip",
				"zlib",
				-- WordPress ecosystem
				"wordpress",
				"woocommerce",
				"acf-pro",
				"wordpress-globals",
				"wp-cli",
				"genesis",
				"polylang",
				"xdebug",
				"Zend OPcache",
			},
			environment = {
				includePaths = {
					"~/.config/composer/vendor/php-stubs/",
					"~/.config/composer/vendor/wpsyntex/",
				},
			},
			diagnostics = {
				undefinedSymbols = false, -- WP hooks register symbols dynamically
				undefinedFunctions = false, -- do_action, apply_filters callbacks
				undefinedConstants = false, -- WP_DEBUG, ABSPATH, etc.
				undefinedClassConstants = false,
				undefinedTypes = false,
				undefinedVariables = true, -- keep this one
				unusedSymbols = false, -- WP often passes args you don't use
			},
			completion = {
				insertUseDeclaration = true,
				fullyQualifyGlobalConstantsAndFunctions = false,
				triggerParameterHints = true,
				maxItems = 100,
			},
			format = {
				braces = "Allman", -- WP coding standard uses Allman brace style
			},
			files = { maxSize = 8000000 },
		},
	},
})

-- In php.lua, ADD:
lsp.setup("phpactor", {
	filetypes = { "php" },
	handlers = {
		["workspace/configuration"] = function()
			return {}
		end,
	},
	init_options = {
		["language_server_phpstan.enabled"] = false,
		["language_server_psalm.enabled"] = false,
	},
})
