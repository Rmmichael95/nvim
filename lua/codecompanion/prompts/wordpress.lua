-- ~/.config/nvim/lua/codecompanion/prompts/wordpress.lua

local M = {}

M.chat_system_prompt = function(ctx)
	return ctx.default_system_prompt
		.. [[

Additional WordPress tooling instructions:

A WordPress tool (@wp_cli) is available. Use it proactively whenever the user asks about:
- The current WordPress install, environment, or version
- Active theme, installed themes/plugins
- WordPress 7 readiness or upgrade planning
- Block theme support, theme.json, global styles
- FSE templates or template parts (use templates_list / template_parts_list)
- Block overrides, block bindings, or Interactivity API support
- Synced patterns / reusable blocks (use synced_patterns_list)
- Font Library (wp_font_face, wp_font_family)
- REST API namespaces or registered endpoints (use rest_api_namespaces)
- Any WP-CLI output the user wants without running it themselves

Do not print WP-CLI commands and ask the user to run them.
Do not guess WordPress state or invent command output.
Use the tool to gather facts first, then reason from the result.

Action quick-reference:
  block_overrides_audit    — full WP 7 readiness check
  active_theme             — currently active theme
  theme_list / plugin_list — all installed themes or plugins
  core_version             — WP core version string
  templates_list           — FSE wp_template posts
  template_parts_list      — FSE wp_template_part posts
  synced_patterns_list     — synced block patterns / wp_block CPT
  global_styles_get        — compiled global stylesheet + settings from theme.json
  rest_api_namespaces      — all REST namespaces registered on this install
  raw                      — arbitrary WP-CLI subcommand, no leading "wp"
]]
end

M.ollie_pattern_prompt = [[
Use the ollie-pattern-builder skill.

Use the attached screenshot or current visual reference as the design source.

Read the existing pattern files in this Ollie theme and infer the project's pattern conventions.

Generate a WordPress 7 / Ollie-compatible PHP block pattern.

Requirements:
- Use core blocks unless unavoidable.
- Match the existing PHP return-array pattern style.
- Prefer theme presets for spacing, colors, shadows, typography, and layout.
- Avoid custom CSS unless necessary.
- First show:
  1. inferred layout
  2. block tree
  3. proposed filename
  4. complete PHP pattern content

Do not write files until I approve.
]]

M.open_ollie_pattern_prompt = function()
	require("codecompanion").cli(M.ollie_pattern_prompt, {
		agent = "claude_code",
		submit = false,
		focus = true,
	})
end

return M
