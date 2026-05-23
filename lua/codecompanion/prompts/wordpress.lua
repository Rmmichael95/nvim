-- ~/.config/nvim/lua/codecompanion/prompts/wordpress.lua
--
-- Generic WordPress prompt helpers for CodeCompanion.
-- Keep project-specific FSE/pattern conventions in the dhali-fse skill and dhali.lua.

local M = {}

M.chat_system_prompt = function(ctx)
	return ctx.default_system_prompt
		.. [[

Additional WordPress tooling instructions:

A WordPress tool (@wp_cli) is available. Use it proactively whenever the user asks about:
- Current WordPress install, environment, version, active theme, plugins, or theme.json/global styles
- WordPress 7 readiness or upgrade planning
- FSE templates/template parts, synced patterns, Block Bindings, Interactivity API, REST namespaces, or Font Library
- Database restore/import verification or whether the database contains real content

Before project-specific WordPress work:
- Look for context.md in the WordPress root and read it if available.
- Use the context file before rereading large theme/plugin directories.
- Refresh only stale or task-critical facts.

Do not print WP-CLI commands and ask the user to run them.
Do not guess WordPress state or invent command output.
Use the tool to gather facts first, then reason from the result.

Action quick-reference:
  block_overrides_audit    — full WP 7 readiness check
  active_theme             — currently active theme
  theme_list / plugin_list — installed themes/plugins
  core_version             — WP core version string
  templates_list           — FSE wp_template posts
  template_parts_list      — FSE wp_template_part posts
  synced_patterns_list     — synced block patterns / wp_block CPT
  global_styles_get        — compiled global stylesheet + settings from theme.json
  rest_api_namespaces      — registered REST namespaces
  content_inventory_audit  — verify restored DB has real content, not just defaults
  raw                      — arbitrary WP-CLI subcommand, no leading "wp"
]]
end

M.ollie_pattern_prompt = [[
Use the ollie-pattern-builder skill.

Use the attached screenshot or current visual reference as the design source.

Before reading many project files, read context.md from the WordPress root if it exists.
Use cached conventions first; refresh only the target filename list and missing/stale token facts.

Generate a WordPress 7 / Ollie-compatible PHP block pattern.

Requirements:
- Use core blocks unless unavoidable.
- Match the existing PHP return-array pattern style.
- Enforce Ollie/theme preset slugs exactly; do not invent semantic color aliases.
- Prefer theme presets for spacing, colors, shadows, typography, and layout.
- Avoid custom CSS unless necessary.
- First show inferred layout, block tree, proposed filename, and complete PHP content.
- Do not write files until I approve.
]]

M.open_ollie_pattern_prompt = function()
	require("codecompanion").cli(M.ollie_pattern_prompt, {
		agent = "claude_code",
		submit = false,
		focus = true,
	})
end

M.wp_database_content_audit_prompt = [[
Use the @wp_cli tool with action content_inventory_audit.

Goal:
Verify whether the current WordPress database contains real site content or appears to be a fresh/default WordPress install.

Report:
1. Verdict: likely_real_site, possibly_default_install, empty_or_missing_content, or inconclusive_small_site
2. Evidence: page/post/media/CPT counts, content character count, navigation/menu presence, and default slugs found
3. Samples: representative page/post titles and slugs
4. Final recommendation: safe to proceed, investigate before proceeding, or likely wrong/empty database

Do not assume the database is valid just because WordPress loads.
Do not rely only on wp_posts row count.
]]

M.open_wp_database_content_audit_prompt = function()
	require("codecompanion").cli(M.wp_database_content_audit_prompt, {
		agent = "claude_code",
		submit = false,
		focus = true,
	})
end

return M
