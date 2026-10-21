-- WordPress-focused CodeCompanion prompts.
-- Context lookups belong to dhali-wordpress-context, not dhali-fse.

local M = {}

M.chat_system_prompt = function(ctx)
  return ctx.default_system_prompt .. [[

For local WordPress runtime facts, prefer the connected 'wordpress' MCP.
Use {ability_name,parameters}, not ability_input. Use read-only @wp_cli fallback
for missing facts. Load only task-relevant skills and context; avoid site-wide scans.
]]
end

M.wp_mcp_context_sync_prompt = [[
Use the dhali-wordpress-context skill.
Task: explicitly sync the local WordPress context cache.
If context.md is already adequate, report it without rewriting.
Otherwise use dhali/sync-context with request=sync_context and confirm_write=true.
If unavailable, report the blocker; do not manually rewrite the file by default.
Output: context path, basic theme/runtime facts and whether it changed.
]]

M.open_wp_mcp_context_sync_prompt = function()
  require('codecompanion').cli(M.wp_mcp_context_sync_prompt,
    { agent = 'claude_code', submit = false, focus = true })
end

M.wp_database_content_audit_prompt = [[
Use @wp_cli content_inventory_audit in read-only mode.
Report verdict, key evidence (posts/pages/media/menus), and next action.
Do not infer database health merely because WordPress loads.
]]

M.open_wp_database_content_audit_prompt = function()
  require('codecompanion').cli(M.wp_database_content_audit_prompt,
    { agent = 'claude_code', submit = false, focus = true })
end

return M
