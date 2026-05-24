-- ~/.config/nvim/lua/codecompanion/prompts/dhali.lua
--
-- Dhali FSE prompt launchers for CodeCompanion.
-- All conventions, token rules, and validation steps live in the dhali-fse skill.
-- Keep these prompts thin; do not duplicate skill content here.

local M = {}

-- Injected into chat-mode system prompt. Keep minimal; skill is the source of truth.
M.chat_system_prompt_addon = [[

For Dhali patterns, FSE templates, or template parts, use the dhali-fse skill.
Read context.md / {project-name}_context.md before anything else.
Use WordPress MCP abilities before @wp_cli.
Execute MCP abilities with `{ "ability_name": "...", "parameters": { ... } }`; never use `ability_input`.
Before writing any approved PHP block pattern, the three MCP validation abilities
(`dhali/lint-pattern-authoring-rules`, `dhali/validate-pattern-markup`,
`dhali/test-pattern-in-editor-context`) must be confirmed available. If any are
missing, stop and ask the user to reconnect MCP.
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

STEP 0 — MCP PRE-FLIGHT (do this before reading any files or asking questions):
Call `mcp-adapter-discover-abilities`. Confirm all three validation abilities are registered:
  dhali/lint-pattern-authoring-rules
  dhali/validate-pattern-markup
  dhali/test-pattern-in-editor-context
If any are missing or MCP is disconnected → STOP. Tell me to reconnect MCP and do not continue.

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

STEP 4 — WRITE + VALIDATE (after approval):
Follow the Post-Approval Write and Validation Workflow in the dhali-fse skill exactly.
]]

-- ─── Template ───────────────────────────────────────────────────────────────

M.dhali_template_prompt = [[
Use the dhali-fse skill.

TASK: Author a new FSE HTML template for the dhali-pattern-library plugin.
Use the description, CPT name, screenshot, selected buffer content, or current visual reference
to determine the template purpose and WordPress hierarchy slug.

STEP 0 — MCP PRE-FLIGHT:
Call `mcp-adapter-discover-abilities`. Confirm validation abilities are registered.
If MCP is disconnected or abilities are missing → STOP. Ask me to reconnect MCP.

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
Call `mcp-adapter-discover-abilities`. Confirm validation abilities are registered.
If MCP is disconnected or abilities are missing → STOP. Ask me to reconnect MCP.

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
