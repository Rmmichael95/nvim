-- ~/.config/nvim/lua/codecompanion/prompts/dhali.lua
--
-- Dhali FSE prompt launchers for CodeCompanion.
-- All conventions, token rules, and validation steps live in the dhali-fse skill.
-- Keep these prompts thin; do not duplicate skill content here.

local M = {}

-- Injected into chat-mode system prompt. Keep minimal; skill is the source of truth.
M.chat_system_prompt_addon = [[

For Dhali patterns, FSE templates, or template parts, use the dhali-fse skill.
For authoring tasks, run MCP pre-flight before reading files or context.
MCP pre-flight means both discovery and a cheap execute sanity check must succeed.
Use WordPress MCP abilities before @wp_cli.
Execute MCP abilities with `{ "ability_name": "...", "parameters": { ... } }`; never use `ability_input`.

Default to static visual pattern authoring. Do not create Query Loop, post-template, or dynamic
post blocks unless the user explicitly asks for them.

Before writing any approved PHP block pattern, the two fast-validation abilities
(`dhali/lint-pattern-authoring-rules`, `dhali/validate-pattern-markup`) must be confirmed available.
Also execute `dhali/get-pattern-template-skeleton` or `dhali/get-editor-safe-block-snippets` successfully.
If discovery works but execute fails, stop and ask the user to reconnect MCP.
]]

local function open_cli_prompt(prompt)
	require("codecompanion").cli(prompt, {
		agent = "claude_code",
		submit = false,
		focus = true,
	})
end

-- ─── Pattern ────────────────────────────────────────────────────────────────

M.dhali_pattern_prompt = [[
Use the dhali-fse skill.

TASK: Author a new PHP block pattern for the dhali-pattern-library plugin.
Use the screenshot, description, selected buffer content, or current visual reference as the design source.

DEFAULT: Build a static visual pattern. Do not create Query Loop, post-template, or dynamic post
blocks unless I explicitly ask for them. A screenshot containing image, category, date, title, and
read-more is a static visual source, not a request for dynamic post output.

STEP 0 — MCP PRE-FLIGHT (do this before reading any files or asking questions):
Call `mcp-adapter-discover-abilities`. Confirm the two fast-validation abilities are registered:
  dhali/lint-pattern-authoring-rules
  dhali/validate-pattern-markup
Then prove MCP execute works with one cheap sanity call:
  dhali/get-pattern-template-skeleton { "request": "pattern_template_skeleton" }
  (or dhali/get-editor-safe-block-snippets if the pattern involves icons/SVGs/covers/fragile markup)
If any ability is missing, MCP is disconnected, or discovery works but execute fails → STOP. Tell me to reconnect MCP. Do not proceed.

STEP 1 — CONTEXT:
Read the project context file if it exists (check in order): {project-name}_context.md → context.md
If the file is fresh and has active theme + token slugs, do not re-fetch runtime facts.

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
Inspect existing files only for filename collision or nearby style match.

STEP 3 — PROPOSAL:
Show the required four-part proposal (see dhali-fse skill: Authoring Protocol). Keep it concise.
Do not write the file until I explicitly approve.

STEP 4 — WRITE + FAST VALIDATE (after approval):
Follow the Post-Approval Write and Validation Workflow in the dhali-fse skill.
Use fast validation by default. Run editor-context validation only when the skill's
deep-validation triggers apply (including always for core/query and core/post-template)
or I explicitly ask for it.
]]

-- ─── Convert Static Pattern to Query Loop ───────────────────────────────────

M.dhali_query_loop_convert_prompt = [[
Use the dhali-fse skill.

TASK: Convert an approved static block pattern into a Query Loop / Post Template pattern.

PRE-CONDITIONS (verify before starting):
1. Confirm the approved static pattern exists and has been reviewed.
   Ask me to identify the source pattern file if not already clear.
2. The approved static pattern is the source of truth. Do not redesign.
   Preserve all spacing, radius, image treatment, badge placement, typography, shadow, and CTA structure.

STEP 0 — MCP PRE-FLIGHT:
Call `mcp-adapter-discover-abilities`. Confirm the two fast-validation abilities are registered:
  dhali/lint-pattern-authoring-rules
  dhali/validate-pattern-markup
Then prove MCP execute works:
  dhali/get-pattern-template-skeleton { "request": "pattern_template_skeleton" }
If any ability is missing or execute fails → STOP. Tell me to reconnect MCP.

STEP 1 — READ THE SOURCE PATTERN:
Read the approved static pattern file. Do not begin conversion until you have confirmed the full
static structure including image treatment, overlay containment, badge placement, and CTA structure.

STEP 2 — MAP STATIC TO DYNAMIC:
Map each static block to its post block equivalent:
  - Static image / Cover → core/post-featured-image (note: cannot contain inner blocks)
  - Static heading → core/post-title
  - Static date paragraph → core/post-date
  - Static category → core/post-terms
  - Static excerpt → core/post-excerpt
  - Static read-more → core/read-more

If a dynamic block cannot reproduce an overlay or containment from the static card
(e.g. badge inside core/post-featured-image), STOP and explain the limitation.
Do not silently move the badge below the image.

STEP 3 — PROPOSAL:
Show the required four-part proposal. Identify any visual limitations of the dynamic conversion.
Do not write the file until I explicitly approve.

STEP 4 — WRITE + DEEP VALIDATE:
core/query and core/post-template always require editor-context validation.
After fast validation passes, run dhali/test-pattern-in-editor-context.

MCP execute shape: `{ "ability_name": "...", "parameters": { ... } }` — never use `ability_input`.
]]

-- ─── Template ───────────────────────────────────────────────────────────────

M.dhali_template_prompt = [[
Use the dhali-fse skill.

TASK: Author a new FSE HTML template for the dhali-pattern-library plugin.
Use the description, CPT name, screenshot, selected buffer content, or current visual reference
to determine the template purpose and WordPress hierarchy slug.

STEP 0 — MCP PRE-FLIGHT:
Call `mcp-adapter-discover-abilities`. Confirm the two fast-validation abilities are registered:
  dhali/lint-pattern-authoring-rules
  dhali/validate-pattern-markup
Then prove MCP execute works:
  dhali/get-pattern-template-skeleton { "request": "pattern_template_skeleton" }
If MCP is disconnected, abilities are missing, or discovery works but execute fails → STOP. Ask me to reconnect MCP.

STEP 1 — CONTEXT: Read the project context file.
STEP 2 — TARGETED MCP FETCHES: Refresh only what is missing from context.
STEP 3 — PROPOSAL: Show the required four-part proposal. Do not write until I approve.
STEP 4 — WRITE + VALIDATE: Follow the skill's Post-Approval Workflow.

MCP execute shape: `{ "ability_name": "...", "parameters": { ... } }` — never use `ability_input`.
]]

-- ─── Template Part ──────────────────────────────────────────────────────────

M.dhali_part_prompt = [[
Use the dhali-fse skill.

TASK: Author a new HTML template part.
Use the description, screenshot, selected buffer content, or current visual reference
to determine the part purpose, name, and destination.

STEP 0 — MCP PRE-FLIGHT:
Call `mcp-adapter-discover-abilities`. Confirm the two fast-validation abilities are registered:
  dhali/lint-pattern-authoring-rules
  dhali/validate-pattern-markup
Then prove MCP execute works:
  dhali/get-pattern-template-skeleton { "request": "pattern_template_skeleton" }
If MCP is disconnected, abilities are missing, or discovery works but execute fails → STOP. Ask me to reconnect MCP.

STEP 1 — CONTEXT: Read the project context file.
STEP 2 — TARGETED MCP FETCHES: Refresh only what is missing from context.
STEP 3 — PROPOSAL: Show the required four-part proposal. Do not write until I approve.
STEP 4 — WRITE + VALIDATE: Follow the skill's Post-Approval Workflow.

MCP execute shape: `{ "ability_name": "...", "parameters": { ... } }` — never use `ability_input`.
]]

-- ─── Launchers ──────────────────────────────────────────────────────────────

M.open_dhali_pattern_prompt = function()
	open_cli_prompt(M.dhali_pattern_prompt)
end

M.open_dhali_query_loop_convert_prompt = function()
	open_cli_prompt(M.dhali_query_loop_convert_prompt)
end

M.open_dhali_template_prompt = function()
	open_cli_prompt(M.dhali_template_prompt)
end

M.open_dhali_part_prompt = function()
	open_cli_prompt(M.dhali_part_prompt)
end

return M
