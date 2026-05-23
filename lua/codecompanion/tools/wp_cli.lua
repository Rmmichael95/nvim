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

local content_inventory_audit_php = [[
global $wpdb;

function cc_count_statuses_for_post_type($post_type) {
	$counts = wp_count_posts($post_type);
	$out = array();

	foreach (get_post_stati() as $status) {
		$out[$status] = isset($counts->{$status}) ? (int) $counts->{$status} : 0;
	}

	return $out;
}

function cc_sample_posts_for_type($post_type, $limit = 10) {
	$posts = get_posts(array(
		'post_type'      => $post_type,
		'post_status'    => array('publish', 'draft', 'private', 'pending', 'future'),
		'posts_per_page' => $limit,
		'orderby'        => 'modified',
		'order'          => 'DESC',
	));

	return array_map(function($post) {
		return array(
			'ID'            => (int) $post->ID,
			'post_title'    => get_the_title($post),
			'post_name'     => $post->post_name,
			'post_status'   => $post->post_status,
			'post_type'     => $post->post_type,
			'post_date'     => $post->post_date,
			'post_modified' => $post->post_modified,
			'content_chars' => strlen(wp_strip_all_tags($post->post_content)),
		);
	}, $posts);
}

$public_post_types = get_post_types(array('public' => true), 'names');

// Always include key WordPress content types, even if something filtered public post types.
$content_post_types = array_values(array_unique(array_merge(
	array('post', 'page', 'attachment', 'wp_navigation'),
	array_values($public_post_types)
)));

$post_type_counts = array();
$samples = array();

foreach ($content_post_types as $post_type) {
	if (!post_type_exists($post_type)) {
		continue;
	}

	$post_type_counts[$post_type] = cc_count_statuses_for_post_type($post_type);

	if ($post_type !== 'attachment') {
		$samples[$post_type] = cc_sample_posts_for_type($post_type, 10);
	}
}

$published_posts = isset($post_type_counts['post']['publish']) ? (int) $post_type_counts['post']['publish'] : 0;
$published_pages = isset($post_type_counts['page']['publish']) ? (int) $post_type_counts['page']['publish'] : 0;
$attachments     = isset($post_type_counts['attachment']['inherit']) ? (int) $post_type_counts['attachment']['inherit'] : 0;

$default_slugs = array('hello-world', 'sample-page', 'privacy-policy');
$found_default_slugs = array();

foreach ($default_slugs as $slug) {
	$found = get_page_by_path($slug, OBJECT, array('post', 'page'));

	if ($found) {
		$found_default_slugs[] = array(
			'ID'          => (int) $found->ID,
			'post_title'  => get_the_title($found),
			'post_name'   => $found->post_name,
			'post_type'   => $found->post_type,
			'post_status' => $found->post_status,
		);
	}
}

$content_types_for_sql = array_values(array_filter($content_post_types, function($type) {
	return $type !== 'attachment';
}));

$escaped_types = array_map('esc_sql', $content_types_for_sql);
$type_list_sql = "'" . implode("','", $escaped_types) . "'";

$total_content_chars = (int) $wpdb->get_var("
	SELECT COALESCE(SUM(CHAR_LENGTH(post_content)), 0)
	FROM {$wpdb->posts}
	WHERE post_type IN ({$type_list_sql})
	AND post_status NOT IN ('auto-draft', 'trash', 'inherit')
");

$total_non_attachment_content = (int) $wpdb->get_var("
	SELECT COUNT(*)
	FROM {$wpdb->posts}
	WHERE post_type IN ({$type_list_sql})
	AND post_status NOT IN ('auto-draft', 'trash', 'inherit')
");

$latest_modified = $wpdb->get_var("
	SELECT MAX(post_modified)
	FROM {$wpdb->posts}
	WHERE post_type IN ({$type_list_sql})
	AND post_status NOT IN ('auto-draft', 'trash', 'inherit')
");

$terms = array(
	'category_count' => taxonomy_exists('category') ? (int) wp_count_terms(array('taxonomy' => 'category', 'hide_empty' => false)) : null,
	'post_tag_count' => taxonomy_exists('post_tag') ? (int) wp_count_terms(array('taxonomy' => 'post_tag', 'hide_empty' => false)) : null,
);

$nav_menu_terms = taxonomy_exists('nav_menu')
	? get_terms(array('taxonomy' => 'nav_menu', 'hide_empty' => false))
	: array();

$menus = array_map(function($term) {
	return array(
		'term_id' => (int) $term->term_id,
		'name'    => $term->name,
		'slug'    => $term->slug,
		'count'   => (int) $term->count,
	);
}, is_wp_error($nav_menu_terms) ? array() : $nav_menu_terms);

$signals = array();

if ($published_pages >= 3) {
	$signals[] = 'Has 3 or more published pages.';
}

if ($published_posts >= 2) {
	$signals[] = 'Has 2 or more published posts.';
}

if ($attachments >= 5) {
	$signals[] = 'Has 5 or more media attachments.';
}

if ($total_content_chars >= 5000) {
	$signals[] = 'Has substantial stored post/page content.';
}

if (count($menus) > 0 || (isset($post_type_counts['wp_navigation']['publish']) && $post_type_counts['wp_navigation']['publish'] > 0)) {
	$signals[] = 'Has navigation/menu data.';
}

if (count($found_default_slugs) > 0) {
	$signals[] = 'Default WordPress slugs are present.';
}

$looks_defaultish =
	$published_pages <= 1
	&& $published_posts <= 1
	&& $attachments <= 1
	&& $total_content_chars < 2500
	&& count($found_default_slugs) > 0;

$looks_empty =
	$total_non_attachment_content === 0
	|| (
		$published_pages === 0
		&& $published_posts === 0
		&& $attachments === 0
	);

if ($looks_empty) {
	$verdict = 'empty_or_missing_content';
	$confidence = 'high';
} elseif ($looks_defaultish) {
	$verdict = 'possibly_default_install';
	$confidence = 'high';
} elseif ($published_pages >= 3 || $published_posts >= 2 || $attachments >= 5 || $total_content_chars >= 5000) {
	$verdict = 'likely_real_site';
	$confidence = 'medium';
} else {
	$verdict = 'inconclusive_small_site';
	$confidence = 'medium';
}

$data = array(
	'site' => array(
		'name'        => get_bloginfo('name'),
		'url'         => home_url('/'),
		'wp_version'  => get_bloginfo('version'),
		'table_prefix'=> $wpdb->prefix,
	),
	'verdict' => array(
		'status'     => $verdict,
		'confidence' => $confidence,
		'signals'    => $signals,
	),
	'summary' => array(
		'published_posts'              => $published_posts,
		'published_pages'              => $published_pages,
		'attachments'                  => $attachments,
		'total_non_attachment_content' => $total_non_attachment_content,
		'total_content_chars'          => $total_content_chars,
		'latest_modified'              => $latest_modified,
	),
	'post_type_counts' => $post_type_counts,
	'default_install_fingerprints' => array(
		'checked_slugs' => $default_slugs,
		'found'         => $found_default_slugs,
	),
	'terms' => $terms,
	'menus' => $menus,
	'samples' => $samples,
);

echo wp_json_encode($data, JSON_PRETTY_PRINT);
]]

local content_inventory_audit_php = [[
global $wpdb;

function cc_count_statuses_for_post_type($post_type) {
	$counts = wp_count_posts($post_type);
	$out = array();

	foreach (get_post_stati() as $status) {
		$out[$status] = isset($counts->{$status}) ? (int) $counts->{$status} : 0;
	}

	return $out;
}

function cc_sample_posts_for_type($post_type, $limit = 10) {
	$posts = get_posts(array(
		'post_type'      => $post_type,
		'post_status'    => array('publish', 'draft', 'private', 'pending', 'future'),
		'posts_per_page' => $limit,
		'orderby'        => 'modified',
		'order'          => 'DESC',
	));

	return array_map(function($post) {
		return array(
			'ID'            => (int) $post->ID,
			'post_title'    => get_the_title($post),
			'post_name'     => $post->post_name,
			'post_status'   => $post->post_status,
			'post_type'     => $post->post_type,
			'post_date'     => $post->post_date,
			'post_modified' => $post->post_modified,
			'content_chars' => strlen(wp_strip_all_tags($post->post_content)),
		);
	}, $posts);
}

$public_post_types = get_post_types(array('public' => true), 'names');

// Always include key WordPress content types, even if something filtered public post types.
$content_post_types = array_values(array_unique(array_merge(
	array('post', 'page', 'attachment', 'wp_navigation'),
	array_values($public_post_types)
)));

$post_type_counts = array();
$samples = array();

foreach ($content_post_types as $post_type) {
	if (!post_type_exists($post_type)) {
		continue;
	}

	$post_type_counts[$post_type] = cc_count_statuses_for_post_type($post_type);

	if ($post_type !== 'attachment') {
		$samples[$post_type] = cc_sample_posts_for_type($post_type, 10);
	}
}

$published_posts = isset($post_type_counts['post']['publish']) ? (int) $post_type_counts['post']['publish'] : 0;
$published_pages = isset($post_type_counts['page']['publish']) ? (int) $post_type_counts['page']['publish'] : 0;
$attachments     = isset($post_type_counts['attachment']['inherit']) ? (int) $post_type_counts['attachment']['inherit'] : 0;

$default_slugs = array('hello-world', 'sample-page', 'privacy-policy');
$found_default_slugs = array();

foreach ($default_slugs as $slug) {
	$found = get_page_by_path($slug, OBJECT, array('post', 'page'));

	if ($found) {
		$found_default_slugs[] = array(
			'ID'          => (int) $found->ID,
			'post_title'  => get_the_title($found),
			'post_name'   => $found->post_name,
			'post_type'   => $found->post_type,
			'post_status' => $found->post_status,
		);
	}
}

$content_types_for_sql = array_values(array_filter($content_post_types, function($type) {
	return $type !== 'attachment';
}));

$escaped_types = array_map('esc_sql', $content_types_for_sql);
$type_list_sql = "'" . implode("','", $escaped_types) . "'";

$total_content_chars = (int) $wpdb->get_var("
	SELECT COALESCE(SUM(CHAR_LENGTH(post_content)), 0)
	FROM {$wpdb->posts}
	WHERE post_type IN ({$type_list_sql})
	AND post_status NOT IN ('auto-draft', 'trash', 'inherit')
");

$total_non_attachment_content = (int) $wpdb->get_var("
	SELECT COUNT(*)
	FROM {$wpdb->posts}
	WHERE post_type IN ({$type_list_sql})
	AND post_status NOT IN ('auto-draft', 'trash', 'inherit')
");

$latest_modified = $wpdb->get_var("
	SELECT MAX(post_modified)
	FROM {$wpdb->posts}
	WHERE post_type IN ({$type_list_sql})
	AND post_status NOT IN ('auto-draft', 'trash', 'inherit')
");

$terms = array(
	'category_count' => taxonomy_exists('category') ? (int) wp_count_terms(array('taxonomy' => 'category', 'hide_empty' => false)) : null,
	'post_tag_count' => taxonomy_exists('post_tag') ? (int) wp_count_terms(array('taxonomy' => 'post_tag', 'hide_empty' => false)) : null,
);

$nav_menu_terms = taxonomy_exists('nav_menu')
	? get_terms(array('taxonomy' => 'nav_menu', 'hide_empty' => false))
	: array();

$menus = array_map(function($term) {
	return array(
		'term_id' => (int) $term->term_id,
		'name'    => $term->name,
		'slug'    => $term->slug,
		'count'   => (int) $term->count,
	);
}, is_wp_error($nav_menu_terms) ? array() : $nav_menu_terms);

$signals = array();

if ($published_pages >= 3) {
	$signals[] = 'Has 3 or more published pages.';
}

if ($published_posts >= 2) {
	$signals[] = 'Has 2 or more published posts.';
}

if ($attachments >= 5) {
	$signals[] = 'Has 5 or more media attachments.';
}

if ($total_content_chars >= 5000) {
	$signals[] = 'Has substantial stored post/page content.';
}

if (count($menus) > 0 || (isset($post_type_counts['wp_navigation']['publish']) && $post_type_counts['wp_navigation']['publish'] > 0)) {
	$signals[] = 'Has navigation/menu data.';
}

if (count($found_default_slugs) > 0) {
	$signals[] = 'Default WordPress slugs are present.';
}

$looks_defaultish =
	$published_pages <= 1
	&& $published_posts <= 1
	&& $attachments <= 1
	&& $total_content_chars < 2500
	&& count($found_default_slugs) > 0;

$looks_empty =
	$total_non_attachment_content === 0
	|| (
		$published_pages === 0
		&& $published_posts === 0
		&& $attachments === 0
	);

if ($looks_empty) {
	$verdict = 'empty_or_missing_content';
	$confidence = 'high';
} elseif ($looks_defaultish) {
	$verdict = 'possibly_default_install';
	$confidence = 'high';
} elseif ($published_pages >= 3 || $published_posts >= 2 || $attachments >= 5 || $total_content_chars >= 5000) {
	$verdict = 'likely_real_site';
	$confidence = 'medium';
} else {
	$verdict = 'inconclusive_small_site';
	$confidence = 'medium';
}

$data = array(
	'site' => array(
		'name'        => get_bloginfo('name'),
		'url'         => home_url('/'),
		'wp_version'  => get_bloginfo('version'),
		'table_prefix'=> $wpdb->prefix,
	),
	'verdict' => array(
		'status'     => $verdict,
		'confidence' => $confidence,
		'signals'    => $signals,
	),
	'summary' => array(
		'published_posts'              => $published_posts,
		'published_pages'              => $published_pages,
		'attachments'                  => $attachments,
		'total_non_attachment_content' => $total_non_attachment_content,
		'total_content_chars'          => $total_content_chars,
		'latest_modified'              => $latest_modified,
	),
	'post_type_counts' => $post_type_counts,
	'default_install_fingerprints' => array(
		'checked_slugs' => $default_slugs,
		'found'         => $found_default_slugs,
	),
	'terms' => $terms,
	'menus' => $menus,
	'samples' => $samples,
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
- content_inventory_audit — checks whether the database contains real pages/posts/media/navigation or looks like a fresh/default install
- verifying whether a restored/imported database contains real WordPress content
- checking if the database looks like a fresh/default WordPress install

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
					"content_inventory_audit",
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

		if action == "content_inventory_audit" then
			return wp .. " eval " .. shell_quote(content_inventory_audit_php)
		end

		if action == "templates_list" then
			return wp .. " post list --post_type=wp_template --fields=ID,post_title,post_name,post_status --format=json"
		end

		if action == "template_parts_list" then
			return wp
				.. " post list --post_type=wp_template_part --fields=ID,post_title,post_name,post_status --format=json"
		end

		if action == "synced_patterns_list" then
			return wp .. " post list --post_type=wp_block --fields=ID,post_title,post_name,post_status --format=json"
		end

		if action == "global_styles_get" then
			local php =
				"echo wp_json_encode( array( 'stylesheet' => wp_get_global_stylesheet(), 'variables' => wp_get_global_settings() ), JSON_PRETTY_PRINT );"
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
