-- ~/.config/nvim/lua/codecompanion/prompts/dhali.lua
--
-- Dhali FSE prompt launchers for CodeCompanion.
-- Keep detailed conventions in the dhali-fse skill, not in these prompts.

local M = {}

M.chat_system_prompt_addon = [[

Dhali FSE instructions:

For Dhali patterns, FSE templates, or template parts:
- Use the dhali-fse skill as the source of detailed conventions.
- Use the shortest reliable context path: existing [project-name]_context.md first, then WordPress MCP abilities, then @wp_cli, then targeted file reads.
- Do not reread the full pattern library unless the requested output requires matching a nearby existing file.
- Prefer the WordPress MCP server named `wordpress` for fast WordPress facts when available.
- Execute MCP abilities with `{ "ability_name": "namespace/ability-name", "parameters": { ... } }`; never use `ability_input`.
- Known fast abilities:
  - `dhali/get-site-info` with `{ "request": "site_info" }`
  - `dhali/get-project-snapshot` with `{ "request": "project_snapshot" }`
  - `dhali/get-token-and-layout-map` with `{ "request": "token_and_layout_map" }`
  - `dhali/get-pattern-template-skeleton` with `{ "request": "pattern_template_skeleton" }`
  - `dhali/get-icon-manifest` with `{ "request": "icon_manifest" }`
  - `dhali/validate-pattern-markup` with `{ "markup": "..." }`
  - `dhali/sync-context` with `{ "request": "sync_context", "confirm_write": true }` only when context refresh is explicitly part of the task.
- Use @wp_cli only for facts not covered by MCP or for broad audits.
- Enforce Ollie/theme preset slugs exactly as listed in theme.json/context/MCP token map.
- Do not invent color aliases such as accent, navy, light, or dark unless those exact slugs exist.
- Do not print WP-CLI commands for the user to run. Use the tool.
]]

local function open_cli_prompt(prompt)
	require("codecompanion").cli(prompt, {
		agent = "claude_code",
		submit = false,
		focus = true,
	})
end

M.dhali_pattern_prompt = [[
Use the dhali-fse skill.

TASK: Author a new PHP block pattern for the dhali-pattern-library plugin.

Use the screenshot, description, selected buffer content, or current visual reference as the design source.

Fast workflow:
1. Read [project-name]_context.md from the WordPress root only if it exists and is concise.
2. Refresh missing runtime/token facts through WordPress MCP, not broad file scans:
   - `dhali/get-project-snapshot` with `{ "request": "project_snapshot" }`
   - `dhali/get-token-and-layout-map` with `{ "request": "token_and_layout_map" }`
   - `dhali/get-pattern-template-skeleton` with `{ "request": "pattern_template_skeleton" }`
   - `dhali/get-icon-manifest` with `{ "request": "icon_manifest" }` only for icon/custom SVG work.
3. Use @wp_cli only when MCP does not expose the needed fact.
4. Inspect existing files only when filename/style collision or nearby pattern style matters.
5. Show the required four-part proposal.
6. Do not write the file until I explicitly approve.

MCP execute shape is always `{ "ability_name": "...", "parameters": { ... } }`; never use `ability_input`.
]]

M.dhali_template_prompt = [[
Use the dhali-fse skill.

TASK: Author a new FSE HTML template for the dhali-pattern-library plugin.

Use the description, CPT name, screenshot, selected buffer content, or current visual reference to determine the template purpose and WordPress hierarchy slug.

Fast workflow:
1. Read [project-name]_context.md from the WordPress root only if it exists and is concise.
2. Refresh missing runtime/token facts through WordPress MCP: `dhali/get-project-snapshot` and `dhali/get-token-and-layout-map`.
3. Use @wp_cli only for template/template-part inventory or facts MCP does not expose.
4. Inspect only the closest existing template examples.
5. Show the required four-part proposal.
6. Do not write the file until I explicitly approve.

MCP execute shape is always `{ "ability_name": "...", "parameters": { ... } }`; never use `ability_input`.
]]

M.dhali_part_prompt = [[
Use the dhali-fse skill.

TASK: Author a new HTML template part.

Use the description, screenshot, selected buffer content, or current visual reference to determine the part purpose, name, and destination.

Fast workflow:
1. Read [project-name]_context.md from the WordPress root only if it exists and is concise.
2. Refresh missing runtime/token facts through WordPress MCP: `dhali/get-project-snapshot` and `dhali/get-token-and-layout-map`.
3. Use `dhali/get-icon-manifest` only for icon/custom SVG work.
4. Use @wp_cli only for template-part inventory or facts MCP does not expose.
5. Inspect only the closest existing part examples.
6. Show the required four-part proposal.
7. Do not write the file until I explicitly approve.

MCP execute shape is always `{ "ability_name": "...", "parameters": { ... } }`; never use `ability_input`.
]]

M.open_dhali_pattern_prompt = function()
	open_cli_prompt(M.dhali_pattern_prompt)
end

M.open_dhali_template_prompt = function()
	open_cli_prompt(M.dhali_template_prompt)
end

M.open_dhali_part_prompt = function()
	open_cli_prompt(M.dhali_part_prompt)
end

return M
