-- lua/snippets/php.lua
-- LuaSnip snippets for PHP files — general PHP + WordPress ecosystem.
-- Loaded by snippets.lua via luasnip.loaders.from_lua.
-- filetype_extend("php", { "html" }) means html.lua snippets are also active here.
--
-- Style: WordPress Coding Standards throughout.
--   • Allman braces  — opening brace on its own line
--   • Spaces inside  — add_action( 'hook', 'cb' ) not add_action('hook','cb')
--   • Tabs           — WP uses hard tabs for indentation
--
-- NOTE: add this to autocmds.lua to auto-fire _skel on new PHP files:
--   aucmd("BufNewFile", { pattern = "*.php",
--     callback = function() vim.schedule(load_document_skeleton) end })

local ls = require("luasnip")
local s, t, i, f, c = ls.snippet, ls.text_node, ls.insert_node, ls.function_node, ls.choice_node

local function mirror(args)
	return args[1][1]
end

-- Uppercase mirror for constants / class name in static context.
local function upper(args)
	return args[1][1]:upper()
end

ls.add_snippets("php", {

	-- ══════════════════════════════════════════════════════════════════════════
	-- GENERAL PHP
	-- ══════════════════════════════════════════════════════════════════════════

	-- ── _skel ─────────────────────────────────────────────────────────────────
	-- WP-safe file header. Fires automatically on BufNewFile via autocmds.lua.
	s({ trig = "_skel", name = "PHP/WP file header" }, {
		t({ "<?php", "/**", " * " }),
		i(1, "File description."),
		t({ "", " *", " * @package " }),
		i(2, "ThemeName"),
		t({
			"",
			" * @since   1.0.0",
			" */",
			"",
			"// Exit if accessed directly.",
			"if ( ! defined( 'ABSPATH' ) )",
			"{",
			"\texit;",
			"}",
			"",
		}),
		i(0),
	}),

	-- ── wpskel ────────────────────────────────────────────────────────────────
	-- Full WordPress plugin file header (main plugin file only).
	s({ trig = "wpskel", name = "WordPress plugin file header" }, {
		t({ "<?php", "/**", " * Plugin Name: " }),
		i(1, "Plugin Name"),
		t({ "", " * Plugin URI:  " }),
		i(2, "https://example.com"),
		t({ "", " * Description: " }),
		i(3, "Plugin description."),
		t({ "", " * Version:     " }),
		i(4, "1.0.0"),
		t({
			"",
			" * Author:      Ryan M Sullivan",
			" * Author URI:  https://ryanmsullivan.com",
			" * License:     GPL-2.0+",
			" * Text Domain: ",
		}),
		i(5, "plugin-name"),
		t({
			"",
			" * Domain Path: /languages",
			" */",
			"",
			"// Exit if accessed directly.",
			"if ( ! defined( 'ABSPATH' ) )",
			"{",
			"\texit;",
			"}",
			"",
		}),
		i(0),
	}),

	-- ── ns ────────────────────────────────────────────────────────────────────
	s({ trig = "ns", name = "namespace" }, {
		t("namespace "),
		i(1, "Vendor\\Package"),
		t(";"),
		i(0),
	}),

	-- ── use ───────────────────────────────────────────────────────────────────
	s({ trig = "use", name = "use statement" }, {
		t("use "),
		i(1, "Vendor\\Class"),
		t(";"),
	}),

	-- ── cls ───────────────────────────────────────────────────────────────────
	-- Class with constructor — Allman brace style.
	s({ trig = "cls", name = "class" }, {
		c(1, { t(""), t("final "), t("abstract ") }),
		t("class "),
		i(2, "ClassName"),
		c(3, {
			t(""),
			s("", { t(" extends "), i(1, "ParentClass") }),
			s("", { t(" implements "), i(1, "InterfaceName") }),
		}),
		t({ "", "{", "\t/**", "\t * @param " }),
		i(4, "mixed"),
		t({ " $param", "\t */", "\tpublic function __construct( " }),
		i(5),
		t({ " )", "\t{", "\t\t" }),
		i(0),
		t({ "", "\t}", "}" }),
	}),

	-- ── ifc ───────────────────────────────────────────────────────────────────
	s({ trig = "ifc", name = "interface" }, {
		t("interface "),
		i(1, "InterfaceName"),
		t({ "", "{", "\tpublic function " }),
		i(2, "methodName"),
		t("("),
		i(3),
		t({ ");", "}" }),
	}),

	-- ── trt ───────────────────────────────────────────────────────────────────
	s({ trig = "trt", name = "trait" }, {
		t("trait "),
		i(1, "TraitName"),
		t({ "", "{", "\t" }),
		i(0),
		t({ "", "}" }),
	}),

	-- ── fn ────────────────────────────────────────────────────────────────────
	-- Standalone function — Allman braces.
	s({ trig = "fn", name = "function" }, {
		t("function "),
		i(1, "function_name"),
		t("( "),
		i(2),
		t({ " )", "{", "\t" }),
		i(0),
		t({ "", "}" }),
	}),

	-- ── pfn ───────────────────────────────────────────────────────────────────
	-- Public class method.
	s({ trig = "pfn", name = "public function" }, {
		c(1, { t("public"), t("protected"), t("private") }),
		t(" function "),
		i(2, "methodName"),
		t("( "),
		i(3),
		t({ " ) : " }),
		c(4, { t("void"), t("string"), t("int"), t("bool"), t("array"), t("mixed"), t("?string") }),
		t({ "", "{", "\t" }),
		i(0),
		t({ "", "}" }),
	}),

	-- ── sfn ───────────────────────────────────────────────────────────────────
	-- Static method.
	s({ trig = "sfn", name = "static function" }, {
		t("public static function "),
		i(1, "methodName"),
		t("( "),
		i(2),
		t({ " )", "{", "\t" }),
		i(0),
		t({ "", "}" }),
	}),

	-- ── try ───────────────────────────────────────────────────────────────────
	s({ trig = "try", name = "try / catch" }, {
		t({ "try", "{", "\t" }),
		i(1),
		t({ "", "}", "catch ( " }),
		i(2, "Exception"),
		t({ " $e )", "{", "\terror_log( $e->getMessage() );", "\t" }),
		i(0),
		t({ "", "}" }),
	}),

	-- ── foreach ───────────────────────────────────────────────────────────────
	s({ trig = "foreach", name = "foreach" }, {
		t("foreach ( $"),
		i(1, "items"),
		t(" as $"),
		i(2, "item"),
		t({ " )", "{", "\t" }),
		i(0),
		t({ "", "}" }),
	}),

	-- ── pdo ───────────────────────────────────────────────────────────────────
	s({ trig = "pdo", name = "PDO connection" }, {
		t({ "try", "{", "\t$pdo = new PDO(", "\t\t'" }),
		c(1, { t("mysql"), t("pgsql"), t("sqlite") }),
		t(":host=$"),
		i(2, "host"),
		t(";dbname=$"),
		i(3, "dbname"),
		t({
			"',",
			"\t\t$username,",
			"\t\t$password,",
			"\t\t[",
			"\t\t\tPDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,",
			"\t\t\tPDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,",
			"\t\t]",
			"\t);",
			"}",
			"catch ( PDOException $e )",
			"{",
			"\tdie( 'DB error: ' . $e->getMessage() );",
			"}",
		}),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- WORDPRESS — Hooks
	-- ══════════════════════════════════════════════════════════════════════════

	-- ── aact ──────────────────────────────────────────────────────────────────
	-- add_action with optional priority + accepted_args.
	s({ trig = "aact", name = "add_action" }, {
		t("add_action( '"),
		i(1, "hook_name"),
		t("', '"),
		i(2, "callback_function"),
		t("', "),
		i(3, "10"),
		t(", "),
		i(4, "1"),
		t(" );"),
	}),

	-- ── aflt ──────────────────────────────────────────────────────────────────
	s({ trig = "aflt", name = "add_filter" }, {
		t("add_filter( '"),
		i(1, "filter_name"),
		t("', '"),
		i(2, "callback_function"),
		t("', "),
		i(3, "10"),
		t(", "),
		i(4, "1"),
		t(" );"),
	}),

	-- ── doact ─────────────────────────────────────────────────────────────────
	s({ trig = "doact", name = "do_action" }, {
		t("do_action( '"),
		i(1, "hook_name"),
		i(2),
		t(" );"),
	}),

	-- ── aplflt ────────────────────────────────────────────────────────────────
	s({ trig = "aplflt", name = "apply_filters" }, {
		t("apply_filters( '"),
		i(1, "filter_name"),
		t("', "),
		i(2, "$value"),
		t(" )"),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- WORDPRESS — Registration
	-- ══════════════════════════════════════════════════════════════════════════

	-- ── rpt ───────────────────────────────────────────────────────────────────
	-- register_post_type — full args array with most common options.
	s({ trig = "rpt", name = "register_post_type" }, {
		t("register_post_type("),
		t({ "", "\t'" }),
		i(1, "post_type"),
		t({ "',", "\t[", "\t\t'label'               => __( '" }),
		i(2, "Post Type Name"),
		t("', '"),
		i(3, "text-domain"),
		t({
			"' ),",
			"\t\t'public'              => true,",
			"\t\t'show_in_rest'        => true,",
			"\t\t'menu_icon'           => 'dashicons-admin-post',",
			"\t\t'supports'            => [ 'title', 'editor', 'thumbnail' ],",
			"\t\t'has_archive'         => true,",
			"\t\t'rewrite'             => [ 'slug' => '",
		}),
		f(mirror, { 1 }),
		t({ "' ],", "\t\t'labels'              => [", "\t\t\t'name'          => __( '" }),
		i(4, "Post Types"),
		t("', '"),
		f(mirror, { 3 }),
		t({ "' ),", "\t\t\t'singular_name' => __( '" }),
		i(5, "Post Type"),
		t("', '"),
		f(mirror, { 3 }),
		t({ "' ),", "\t\t],", "\t]", ");" }),
	}),

	-- ── rtax ──────────────────────────────────────────────────────────────────
	s({ trig = "rtax", name = "register_taxonomy" }, {
		t("register_taxonomy("),
		t({ "", "\t'" }),
		i(1, "taxonomy"),
		t({ "',", "\t'" }),
		i(2, "post_type"),
		t({ "',", "\t[", "\t\t'label'        => __( '" }),
		i(3, "Taxonomy Name"),
		t("', '"),
		i(4, "text-domain"),
		t({ "' ),", "\t\t'hierarchical' => " }),
		c(5, { t("false"), t("true") }),
		t({ ",", "\t\t'show_in_rest' => true,", "\t\t'rewrite'      => [ 'slug' => '" }),
		f(mirror, { 1 }),
		t({ "' ],", "\t]", ");" }),
	}),

	-- ── shrt ──────────────────────────────────────────────────────────────────
	-- Shortcode using output buffering — cleanest pattern.
	s({ trig = "shrt", name = "add_shortcode" }, {
		t("add_shortcode( '"),
		i(1, "shortcode_name"),
		t({ "', function( $atts, $content = null )", "{", "\t$atts = shortcode_atts(", "\t\t[", "\t\t\t'" }),
		i(2, "key"),
		t("' => '"),
		i(3, "default"),
		t({ "',", "\t\t],", "\t\t$atts,", "\t\t'" }),
		f(mirror, { 1 }),
		t({ "'", "\t);", "", "\tob_start();", "\t?>", '\t\t<div class="' }),
		f(mirror, { 1 }),
		t({ '">', "\t\t\t" }),
		i(0),
		t({ "", "\t\t</div>", "\t<?php", "\treturn ob_get_clean();", "} );" }),
	}),

	-- ── enqs ──────────────────────────────────────────────────────────────────
	s({ trig = "enqs", name = "wp_enqueue_script" }, {
		t("wp_enqueue_script("),
		t({ "", "\t'" }),
		i(1, "handle"),
		t({ "',", "\tget_template_directory_uri() . '/assets/js/" }),
		i(2, "script.js"),
		t({ "',", "\t[ " }),
		i(3, "'jquery'"),
		t({ " ],", "\t'" }),
		i(4, "1.0.0"),
		t({ "',", "\ttrue", ");" }),
	}),

	-- ── enqss ─────────────────────────────────────────────────────────────────
	s({ trig = "enqss", name = "wp_enqueue_style" }, {
		t("wp_enqueue_style("),
		t({ "", "\t'" }),
		i(1, "handle"),
		t({ "',", "\tget_template_directory_uri() . '/assets/css/" }),
		i(2, "style.css"),
		t({ "',", "\t[ " }),
		i(3),
		t({ " ],", "\t'" }),
		i(4, "1.0.0"),
		t({ "'", ");" }),
	}),

	-- ── wpaj ──────────────────────────────────────────────────────────────────
	-- wp_localize_script for AJAX — pairs with wp_enqueue_script.
	s({ trig = "wpaj", name = "wp_localize_script (AJAX)" }, {
		t("wp_localize_script("),
		t({ "", "\t'" }),
		i(1, "handle"),
		t({ "',", "\t'" }),
		i(2, "ajax_obj"),
		t({ "',", "\t[", "\t\t'ajax_url' => admin_url( 'admin-ajax.php' ),", "\t\t'nonce'    => wp_create_nonce( '" }),
		i(3, "nonce_action"),
		t({ "' ),", "\t]", ");" }),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- WORDPRESS — Data / Query
	-- ══════════════════════════════════════════════════════════════════════════

	-- ── wpq ───────────────────────────────────────────────────────────────────
	-- WP_Query with proper wp_reset_postdata().
	s({ trig = "wpq", name = "WP_Query" }, {
		t({ "$args  = [", "\t'post_type'      => '" }),
		i(1, "post"),
		t({ "',", "\t'posts_per_page' => " }),
		i(2, "10"),
		t({
			",",
			"\t'post_status'    => 'publish',",
			"];",
			"",
			"$query = new WP_Query( $args );",
			"",
			"if ( $query->have_posts() )",
			"{",
			"\twhile ( $query->have_posts() )",
			"\t{",
			"\t\t$query->the_post();",
			"\t\t",
		}),
		i(0),
		t({ "", "\t}", "}", "", "wp_reset_postdata();" }),
	}),

	-- ── getpost ───────────────────────────────────────────────────────────────
	s({ trig = "getpost", name = "get_posts" }, {
		t({ "$posts = get_posts(", "\t[", "\t\t'post_type'      => '" }),
		i(1, "post"),
		t({ "',", "\t\t'posts_per_page' => " }),
		i(2, "10"),
		t({
			",",
			"\t\t'post_status'    => 'publish',",
			"\t]",
			");",
			"",
			"foreach ( $posts as $post )",
			"{",
			"\tsetup_postdata( $post );",
			"\t",
		}),
		i(0),
		t({ "", "}", "", "wp_reset_postdata();" }),
	}),

	-- ── meta ──────────────────────────────────────────────────────────────────
	-- add_meta_box with a separate render callback.
	s({ trig = "meta", name = "add_meta_box" }, {
		t("add_meta_box("),
		t({ "", "\t'" }),
		i(1, "meta_box_id"),
		t({ "',", "\t__( '" }),
		i(2, "Meta Box Title"),
		t("', '"),
		i(3, "text-domain"),
		t({ "' ),", "\t'" }),
		i(4, "render_callback"),
		t({ "',", "\t'" }),
		i(5, "post"),
		t({ "',", "\t'normal',", "\t'high'", ");", "", "function " }),
		f(mirror, { 4 }),
		t({ "( $post )", "{", "\t$value = get_post_meta( $post->ID, '_" }),
		i(6, "meta_key"),
		t({ "', true );", "\twp_nonce_field( '" }),
		f(mirror, { 1 }),
		t("_nonce', '"),
		f(mirror, { 1 }),
		t({ "_nonce_field' );", "\t?>", '\t<label for="' }),
		f(mirror, { 6 }),
		t({ '">' }),
		f(mirror, { 2 }),
		t({ "</label>", '\t<input type="text" id="' }),
		f(mirror, { 6 }),
		t('" name="'),
		f(mirror, { 6 }),
		t('" value="<?php echo esc_attr( $value ); ?>" />'),
		t({ "", "\t<?php", "}" }),
	}),

	-- ── restrt ────────────────────────────────────────────────────────────────
	s({ trig = "restrt", name = "register_rest_route" }, {
		t("register_rest_route("),
		t({ "", "\t'" }),
		i(1, "plugin/v1"),
		t({ "',", "\t'/" }),
		i(2, "endpoint"),
		t({ "',", "\t[", "\t\t'methods'             => WP_REST_Server::" }),
		c(3, { t("READABLE"), t("CREATABLE"), t("EDITABLE"), t("DELETABLE") }),
		t({ ",", "\t\t'callback'            => '" }),
		i(4, "callback_function"),
		t({ "',", "\t\t'permission_callback' => '__return_true',", "\t]", ");" }),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- WORDPRESS — ACF Pro
	-- ══════════════════════════════════════════════════════════════════════════

	-- ── acff ──────────────────────────────────────────────────────────────────
	s({ trig = "acff", name = "get_field (ACF)" }, {
		t("get_field( '"),
		i(1, "field_name"),
		t("' )"),
	}),

	-- ── acffe ─────────────────────────────────────────────────────────────────
	-- the_field — echoes directly, no escaping. Use esc_* where needed.
	s({ trig = "acffe", name = "the_field (ACF echo)" }, {
		t("the_field( '"),
		i(1, "field_name"),
		t("' );"),
	}),

	-- ── acfr ──────────────────────────────────────────────────────────────────
	-- ACF Repeater / Flexible Content loop.
	s({ trig = "acfr", name = "ACF repeater loop" }, {
		t("if ( have_rows( '"),
		i(1, "repeater_field"),
		t({ "' ) )", "{", "\twhile ( have_rows( '" }),
		f(mirror, { 1 }),
		t({ "' ) ) : the_row();", "\t\t$" }),
		i(2, "sub_value"),
		t(" = get_sub_field( '"),
		i(3, "sub_field_name"),
		t({ "' );", "\t\t" }),
		i(0),
		t({ "", "\tendwhile;", "}" }),
	}),

	-- ── acfopt ────────────────────────────────────────────────────────────────
	-- get_field from Options page (ACF Options Page addon).
	s({ trig = "acfopt", name = "get_field from options page (ACF)" }, {
		t("get_field( '"),
		i(1, "field_name"),
		t("', 'option' )"),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- WORDPRESS — Output / i18n
	-- ══════════════════════════════════════════════════════════════════════════

	-- ── esc ───────────────────────────────────────────────────────────────────
	s({ trig = "esc", name = "esc_* output" }, {
		c(1, { t("esc_html"), t("esc_attr"), t("esc_url"), t("esc_js"), t("esc_textarea") }),
		t("( "),
		i(2, "$value"),
		t(" )"),
	}),

	-- ── __ ────────────────────────────────────────────────────────────────────
	-- Translation string — returns string, does not echo.
	s({ trig = "__", name = "__() translation" }, {
		t("__( '"),
		i(1, "String to translate"),
		t("', '"),
		i(2, "text-domain"),
		t("' )"),
	}),

	-- ── _e ────────────────────────────────────────────────────────────────────
	-- Translation string — echoes directly.
	s({ trig = "_e", name = "_e() translation echo" }, {
		t("_e( '"),
		i(1, "String to translate"),
		t("', '"),
		i(2, "text-domain"),
		t("' );"),
	}),

	-- ── nonce ─────────────────────────────────────────────────────────────────
	-- wp_nonce_field in a form + verify pattern in a comment.
	s({ trig = "nonce", name = "wp_nonce_field + verify" }, {
		t("wp_nonce_field( '"),
		i(1, "action_name"),
		t("', '"),
		i(2, "nonce_field"),
		t({ "' );", "// Verify with:", "// check_admin_referer( '" }),
		f(mirror, { 1 }),
		t("', '"),
		f(mirror, { 2 }),
		t("' );"),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- WORDPRESS — WooCommerce
	-- ══════════════════════════════════════════════════════════════════════════

	-- ── wooloop ───────────────────────────────────────────────────────────────
	-- Standard WooCommerce product loop.
	s({ trig = "wooloop", name = "WooCommerce product loop" }, {
		t({ "$args     = [", "\t'post_type'      => 'product',", "\t'posts_per_page' => " }),
		i(1, "12"),
		t({
			",",
			"\t'post_status'    => 'publish',",
			"];",
			"",
			"$products = new WP_Query( $args );",
			"",
			"if ( $products->have_posts() )",
			"{",
			"\twhile ( $products->have_posts() )",
			"\t{",
			"\t\t$products->the_post();",
			"\t\t$product = wc_get_product( get_the_ID() );",
			"\t\t",
		}),
		i(0),
		t({ "", "\t}", "}", "", "wp_reset_postdata();" }),
	}),

	-- ── wooprice ──────────────────────────────────────────────────────────────
	s({ trig = "wooprice", name = "WooCommerce get product price" }, {
		t("$product->get_price_html()"),
	}),
})
