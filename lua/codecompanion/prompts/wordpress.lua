-- ~/.config/nvim/lua/codecompanion/prompts/wordpress.lua
--
-- Generic WordPress prompt helpers for CodeCompanion.
-- Keep project-specific FSE/pattern conventions in the dhali-fse skill and dhali.lua.

local M = {}

M.chat_system_prompt = function(ctx)
	return ctx.default_system_prompt
		.. [[

Additional WordPress tooling instructions:

Tool priority for WordPress facts:
1. Use the WordPress MCP server named `wordpress` when a relevant ability exists.
2. Use @wp_cli when MCP is unavailable, missing the needed ability, or the task is an admin/debug audit not covered by MCP.
3. Read project files only when code conventions, exact existing markup, or target filenames are required.

WordPress MCP execution rule:
- For known Dhali abilities, execute directly; do not spend tokens discovering unless the call fails or the needed ability is unknown.
- Execute with `mcp-adapter-execute-ability` using exactly this top-level shape:
  `{ "ability_name": "namespace/ability-name", "parameters": { ... } }`
- Never use `ability_input`; the execute tool requires `parameters`.
- If the user says MCP-only and no relevant ability exists, stop and report that the MCP server is connected but the needed WordPress ability is not registered.
- Do not fall back to Bash, WP-CLI, curl, filesystem reads, or HTTP when the user requested MCP-only behavior.

Known Dhali MCP abilities:
  dhali/get-site-info
    parameters: { "request": "site_info" }
    use for: site title, active theme name/slug, template, stylesheet

  dhali/get-project-snapshot
    parameters: { "request": "project_snapshot" }
    use for: compact runtime snapshot, WP/PHP version, active theme, layout defaults

  dhali/get-token-and-layout-map
    parameters: { "request": "token_and_layout_map" }
    use for: color, spacing, font-size, and layout token slugs

  dhali/get-pattern-template-skeleton
    parameters: { "request": "pattern_template_skeleton" }
    use for: PHP pattern return-array skeleton without rereading examples

  dhali/get-icon-manifest
    parameters: { "request": "icon_manifest" }
    use for: Ollie/Outermost named icon and custom SVG wrapper markup

  dhali/validate-pattern-markup
    parameters: { "markup": "<!-- wp:... -->..." }
    use for: checking generated block markup before finalizing

  dhali/sync-context
    parameters: { "request": "sync_context", "confirm_write": true }
    use only when the user explicitly wants context.md refreshed or the current prompt workflow explicitly asks to update the cache

A WordPress tool (@wp_cli) is also available. Use it proactively when MCP lacks coverage for:
- WordPress 7 readiness or upgrade planning
- Full plugin/theme inventories
- FSE templates/template parts stored in the database
- Synced patterns, Block Bindings, Interactivity API, REST namespaces, or Font Library audits
- Database restore/import verification or whether the database contains real content

Before project-specific WordPress work:
- Prefer a short context.md cache when it already contains the needed facts.
- Use MCP abilities to refresh only stale or missing runtime/token/icon facts.
- Avoid rereading large theme/plugin directories unless code style or existing file examples are required.

Do not print WP-CLI commands and ask the user to run them.
Do not guess WordPress state or invent command output.
Use the tool result first, then reason from it.

@wp_cli action quick-reference:
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

Fast context path:
1. Read context.md only if it is small and already present.
2. For missing/stale WordPress facts, prefer the WordPress MCP server named `wordpress`.
3. Execute known abilities directly with `{ "ability_name": "...", "parameters": { ... } }`; never use `ability_input`.
4. Use `dhali/get-token-and-layout-map` for token slugs and `dhali/get-icon-manifest` only when icons/custom SVGs are involved.
5. Use @wp_cli only when MCP does not expose the needed fact.

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

M.wp_mcp_context_sync_prompt = [[
Use the dhali-wordpress-context skill.

Goal:
Create or update the WordPress project context file using the WordPress MCP server named `wordpress` first, while minimizing token usage and avoiding broad scans.

Strict tool order:
1. Find the WordPress root.
2. Check whether a concise context file already exists:
   - context.md
   - {project-name}_context.md
3. Use the WordPress MCP server named `wordpress` before @wp_cli whenever possible.

MCP execution rule:
- First call `mcp-adapter-discover-abilities`.
- Inspect relevant abilities with `mcp-adapter-get-ability-info`.
- Execute abilities with `mcp-adapter-execute-ability`.
- Always use this exact input shape:
  {
    "ability_name": "namespace/ability-name",
    "parameters": { ... }
  }
- Never use `ability_input`.

Preferred MCP abilities:
1. `dhali/get-project-snapshot`
   parameters:
   {
     "request": "project_snapshot"
   }

2. `dhali/get-token-and-layout-map`
   parameters:
   {
     "request": "token_and_layout_map"
   }

3. `dhali/get-icon-manifest`
   parameters:
   {
     "request": "icon_manifest"
   }

4. If I explicitly approve writing or the task is only to sync the cache, use `dhali/sync-context`
   parameters:
   {
     "request": "sync_context",
     "confirm_write": true
   }

Fallback rules:
- Use @wp_cli only when the needed fact is not available through MCP.
- Do not scan the full pattern library.
- Do not read large theme/plugin directories unless the context skill says the exact task requires representative examples.
- Do not print commands for me to run.
- Do not invent WordPress state, token slugs, file paths, or active theme details.

Output:
- Report the context file path.
- Summarize only the gathered facts that matter:
  - WordPress version
  - PHP version
  - active theme
  - token slug groups found
  - MCP abilities used
  - any missing facts
- Keep the response concise.
]]

M.open_wp_mcp_context_sync_prompt = function()
	require("codecompanion").cli(M.wp_mcp_context_sync_prompt, {
		agent = "claude_code",
		submit = false,
		focus = true,
	})
end

return M
