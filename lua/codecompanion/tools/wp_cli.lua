-- ~/.config/nvim/lua/codecompanion/tools/wp_cli.lua

local uv = vim.uv or vim.loop

local function shell_quote(value)
	value = tostring(value or "")
	return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function path_exists(path)
	return path and uv.fs_stat(path) ~= nil
end

local function is_wp_root(path)
	return path
		and path_exists(path .. "/wp-config.php")
		and path_exists(path .. "/wp-includes")
		and path_exists(path .. "/wp-admin")
end

local function dirname(path)
	if not path or path == "" then
		return nil
	end

	path = path:gsub("/+$", "")
	local parent = path:match("^(.*)/[^/]+$")

	if not parent or parent == "" or parent == path then
		return nil
	end

	return parent
end

local function find_wp_root_from(start)
	if not start or start == "" then
		return nil
	end

	local stat = uv.fs_stat(start)
	if stat and stat.type == "file" then
		start = dirname(start)
	end

	local dir = start

	while dir do
		if is_wp_root(dir) then
			return dir
		end

		-- If opened inside a theme/plugin dir, walk up past wp-content.
		if path_exists(dir .. "/wp-content") and path_exists(dir .. "/wp-includes") then
			return dir
		end

		local parent = dirname(dir)
		if not parent or parent == dir then
			break
		end

		dir = parent
	end

	return nil
end

local function detect_wp_root()
	-- 0. Explicit/global path remembered by Neovim config.
	local configured = vim.g.wp_cli_path or vim.env.WP_CLI_PATH

	if configured and configured ~= "" then
		local root = find_wp_root_from(configured)
		if root then
			return root
		end
	end

	-- 1. Current buffer file path.
	local bufname = vim.api.nvim_buf_get_name(0)
	local root = find_wp_root_from(bufname)
	if root then
		return root
	end

	-- 2. Current Neovim cwd.
	root = find_wp_root_from(vim.fn.getcwd())
	if root then
		return root
	end

	-- 3. Current file's directory via expand fallback.
	root = find_wp_root_from(vim.fn.expand("%:p:h"))
	if root then
		return root
	end

	return nil
end
local function wp_prefix()
	local root = detect_wp_root()

	if not root then
		return "printf '%s\n' 'ERROR: Could not detect WordPress root. Open Neovim inside the WordPress install, or set vim.g.wp_cli_path to the WP root.'"
	end

	return "WP_CLI_PHP_ARGS='-d display_errors=stderr -d error_reporting=E_ERROR' wp --path=" .. shell_quote(root)
end

local block_overrides_audit_php = [[
$stylesheet = get_stylesheet();
$template   = get_template();

$stylesheet_dir = get_stylesheet_directory();
$template_dir   = get_template_directory();

$theme = wp_get_theme($stylesheet);

// Block Bindings API (stable WP 6.7+, central to WP 7 interactivity model)
$bindings_registry  = function_exists("wp_block_bindings_registry") ? wp_block_bindings_registry() : null;
$registered_sources = $bindings_registry ? array_keys($bindings_registry->get_all_registered()) : null;

// Synced patterns (wp_block CPT)
$synced_counts = wp_count_posts("wp_block");
$synced_total  = isset($synced_counts->publish) ? (int) $synced_counts->publish : 0;

// REST API namespaces registered on this install
$rest_server     = rest_get_server();
$rest_namespaces = method_exists($rest_server, "get_namespaces") ? $rest_server->get_namespaces() : null;

$data = array(
	// ── Core ─────────────────────────────────────────────────────────────────
	"core_version" => get_bloginfo("version"),

	// ── Theme ─────────────────────────────────────────────────────────────────
	"theme_name"   => $theme->get("Name"),
	"stylesheet"   => $stylesheet,
	"template"     => $template,
	"is_child_theme" => $stylesheet !== $template,

	"child_theme_dir" => $stylesheet_dir,
	"parent_theme_dir" => $template_dir,

	"child_has_style_css"       => file_exists($stylesheet_dir . "/style.css"),
	"parent_has_style_css"      => file_exists($template_dir  . "/style.css"),
	"child_has_functions_php"   => file_exists($stylesheet_dir . "/functions.php"),
	"parent_has_functions_php"  => file_exists($template_dir  . "/functions.php"),
	"child_has_theme_json"      => file_exists($stylesheet_dir . "/theme.json"),
	"parent_has_theme_json"     => file_exists($template_dir  . "/theme.json"),
	"child_has_templates_dir"   => is_dir($stylesheet_dir . "/templates"),
	"parent_has_templates_dir"  => is_dir($template_dir   . "/templates"),
	"child_has_parts_dir"       => is_dir($stylesheet_dir . "/parts"),
	"parent_has_parts_dir"      => is_dir($template_dir   . "/parts"),
	"child_has_patterns_dir"    => is_dir($stylesheet_dir . "/patterns"),
	"parent_has_patterns_dir"   => is_dir($template_dir   . "/patterns"),

	// ── Block Theme ──────────────────────────────────────────────────────────
	"wp_is_block_theme"                  => function_exists("wp_is_block_theme") ? wp_is_block_theme() : null,
	"has_get_block_templates_function"   => function_exists("get_block_templates"),
	"has_get_block_template_function"    => function_exists("get_block_template"),
	"has_resolve_block_template_function" => function_exists("resolve_block_template"),

	// ── Block Bindings API (WP 6.7+ / WP 7) ─────────────────────────────────
	"has_block_bindings_registry"        => function_exists("wp_block_bindings_registry"),
	"has_register_block_bindings_source" => function_exists("register_block_bindings_source"),
	"registered_block_binding_sources"   => $registered_sources,

	// ── Interactivity API (WP 6.5+ / WP 7) ──────────────────────────────────
	"has_interactivity_api"      => class_exists("WP_Interactivity_API"),
	"has_wp_interactivity_state" => function_exists("wp_interactivity_state"),
	"has_wp_interactivity_config" => function_exists("wp_interactivity_config"),

	// ── Block Hooks (WP 6.5+) ────────────────────────────────────────────────
	"has_block_hooks"            => function_exists("insert_hooked_blocks"),
	"has_traverse_and_serialize_blocks" => function_exists("traverse_and_serialize_blocks"),

	// ── Synced Patterns ──────────────────────────────────────────────────────
	"has_synced_patterns_cpt"    => post_type_exists("wp_block"),
	"synced_pattern_count"       => $synced_total,

	// ── Font Library (WP 6.5+) ──────────────────────────────────────────────
	"has_font_library"           => function_exists("wp_get_font_face_data"),
	"has_font_face_cpt"          => post_type_exists("wp_font_face"),
	"has_font_family_cpt"        => post_type_exists("wp_font_family"),

	// ── REST API ─────────────────────────────────────────────────────────────
	"rest_api_namespaces"        => $rest_namespaces,
	"has_block_editor_rest_namespace" => in_array("wp-block-editor/v1", (array) $rest_namespaces),
);

echo wp_json_encode($data, JSON_PRETTY_PRINT);
]]

return {
	extends = "cmd_tool",

	name = "wp_cli",
	description = "Run approved WP-CLI checks against the current local WordPress site.",

	system_prompt = [[
This tool runs WP-CLI against the detected WordPress root.

Use this tool whenever the user asks about:
- active WordPress theme or installed themes/plugins
- WordPress options, posts, pages, or CPTs
- WordPress 7 readiness or upgrade planning
- Block theme support or theme.json
- FSE templates or template parts
- Block overrides or block bindings
- Interactivity API or block hooks support
- Synced patterns (wp_block CPT)
- Font Library (wp_font_face / wp_font_family)
- REST API namespaces registered on this install
- WordPress environment state

Action reference:
- block_overrides_audit  — comprehensive WP 7 readiness check (block bindings, interactivity API,
                           block hooks, synced patterns, font library, REST namespaces, FSE dirs)
- active_theme           — currently active theme (name, slug, status)
- theme_list             — all installed themes
- plugin_list            — all installed plugins
- core_version           — WordPress core version string
- templates_list         — FSE wp_template posts in the database
- template_parts_list    — FSE wp_template_part posts in the database
- synced_patterns_list   — synced block patterns (wp_block CPT)
- global_styles_get      — compiled global stylesheet from theme.json + user overrides
- rest_api_namespaces    — all REST API namespaces registered on this install
- raw                    — arbitrary WP-CLI subcommand (no leading "wp")

Rules:
- The tool already runs the "wp" binary. Do not include "wp", "@wp", "@wp_cli", shell redirects, pipes, or shell metacharacters.
- Prefer block_overrides_audit when the user asks about WP 7 readiness, block bindings, Interactivity API, or whether the environment supports block overrides.
- Prefer read-only actions unless the user explicitly asks to change WordPress state.
- For REST API questions use rest_api_namespaces before falling back to raw.
]],

	schema = {
		type = "object",
		properties = {
			action = {
				type = "string",
				enum = {
					"active_theme",
					"theme_list",
					"plugin_list",
					"core_version",
					"block_overrides_audit",
					"templates_list",
					"template_parts_list",
					"synced_patterns_list",
					"global_styles_get",
					"rest_api_namespaces",
					"raw",
				},
				description = "The safe WP-CLI action to run.",
			},
			query = {
				type = "string",
				description = "Only used when action is raw. WP-CLI arguments only, without the leading wp.",
			},
		},
		required = {
			"action",
		},
	},

	build_cmd = function(args)
		local action = args.action or ""
		local wp = wp_prefix()

		if wp:match("^printf") then
			return wp
		end

		if action == "active_theme" then
			return wp .. " theme list --status=active --format=json"
		end

		if action == "theme_list" then
			return wp .. " theme list --format=json"
		end

		if action == "plugin_list" then
			return wp .. " plugin list --format=json"
		end

		if action == "core_version" then
			return wp .. " core version"
		end

		if action == "block_overrides_audit" then
			return wp .. " eval " .. shell_quote(block_overrides_audit_php)
		end

		if action == "templates_list" then
			return wp .. " post list --post_type=wp_template --fields=ID,post_title,post_name,post_status --format=json"
		end

		if action == "template_parts_list" then
			return wp .. " post list --post_type=wp_template_part --fields=ID,post_title,post_name,post_status --format=json"
		end

		if action == "synced_patterns_list" then
			return wp .. " post list --post_type=wp_block --fields=ID,post_title,post_name,post_status --format=json"
		end

		if action == "global_styles_get" then
			local php = "echo wp_json_encode( array( 'stylesheet' => wp_get_global_stylesheet(), 'variables' => wp_get_global_settings() ), JSON_PRETTY_PRINT );"
			return wp .. " eval " .. shell_quote(php)
		end

		if action == "rest_api_namespaces" then
			local php = "echo wp_json_encode( rest_get_server()->get_namespaces(), JSON_PRETTY_PRINT );"
			return wp .. " eval " .. shell_quote(php)
		end

		if action == "raw" then
			local query = args.query or ""

			query = query:gsub("^%s+", ""):gsub("%s+$", "")
			query = query:gsub("^@?wp_cli%s+", "")
			query = query:gsub("^@?wp%s+", "")
			query = query:gsub("^cli%s+", "")

			if query == "" then
				return "printf '%s\n' 'ERROR: No WP-CLI query provided.'"
			end

			if query:find("[;&|`<>$\\\n\r]") then
				return "printf '%s\n' 'ERROR: Refusing shell metacharacters in WP-CLI query.'"
			end

			return wp .. " " .. query
		end

		return "printf '%s\n' 'ERROR: Unknown wp_cli action.'"
	end,
}
