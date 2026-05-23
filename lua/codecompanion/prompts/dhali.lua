-- ~/.config/nvim/lua/codecompanion/prompts/dhali.lua
--
-- Dhali FSE prompts for CodeCompanion.
--
-- Provides:
--   chat_system_prompt_addon  — appended to Gemini chat system prompt
--   dhali_pattern_prompt      — ACP prompt: author a PHP block pattern
--   dhali_template_prompt     — ACP prompt: author an FSE HTML template
--   dhali_part_prompt         — ACP prompt: author an HTML template part
--   open_*                    — opener functions bound to keymaps
--
-- Usage in codecompanion.lua:
--
--   system_prompt = function(ctx)
--     return require("codecompanion.prompts.wordpress").chat_system_prompt(ctx)
--       .. require("codecompanion.prompts.dhali").chat_system_prompt_addon
--   end
--
--   keys = {
--     { "<leader>adp", function() require("codecompanion.prompts.dhali").open_dhali_pattern_prompt()  end, desc = "Dhali: make pattern"  },
--     { "<leader>adt", function() require("codecompanion.prompts.dhali").open_dhali_template_prompt() end, desc = "Dhali: make template" },
--     { "<leader>adr", function() require("codecompanion.prompts.dhali").open_dhali_part_prompt()     end, desc = "Dhali: make part"     },
--   }

local M = {}

-- ─────────────────────────────────────────────────────────────────────────────
-- Gemini chat addon
-- Appended to the existing wordpress.lua chat_system_prompt so Gemini knows
-- which wp_cli actions to use when the user asks Dhali-specific questions.
-- ─────────────────────────────────────────────────────────────────────────────

M.chat_system_prompt_addon = [[

Dhali FSE tooling instructions:

When the user asks about Dhali patterns, FSE templates, or template parts, use @wp_cli
proactively to gather facts before answering or planning.

Relevant actions:
  active_theme          — confirm theme slug, child/parent paths, and FSE directory presence
  global_styles_get     — get compiled color, spacing, shadow tokens from theme.json
  templates_list        — list FSE wp_template records registered in the database
  template_parts_list   — list FSE wp_template_part records registered in the database
  synced_patterns_list  — list any synced block patterns (wp_block CPT)
  raw                   — use for Dhali-specific checks, e.g.:
                            eval 'echo json_encode(glob(WP_PLUGIN_DIR."/dhali-pattern-library/patterns/*.php"));'
                            eval 'echo json_encode(glob(WP_PLUGIN_DIR."/dhali-pattern-library/templates/*.html"));'
                            plugin list --format=json

Before suggesting a new pattern filename or template slug:
  - Check existing patterns/ glob to avoid name collisions.
  - Check existing templates/ glob to confirm the slug does not already exist.
  - Confirm dhali-pattern-library plugin is active via plugin list.

For color tokens, always verify slugs from global_styles_get rather than guessing.
Known slugs include custom-color-1 through custom-color-6, base, border-light, main —
but the canonical source is theme.json.

Do not suggest custom CSS for values that have preset token equivalents.
Do not write WP-CLI commands for the user to run. Use the tool.
]]

-- ─────────────────────────────────────────────────────────────────────────────
-- ACP prompt strings
-- Sent to Claude Code via require("codecompanion").cli().
-- Each is a complete instruction set — Claude Code reads the skill for the
-- detailed conventions; the prompt defines the task and workflow guard.
-- ─────────────────────────────────────────────────────────────────────────────

M.dhali_pattern_prompt = [[
Load and follow the dhali-fse skill.

TASK: Author a new PHP block pattern for the dhali-pattern-library plugin.

CONTEXT GATHERING (do this first, in order):
1. Find the WordPress root by looking for wp-config.php above the cwd.
2. Read theme.json from the active theme to get the canonical color and spacing token slugs.
3. List existing patterns/ in the dhali-pattern-library plugin directory.
4. Read 2-3 existing pattern PHP files to calibrate indentation, animationType usage,
   and how preset tokens are referenced in this project.

DESIGN SOURCE:
Use the screenshot, description, or selected buffer content as the visual/functional
reference for the new pattern.

OUTPUT — show all four before writing anything:
1. Inferred layout — describe the visual structure in plain English
2. Block tree — indented list of block names and key attributes only
3. Proposed filename — dhali-pattern-library/patterns/{name}.php
4. Complete PHP content — full return array with all content inline

RULES:
- categories must include dhali-web-development plus one matching WP core category.
- Prefer theme preset tokens over hardcoded hex or pixel values.
- Do not add animationType to every block — use it for section headings and card groups.
- Do not use ollieCustomClasses names that are not already in dhali-classes.css.
- Do not write the file until I explicitly approve.

AFTER APPROVAL:
Write the file, then run: php -l dhali-pattern-library/patterns/{name}.php
Report the result.
]]

M.dhali_template_prompt = [[
Load and follow the dhali-fse skill.

TASK: Author a new FSE HTML template for the dhali-pattern-library plugin.

CONTEXT GATHERING (do this first, in order):
1. Find the WordPress root by looking for wp-config.php above the cwd.
2. Read theme.json from the active (Ollie) theme to confirm token slugs and available
   template parts.
3. List existing templates/ in the dhali-pattern-library plugin directory.
4. Read 1-2 existing template HTML files to calibrate pretty-print style and how
   Ollie template parts (header, footer) are referenced.
5. List existing parts/ in the Ollie theme directory to know which parts are available
   for inclusion via wp:template-part.

DESIGN SOURCE:
Use the description, CPT name, screenshot, or selected buffer content to determine the
template's purpose and slug.

SLUG RULES — confirm the correct WordPress hierarchy slug:
  single-{post-type}.html  →  singular CPT view
  archive-{post-type}.html →  CPT archive listing
  page-{slug}.html         →  specific page by slug
  index.html               →  fallback
  404.html / search.html   →  system templates

OUTPUT — show all four before writing anything:
1. Template purpose — what page/post type this serves and why
2. Block tree — indented hierarchy showing header part → main content → footer part
3. Proposed filename — dhali-pattern-library/templates/{slug}.html
4. Complete HTML content — full pretty-printed block markup

RULES:
- Always open with the Ollie header part: wp:template-part {"slug":"header","theme":"ollie","area":"header"}
- Always close with the Ollie footer part: wp:template-part {"slug":"footer","theme":"ollie","area":"uncategorized"}
- Wrap the page body in wp:group with "tagName":"main".
- Use wp:post-content for singular templates unless a custom layout replaces it.
- Use wp:mfb/meta-field-block for ACF field display.
- Use blockVisibility controlSets for conditionally hidden blocks.
- Do not write the file until I explicitly approve.

AFTER APPROVAL:
Write the file.
Then verify: grep -c '<!-- wp:' {file} and grep -c '<!-- /wp:' {file}
Self-closing blocks should be excluded from the closing count. Report any mismatch.
]]

M.dhali_part_prompt = [[
Load and follow the dhali-fse skill.

TASK: Author a new HTML template part.

CONTEXT GATHERING (do this first, in order):
1. Find the WordPress root by looking for wp-config.php above the cwd.
2. Read theme.json from the active (Ollie) theme to confirm token slugs.
3. List existing parts/ in the Ollie theme and/or child theme directory.
4. Read 1-2 existing part HTML files to calibrate the pretty-print style and block depth.

DESIGN SOURCE:
Use the description, screenshot, or selected buffer content to determine the part's
purpose, name, and which templates will reference it.

OUTPUT — show all four before writing anything:
1. Part purpose — what section this represents and which templates will use it
2. Block tree — indented hierarchy of blocks
3. Proposed filename and destination path — {theme}/parts/{name}.html
4. Complete HTML content — full pretty-printed block markup

RULES:
- Template parts are pure HTML block markup. No PHP.
- Do not wrap the part in wp:template-part — the file IS the part content.
- The area value when referencing this part from a template:
    header/footer → use the matching area slug
    everything else → "area":"uncategorized"
- Prefer theme preset tokens. Avoid inline CSS for preset-covered values.
- Do not write the file until I explicitly approve.

AFTER APPROVAL:
Write the file to the correct parts/ directory.
Then verify: grep -c '<!-- wp:' {file} and grep -c '<!-- /wp:' {file}
Report any unclosed block mismatch.
]]

-- ─────────────────────────────────────────────────────────────────────────────
-- Opener functions
-- Each opens a Claude Code ACP session with the prompt pre-filled.
-- submit = false means Claude Code shows the prompt for review before sending.
-- ─────────────────────────────────────────────────────────────────────────────

M.open_dhali_pattern_prompt = function()
	require("codecompanion").cli(M.dhali_pattern_prompt, {
		agent = "claude_code",
		submit = false,
		focus = true,
	})
end

M.open_dhali_template_prompt = function()
	require("codecompanion").cli(M.dhali_template_prompt, {
		agent = "claude_code",
		submit = false,
		focus = true,
	})
end

M.open_dhali_part_prompt = function()
	require("codecompanion").cli(M.dhali_part_prompt, {
		agent = "claude_code",
		submit = false,
		focus = true,
	})
end

return M
