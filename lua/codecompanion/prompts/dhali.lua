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
Before writing any approved PHP block pattern, the two fast-validation abilities
(`dhali/lint-pattern-authoring-rules`, `dhali/validate-pattern-markup`) must be confirmed available. Also execute
`dhali/get-pattern-template-skeleton` or `dhali/get-editor-safe-block-snippets`
successfully. If discovery works but execute fails, stop and ask the user to reconnect MCP.
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
If the source is a post list/card grid, use the Query Loop fast path and native post blocks; do not fetch Cover/icon snippets unless the pattern actually uses them.

STEP 0 — MCP PRE-FLIGHT (do this before reading any files or asking questions):
Call `mcp-adapter-discover-abilities`. Confirm the two fast-validation abilities are registered:
  dhali/lint-pattern-authoring-rules
  dhali/validate-pattern-markup
Then prove MCP execute works with one cheap sanity call:
  dhali/get-pattern-template-skeleton { "request": "pattern_template_skeleton" }
or, if the pattern involves icons/SVGs/CTAs/covers/fragile markup:
  dhali/get-editor-safe-block-snippets { "request": "editor_safe_block_snippets" }
If any ability is missing, MCP is disconnected, or discovery works but execute fails → STOP. Tell me to reconnect MCP and do not continue.

STEP 1 — CONTEXT:
Read the project context file if it exists (check in order):
  {project-name}_context.md → context.md
If the file is fresh and has active theme + token slugs, do not re-fetch runtime facts.

STEP 2 — TARGETED MCP FETCHES (only what is missing from context):
Use this decision table — skip any fetch whose data is already in context.md:

  | Needed fact                          | MCP ability                          |
  |--------------------------------------|--------------------------------------|
  | Core/PHP/theme/layout snapshot       | dhali/get-project-snapshot           |
  | Site title or active theme name      | dhali/get-site-info                  |
  | Token slugs or layout settings       | dhali/get-token-and-layout-map       |
  | PHP return-array skeleton (always)   | dhali/get-pattern-template-skeleton  |
  | Icons, SVGs, CTAs, covers, fragile   | dhali/get-editor-safe-block-snippets |
  | Known-good Ollie/Outermost icon      | dhali/get-icon-manifest              |

Use @wp_cli only when MCP does not expose the needed fact.
Inspect existing files only for filename collision or nearby style match.

STEP 3 — PROPOSAL:
Show the required four-part proposal (see dhali-fse skill: Authoring Protocol).
Do not write the file until I explicitly approve.

STEP 4 — WRITE + FAST VALIDATE (after approval):
Follow the Post-Approval Write and Validation Workflow in the dhali-fse skill. Use fast validation by default; run editor-context validation only when the skill's deep-validation triggers apply or I explicitly ask for it.
]]

-- ─── Template ───────────────────────────────────────────────────────────────

M.dhali_template_prompt = [[
Use the dhali-fse skill.

TASK: Author a new FSE HTML template for the dhali-pattern-library plugin.
Use the description, CPT name, screenshot, selected buffer content, or current visual reference
to determine the template purpose and WordPress hierarchy slug.

STEP 0 — MCP PRE-FLIGHT:
Call `mcp-adapter-discover-abilities`. Confirm the two fast-validation abilities are registered.
Then execute `dhali/get-pattern-template-skeleton` with `{ "request": "pattern_template_skeleton" }` to prove MCP execute works.
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
Call `mcp-adapter-discover-abilities`. Confirm the two fast-validation abilities are registered.
Then execute `dhali/get-pattern-template-skeleton` with `{ "request": "pattern_template_skeleton" }` to prove MCP execute works.
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

M.open_dhali_template_prompt = function()
	open_cli_prompt(M.dhali_template_prompt)
end

M.open_dhali_part_prompt = function()
	open_cli_prompt(M.dhali_part_prompt)
end

return M
