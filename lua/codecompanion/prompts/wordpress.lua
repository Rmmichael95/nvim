-- wordpress.lua — Generic WordPress prompts for CodeCompanion.
-- Pattern-specific rules and procedure in dhali.lua + dhali-fse skill.

local M = {}

M.chat_system_prompt = function(ctx)
	return ctx.default_system_prompt
		.. [[

WordPress MCP available. prefer MCP over @wp_cli. execute: {ability_name,parameters}. never ability_input.
Discover once per session. If no ability → @wp_cli. don't print WP-CLI for user to run.
For patterns: dhali/lint-pattern-authoring-rules + dhali/validate-pattern-markup must be confirmed before any write.

@wp_cli actions: active_theme, core_version, theme_list, plugin_list, templates_list,
template_parts_list, synced_patterns_list, global_styles_get, rest_api_namespaces,
content_inventory_audit, raw (no leading "wp").
]]
end

M.wp_mcp_context_sync_prompt = [[
Skill: dhali-fse.
Task: create/update WordPress project context file.

1. Find WP root.
2. Check for context.md or {project}_context.md. If fresh → read + report. no recreate.
3. If missing or refresh needed:

   MCP (in order):
   a. dhali/sync-context {"request":"sync_context","confirm_write":true}
      → writes context.md with tokens + image assets. done if succeeds.
   b. dhali/get-project-snapshot {"request":"project_snapshot"}  (fallback)
   c. dhali/get-site-info {"request":"site_info"}               (fallback)
   d. dhali/get-token-and-layout-map {"request":"token_and_layout_map"} (fallback)
   e. dhali/get-local-assets {"request":"get_local_assets"}     (fallback: asset list)

4. @wp_cli only when MCP lacks needed fact.
5. No full pattern library scan. No inventing state.

Output: context path + summary (WP version, theme, tokens, assets, abilities used).
]]

M.open_wp_mcp_context_sync_prompt = function()
	require("codecompanion").cli(M.wp_mcp_context_sync_prompt, {
		agent = "claude_code",
		submit = false,
		focus = true,
	})
end

M.wp_database_content_audit_prompt = [[
Use @wp_cli action content_inventory_audit.

Verdict: likely_real_site | possibly_default_install | empty_or_missing_content | inconclusive_small_site
Evidence: page/post/media/CPT counts, content char count, nav/menu presence, default slugs.
Samples: representative titles + slugs.
Recommendation: safe to proceed | investigate | likely wrong/empty DB.

Don't assume DB is valid just because WordPress loads. Don't rely only on wp_posts count.
]]

M.open_wp_database_content_audit_prompt = function()
	require("codecompanion").cli(M.wp_database_content_audit_prompt, {
		agent = "claude_code",
		submit = false,
		focus = true,
	})
end

return M
