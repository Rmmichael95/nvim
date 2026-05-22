-- ~/.config/nvim/lua/codecompanion/tools/wp_cli.lua

local function shell_quote(value)
	value = tostring(value or "")
	return "'" .. value:gsub("'", "'\\''") .. "'"
end

local block_overrides_audit_php = [[
$stylesheet = get_stylesheet();
$template = get_template();

$stylesheet_dir = get_stylesheet_directory();
$template_dir = get_template_directory();

$theme = wp_get_theme($stylesheet);

$data = array(
	"core_version" => get_bloginfo("version"),
	"theme_name" => $theme->get("Name"),
	"stylesheet" => $stylesheet,
	"template" => $template,
	"is_child_theme" => $stylesheet !== $template,

	"child_theme_dir" => $stylesheet_dir,
	"parent_theme_dir" => $template_dir,

	"child_has_style_css" => file_exists($stylesheet_dir . "/style.css"),
	"parent_has_style_css" => file_exists($template_dir . "/style.css"),

	"child_has_functions_php" => file_exists($stylesheet_dir . "/functions.php"),
	"parent_has_functions_php" => file_exists($template_dir . "/functions.php"),

	"child_has_theme_json" => file_exists($stylesheet_dir . "/theme.json"),
	"parent_has_theme_json" => file_exists($template_dir . "/theme.json"),

	"child_has_templates_dir" => is_dir($stylesheet_dir . "/templates"),
	"parent_has_templates_dir" => is_dir($template_dir . "/templates"),

	"child_has_parts_dir" => is_dir($stylesheet_dir . "/parts"),
	"parent_has_parts_dir" => is_dir($template_dir . "/parts"),

	"child_has_patterns_dir" => is_dir($stylesheet_dir . "/patterns"),
	"parent_has_patterns_dir" => is_dir($template_dir . "/patterns"),

	"wp_is_block_theme" => function_exists("wp_is_block_theme") ? wp_is_block_theme() : null,
	"has_get_block_templates_function" => function_exists("get_block_templates"),
	"has_get_block_template_function" => function_exists("get_block_template"),
	"has_resolve_block_template_function" => function_exists("resolve_block_template"),
);

echo wp_json_encode($data, JSON_PRETTY_PRINT);
]]

return {
	extends = "cmd_tool",

	name = "wp_cli",
	description = "Run approved WP-CLI checks against the current local WordPress site.",

	system_prompt = [[
This tool runs WP-CLI in the current Neovim working directory.

Use this tool whenever the user asks about:
- active WordPress theme
- installed themes
- installed plugins
- WordPress options
- posts, pages, or CPTs
- WordPress 7 readiness
- block theme support
- theme.json
- templates
- template parts
- block overrides
- WordPress environment state

Rules:
- The tool already runs the "wp" binary.
- Do not include "wp", "@wp", "@wp_cli", "wp_cli", "cli", shell redirects, pipes, or shell syntax.
- Prefer the "block_overrides_audit" action when the user asks whether the environment can handle block overrides.
- Prefer read-only actions unless the user explicitly asks to change WordPress state.
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

		if action == "active_theme" then
			return "wp theme list --status=active --format=json"
		end

		if action == "theme_list" then
			return "wp theme list --format=json"
		end

		if action == "plugin_list" then
			return "wp plugin list --format=json"
		end

		if action == "core_version" then
			return "wp core version"
		end

		if action == "block_overrides_audit" then
			return "wp eval " .. shell_quote(block_overrides_audit_php)
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

			return "wp " .. query
		end

		return "printf '%s\n' 'ERROR: Unknown wp_cli action.'"
	end,
}
