-- ~/.config/nvim/lua/codecompanion/prompts/dhali.lua
--
-- Dhali FSE prompt launchers for CodeCompanion.
-- Keep detailed conventions in the dhali-fse skill, not in these prompts.

local M = {}

M.chat_system_prompt_addon = [[

Dhali FSE instructions:

For Dhali patterns, FSE templates, or template parts:
- Use the dhali-fse skill as the source of detailed conventions.
- First look for context.md in the WordPress project root.
- If the context file exists, read it before reading theme/plugin files.
- Only refresh missing or task-critical context; do not reread the full pattern library every run.
- Use @wp_cli for WordPress facts instead of guessing.
- Enforce Ollie/theme preset slugs exactly as listed in theme.json/context.
- Do not invent color aliases such as primary, secondary, accent, navy, light, or dark unless those exact slugs exist.
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

Workflow:
1. Read context.md from the WordPress root if it exists.
2. Refresh only task-critical context required by the dhali-fse skill.
3. Save/update context.md with any newly discovered facts.
4. Show the required four-part proposal.
5. Do not write the file until I explicitly approve.
]]

M.dhali_template_prompt = [[
Use the dhali-fse skill.

TASK: Author a new FSE HTML template for the dhali-pattern-library plugin.

Use the description, CPT name, screenshot, selected buffer content, or current visual reference to determine the template purpose and WordPress hierarchy slug.

Workflow:
1. Read context.md from the WordPress root if it exists.
2. Refresh only task-critical context required by the dhali-fse skill.
3. Save/update context.md with any newly discovered facts.
4. Show the required four-part proposal.
5. Do not write the file until I explicitly approve.
]]

M.dhali_part_prompt = [[
Use the dhali-fse skill.

TASK: Author a new HTML template part.

Use the description, screenshot, selected buffer content, or current visual reference to determine the part purpose, name, and destination.

Workflow:
1. Read context.md from the WordPress root if it exists.
2. Refresh only task-critical context required by the dhali-fse skill.
3. Save/update context.md with any newly discovered facts.
4. Show the required four-part proposal.
5. Do not write the file until I explicitly approve.
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
