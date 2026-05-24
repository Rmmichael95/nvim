-- ~/.config/nvim/lua/codecompanion/prompts/dhali.lua
--
-- Dhali FSE prompt launchers for CodeCompanion.
-- Keep detailed conventions in the dhali-fse skill, not in these prompts.

local M = {}

M.chat_system_prompt_addon = [[

Dhali FSE instructions:

For Dhali patterns, FSE templates, or template parts:
- Use the dhali-fse skill as the source of detailed conventions.
- Read the existing project context file first when present: {project-name}_context.md, then context.md.
- Use WordPress MCP abilities before @wp_cli for small live facts.
- Execute MCP abilities with `{ "ability_name": "...", "parameters": { ... } }`; never use `ability_input`.
- Only refresh missing or task-critical context; do not reread the full pattern library every run.
- Enforce Ollie/theme preset slugs exactly as listed in theme.json/context/MCP token map.
- Do not invent color aliases such as primary, secondary, accent, navy, light, or dark unless those exact slugs exist.
- Do not print WP-CLI commands for the user to run. Use the tool.
- Before writing any approved PHP block pattern, confirm MCP validation tools are connected and available: `dhali/lint-pattern-authoring-rules`, `dhali/validate-pattern-markup`, and `dhali/test-pattern-in-editor-context`. If unavailable, stop before writing. Run PHP lint and all MCP checks after writing. If the pattern contains generated SVG art, prefer `core/html`; avoid generated `outermost/icon-block` custom SVGs.
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
1. Read the existing project context file from the WordPress root if it exists and is concise:
   - {project-name}_context.md
   - context.md
2. Refresh missing runtime/token facts through WordPress MCP, not broad file scans:
   - `dhali/get-project-snapshot` with `{ "request": "project_snapshot" }`
   - `dhali/get-site-info` with `{ "request": "site_info" }`
   - `dhali/get-token-and-layout-map` with `{ "request": "token_and_layout_map" }` only if token facts are missing/stale
   - `dhali/get-pattern-template-skeleton` with `{ "request": "pattern_template_skeleton" }` for every new PHP pattern
   - `dhali/get-editor-safe-block-snippets` with `{ "request": "editor_safe_block_snippets" }` for icons, generated SVGs, plus CTAs, cover/image cards, or fragile editor markup
   - `dhali/get-icon-manifest` with `{ "request": "icon_manifest" }` only for known-good Ollie/Outermost icon work
3. Use @wp_cli only when MCP does not expose the needed fact.
4. Inspect existing files only when filename/style collision or nearby pattern style matters.
5. Show the required four-part proposal.
6. Do not write the file until I explicitly approve.

MCP execute shape is always `{ "ability_name": "...", "parameters": { ... } }`; never use `ability_input`.

Validation availability gate after approval:
1. Reconnect/check the WordPress MCP server before writing.
2. Confirm these abilities exist: `dhali/lint-pattern-authoring-rules`, `dhali/validate-pattern-markup`, and `dhali/test-pattern-in-editor-context`.
3. If MCP is disconnected or any required validation ability is missing, stop before writing and ask me to reconnect MCP. Do not write a file and then say validation was skipped.

Validation gate after MCP availability is confirmed:
1. Write the file.
2. Run PHP lint on the written file.
3. Run MCP authoring lint using `dhali/lint-pattern-authoring-rules` with `{ "request": "lint_pattern_authoring_rules", "markup": "BLOCK_MARKUP_HERE", "context": "standalone" }`.
4. Validate the generated block markup through MCP using `dhali/validate-pattern-markup` with `{ "markup": "BLOCK_MARKUP_HERE" }`.
5. Run MCP editor-context smoke test using `dhali/test-pattern-in-editor-context` with `{ "request": "test_pattern_in_editor_context", "markup": "BLOCK_MARKUP_HERE", "post_type": "page", "context": "standalone" }`.
6. If any check fails, fix the file and rerun all checks.
7. Do not claim the pattern is ready unless all checks pass.

Icon/SVG safety:
- Do not put placeholder comments inside final SVG markup.
- Do not generate custom `outermost/icon-block` SVG markup from scratch.
- Use `outermost/icon-block` only when copying known-good editor-saved markup or a trusted manifest snippet.
- For AI-generated decorative SVGs, use `core/html` with inline SVG instead of `outermost/icon-block`.
- For circular plus CTAs, use `core/buttons` + `core/button` with text `+`, not `outermost/icon-block`.
- Do not output empty SVG shells for named icons. Named icons must include the saved SVG path.
- Do not use CSS variables in `iconColorValue` or `iconBackgroundColorValue`; preserve editor-resolved values such as `#fbb042` or `#ffffff` when using copied editor markup.
- Preserve hardcoded values that came from editor-saved markup. Do not normalize them unless explicitly asked.

Image/cover safety:
- Do not use `core/cover` with `useFeaturedImage:true` for standalone screenshot-based cards.
- Do not write `id:0`, `wp-image-0`, remote placeholder image URLs, or generated block-level `style.css` such as `"css":"overflow:hidden;"`.
- Use static `core/image` or static `core/cover` only with a real media URL/id/sizeSlug or known-good editor-copied markup, unless the user explicitly asks for Query Loop/post-template context.
- If no real image asset is known, ask for the image URL/id before writing the final pattern.
]]

M.dhali_template_prompt = [[
Use the dhali-fse skill.

TASK: Author a new FSE HTML template for the dhali-pattern-library plugin.

Use the description, CPT name, screenshot, selected buffer content, or current visual reference to determine the template purpose and WordPress hierarchy slug.

Workflow:
1. Read the existing project context file from the WordPress root if it exists.
2. Refresh only task-critical context through MCP first, then @wp_cli only if MCP lacks the fact.
3. Show the required four-part proposal.
4. Do not write the file until I explicitly approve.
5. After approval, validate file syntax/markup as appropriate before claiming success.

MCP execute shape is always `{ "ability_name": "...", "parameters": { ... } }`; never use `ability_input`.
]]

M.dhali_part_prompt = [[
Use the dhali-fse skill.

TASK: Author a new HTML template part.

Use the description, screenshot, selected buffer content, or current visual reference to determine the part purpose, name, and destination.

Workflow:
1. Read the existing project context file from the WordPress root if it exists.
2. Refresh only task-critical context through MCP first, then @wp_cli only if MCP lacks the fact.
3. Show the required four-part proposal.
4. Do not write the file until I explicitly approve.
5. After approval, validate file syntax/markup as appropriate before claiming success.

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
