-- ~/.config/nvim/lua/codecompanion/prompts/wordpress.lua
--
-- Generic WordPress prompt helpers for CodeCompanion.
-- Project-specific FSE/pattern conventions live in the dhali-fse skill and dhali.lua.

local M = {}

-- ─── Chat system prompt ─────────────────────────────────────────────────────

M.chat_system_prompt = function(ctx)
	return ctx.default_system_prompt
		.. [[

Additional WordPress tooling instructions:

A WordPress MCP server named `wordpress` may be available. Prefer it for small structured facts.

MCP execution rule:
- Discover abilities once per session with `mcp-adapter-discover-abilities`.
- Execute with `mcp-adapter-execute-ability` using this exact shape:
  `{ "ability_name": "namespace/ability-name", "parameters": { ... } }`
- Never use `ability_input`.
- If no relevant ability exists, say so and fall back to @wp_cli.

Use @wp_cli when MCP is unavailable, an ability is missing, or an ability returns incomplete data.
Do not print WP-CLI commands for the user to run. Use the tool.
Do not guess WordPress state or invent command output.
Use the smallest tool that answers the question.

For PHP pattern writes, MCP must pass both discovery and an execute sanity check before writing:
  dhali/lint-pattern-authoring-rules
  dhali/validate-pattern-markup
  dhali/test-pattern-in-editor-context
Also execute either dhali/get-pattern-template-skeleton or dhali/get-editor-safe-block-snippets successfully.
If any ability is missing, MCP is disconnected, or discovery works but execute fails → STOP and ask the user to reconnect MCP.

Action quick-reference (@wp_cli):
  block_overrides_audit    — full WP 7 readiness check
  active_theme             — currently active theme
  theme_list / plugin_list — installed themes/plugins
  core_version             — WordPress core version string
  templates_list           — FSE wp_template posts
  template_parts_list      — FSE wp_template_part posts
  synced_patterns_list     — synced block patterns / wp_block CPT
  global_styles_get        — compiled global stylesheet + settings from theme.json
  rest_api_namespaces      — registered REST namespaces
  content_inventory_audit  — verify restored DB has real content, not just defaults
  raw                      — arbitrary WP-CLI subcommand, no leading "wp"
]]
end

-- ─── Context sync ───────────────────────────────────────────────────────────

M.wp_mcp_context_sync_prompt = [[
Use the dhali-wordpress-context skill.

Goal:
Create or update the WordPress project context file using the WordPress MCP server first,
while minimizing token usage and avoiding broad scans.

Strict workflow:
1. Find the WordPress root.
2. Check whether a concise context file already exists:
   - {project-name}_context.md
   - context.md
3. If a concise context file exists and this is not an explicit refresh, read and report it. Do not recreate it.
4. If refresh is needed, use MCP abilities before @wp_cli.

MCP execution shape: `{ "ability_name": "...", "parameters": { ... } }` — never use `ability_input`.

Preferred MCP abilities for context (in order):
1. dhali/sync-context              { "request": "sync_context", "confirm_write": true }  — writes/updates context and injects local image asset list
2. dhali/get-project-snapshot      { "request": "project_snapshot" }                     — fallback if sync-context fails
3. dhali/get-site-info             { "request": "site_info" }
4. dhali/get-token-and-layout-map  { "request": "token_and_layout_map" }
5. dhali/get-local-assets          { "request": "get_local_assets" }                     — if image list not in context after sync
6. dhali/get-icon-manifest         { "request": "icon_manifest" }                        — only when icon guidance is needed

Fallback rules:
- Use @wp_cli only when MCP lacks the needed fact.
- Read theme.json only if the MCP token map is empty or incomplete.
- Do not scan the full pattern library.
- Do not inspect existing patterns unless the user is authoring a specific new pattern.
- Do not invent WordPress state, token slugs, file paths, or active theme details.

Output:
- Report the context file path.
- Summarize gathered facts: WordPress version, PHP version, active theme, token slug groups,
  available local image assets, MCP abilities used, any missing or fallback facts.
- Keep the response concise.
]]

M.open_wp_mcp_context_sync_prompt = function()
	require("codecompanion").cli(M.wp_mcp_context_sync_prompt, {
		agent = "claude_code",
		submit = false,
		focus = true,
	})
end

-- ─── Ollie / Dhali pattern (unified entry point) ─────────────────────────────
-- Delegates to dhali-fse skill with the same hard pre-flight gate as dhali.lua.
-- Use this from generic WordPress contexts when a pattern is needed without
-- opening the dedicated dhali.lua launcher.

M.ollie_pattern_prompt = [[
Use the dhali-fse skill.

TASK: Author a new WordPress / Ollie-compatible PHP block pattern for the dhali-pattern-library plugin.
Use the screenshot or current visual reference as the design source.

STEP 0 — MCP PRE-FLIGHT (required before reading any files or asking questions):
Call `mcp-adapter-discover-abilities`. Confirm all three validation abilities are registered:
  dhali/lint-pattern-authoring-rules
  dhali/validate-pattern-markup
  dhali/test-pattern-in-editor-context
Then prove MCP execute works with one cheap sanity call:
  dhali/get-pattern-template-skeleton { "request": "pattern_template_skeleton" }
  (or dhali/get-editor-safe-block-snippets if the pattern involves icons/SVGs/covers/fragile markup)
If any ability is missing, MCP is disconnected, or discovery works but execute fails → STOP. Tell me to reconnect MCP and do not continue.

STEP 1 — CONTEXT:
Read the project context file (check in order): {project-name}_context.md → context.md
If the file is fresh and has active theme + token slugs, skip runtime re-fetches.

STEP 2 — TARGETED MCP FETCHES (only what is missing from context):

  | Needed fact                          | MCP ability                          |
  |--------------------------------------|--------------------------------------|
  | Core/PHP/theme/layout snapshot       | dhali/get-project-snapshot           |
  | Site title or active theme name      | dhali/get-site-info                  |
  | Token slugs or layout settings       | dhali/get-token-and-layout-map       |
  | PHP return-array skeleton (always)   | dhali/get-pattern-template-skeleton  |
  | Local image filenames (if images)    | dhali/get-local-assets               |
  | Icons, SVGs, CTAs, covers, fragile   | dhali/get-editor-safe-block-snippets |
  | Known-good Ollie/Outermost icon      | dhali/get-icon-manifest              |

Use @wp_cli only when MCP does not expose the needed fact.

STEP 3 — PROPOSAL:
Show the required four-part proposal (see dhali-fse skill: Authoring Protocol).
Do not write the file until I explicitly approve.

STEP 4 — WRITE + VALIDATE (after approval):
Follow the Post-Approval Write and Validation Workflow in the dhali-fse skill exactly.
]]

M.open_ollie_pattern_prompt = function()
	require("codecompanion").cli(M.ollie_pattern_prompt, {
		agent = "claude_code",
		submit = false,
		focus = true,
	})
end

-- ─── Database content audit ─────────────────────────────────────────────────

M.wp_database_content_audit_prompt = [[
Use the @wp_cli tool with action content_inventory_audit.

Goal:
Verify whether the current WordPress database contains real site content or appears to be
a fresh/default WordPress install.

Report:
1. Verdict: likely_real_site, possibly_default_install, empty_or_missing_content, or inconclusive_small_site
2. Evidence: page/post/media/CPT counts, content character count, navigation/menu presence, default slugs found
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
