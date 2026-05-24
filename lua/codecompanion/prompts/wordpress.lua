-- ~/.config/nvim/lua/codecompanion/prompts/wordpress.lua
--
-- Generic WordPress prompt helpers for CodeCompanion.
-- Keep project-specific FSE/pattern conventions in the dhali-fse skill and dhali.lua.

local M = {}

M.chat_system_prompt = function(ctx)
	return ctx.default_system_prompt
		.. [[

Additional WordPress tooling instructions:

A WordPress MCP server named `wordpress` may be available. Prefer it for small structured WordPress facts when the needed ability exists.

MCP execution rule:
- First call `mcp-adapter-discover-abilities` once per session/task when ability availability is unknown.
- Inspect the relevant ability with `mcp-adapter-get-ability-info` only if the schema is unknown.
- Execute with `mcp-adapter-execute-ability` using exactly this top-level input shape:
  `{ "ability_name": "namespace/ability-name", "parameters": { ... } }`
- Never use `ability_input`; the execute tool requires `parameters`.
- If no relevant ability exists, say the MCP server is connected but the needed WordPress ability is not registered.

Preferred MCP abilities:
  dhali/get-site-info                 — active theme + site title
  dhali/get-project-snapshot          — core/PHP/theme/layout snapshot
  dhali/get-token-and-layout-map      — token slugs + layout settings
  dhali/get-pattern-template-skeleton — PHP pattern return-array skeleton
  dhali/get-icon-manifest             — Ollie/Outermost icon block skeletons
  dhali/get-editor-safe-block-snippets — known-good snippets for fragile editor blocks
  dhali/lint-pattern-authoring-rules  — project-specific editor-safety lint
  dhali/validate-pattern-markup       — parse generated block markup after writing
  dhali/test-pattern-in-editor-context — draft page/post editor-context smoke test
  dhali/sync-context                  — write/update context.md when explicitly syncing

Use @wp_cli when:
- MCP is unavailable
- the needed ability is missing
- an MCP ability returns incomplete data, such as empty token arrays
- the task needs deep DB/content inventory not covered by MCP

Do not print WP-CLI commands and ask the user to run them.
Do not guess WordPress state or invent command output.
Use the smallest tool that can answer the question.
For PHP pattern writes, MCP validation availability is mandatory before writing: confirm `dhali/lint-pattern-authoring-rules`, `dhali/validate-pattern-markup`, and `dhali/test-pattern-in-editor-context` are available, or stop and ask the user to reconnect MCP.

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

M.wp_mcp_context_sync_prompt = [[
Use the dhali-wordpress-context skill.

Goal:
Create or update the WordPress project context file using the WordPress MCP server named `wordpress` first, while minimizing token usage and avoiding broad scans.

Strict workflow:
1. Find the WordPress root.
2. Check whether a concise context file already exists:
   - {project-name}_context.md
   - context.md
3. If a concise context file exists and the task is not explicitly a refresh, read it and report it. Do not recreate it.
4. If refresh is needed, use MCP abilities before @wp_cli.

MCP execution rule:
- First call `mcp-adapter-discover-abilities`.
- Inspect relevant abilities only if needed.
- Execute abilities with `mcp-adapter-execute-ability`.
- Always use this exact input shape:
  `{ "ability_name": "namespace/ability-name", "parameters": { ... } }`
- Never use `ability_input`.

Preferred MCP abilities for context:
1. `dhali/get-project-snapshot` with `{ "request": "project_snapshot" }`
2. `dhali/get-site-info` with `{ "request": "site_info" }`
3. `dhali/get-token-and-layout-map` with `{ "request": "token_and_layout_map" }`
4. `dhali/get-icon-manifest` with `{ "request": "icon_manifest" }` only when icon guidance is needed
5. `dhali/sync-context` with `{ "request": "sync_context", "confirm_write": true }` when the goal is to write/update the cache

Fallback rules:
- Use @wp_cli only when the needed fact is not available through MCP.
- Read theme.json only if the MCP token map is empty or incomplete.
- Do not scan the full pattern library.
- Do not inspect existing patterns unless the user is authoring a specific new pattern.
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
  - any missing or fallback facts
- Keep the response concise.
]]

M.open_wp_mcp_context_sync_prompt = function()
	require("codecompanion").cli(M.wp_mcp_context_sync_prompt, {
		agent = "claude_code",
		submit = false,
		focus = true,
	})
end

M.ollie_pattern_prompt = [[
Use the ollie-pattern-builder skill.

Use the attached screenshot or current visual reference as the design source.

Before reading many project files, read the existing project context file from the WordPress root if it exists.
When asking WordPress for facts through MCP, execute abilities with `{ "ability_name": "...", "parameters": { ... } }`; never use `ability_input`.
Use cached conventions first; refresh only the target filename list and missing/stale token facts.

Generate a WordPress 7 / Ollie-compatible PHP block pattern.

Requirements:
- Use core blocks unless unavoidable.
- Match the existing PHP return-array pattern style.
- Execute `dhali/get-pattern-template-skeleton` before drafting the PHP return array.
- Enforce Ollie/theme preset slugs exactly; do not invent semantic color aliases.
- Prefer theme presets for spacing, colors, shadows, typography, and layout.
- Avoid custom CSS unless necessary.
- First show inferred layout, block tree, proposed filename, and complete PHP content.
- Do not write files until I approve.
- After approval, run PHP lint, MCP `dhali/lint-pattern-authoring-rules`, MCP `dhali/validate-pattern-markup`, and MCP `dhali/test-pattern-in-editor-context` when available; do not claim success unless all available checks pass.
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
