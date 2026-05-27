-- dhali.lua — Dhali FSE pattern prompts for CodeCompanion.
-- Procedure here. Rules in dhali-fse skill. Reference in plugin snippet files + live MCP.

local M = {}

M.chat_system_prompt_addon = [[
dhali-fse skill governs all pattern rules. execute: {ability_name,parameters}. never ability_input.
]]

local function cli(p)
	require("codecompanion").cli(p, { agent = "claude_code", submit = false, focus = true })
end

M.dhali_pattern_prompt = [[
Skill: dhali-fse. Task: new PHP block pattern for dhali-pattern-library.

STATIC ONLY — no dynamic blocks unless user says: "Query Loop" "dynamic posts" "latest posts" "archive" "post template" "convert to dynamic".

─── STEP 0: PRE-FLIGHT ───────────────────────────────────────────────────────
1. mcp-adapter-discover-abilities
2. confirm registered: dhali/lint-pattern-authoring-rules, dhali/validate-pattern-markup
3. sanity execute: dhali/get-plugin-paths {"request":"plugin_paths"}
FAIL → STOP. reconnect MCP.

─── STEP 1: CONTEXT + CLASSIFY ───────────────────────────────────────────────
Read context.md. Read design source (~/pictures/blocks/).
State type + 2-3 visual signals:

  hero        large heading, bg image/color, CTA buttons, full-width
  cta         heading + buttons, no card, no image
  feature-grid  3+ columns, icon+heading+text each
  testimonial  quote, stars, avatar, name/role
  pricing     price amount, ✓ list, tier columns, CTA
  card        single card, shadow/radius, image+content
  contact     business info, hours, social links, photo
  post-card   date, category, title, read more
  intro       text only or text+small image, no card, no CTA
  other       unclassifiable

Then call: dhali/get-pattern-approach {"pattern_type":"TYPE"}
Response gives: block_tree, required_mcp, deep_validation, ollie_slugs. Follow it.

─── STEP 2: FETCHES ──────────────────────────────────────────────────────────
Fetch only what get-pattern-approach.required_mcp says, minus what's in context.

  plugin paths (always)    → dhali/get-plugin-paths
  image+icon+snippet list  → dhali/get-local-assets
  token slugs/layout       → dhali/get-token-and-layout-map
  named icon SVG           → dhali/get-icon-manifest

Snippet files — read with @wp_cli raw cat PLUGIN_PATH/snippets/FILENAME.html:
  cover-with-badge.html   → cover with top-only radius, badge pill overlay (WP7-verified)
  plus-cta.html           → linked group circle plus CTA (WP7-verified)
  flex-vertical.html      → flex card shell, vertical layout
  flex-horizontal.html    → horizontal flex row
  flex-space-between.html → horizontal flex, heading left / element right
  card-shadow.html        → constrained card with radius + shadow
  social-links.html       → core/social-links row, logos-only, centered

Icon rule: get-local-assets returns icon_selection_guide.
  check.svg=lists/confirmations  arrow-right.svg=CTAs/nav  plus.svg=add actions
  question.svg=DEFAULT  image.svg=media  user.svg=person
Read chosen file: @wp_cli raw cat PLUGIN_PATH/assets/icons/FILE.svg
Embed in outermost/icon-block iconName:"". Never core/html for icons.

Check filename collisions before proposing.

─── STEP 3: PROPOSAL (no write until Approved) ───────────────────────────────
1. Type + visual signals.
2. Block tree (hierarchy + layout decisions only).
3. Full destination path.
4. PHP payload:
   - viewportWidth:1500
   - esc_html__() for all text in content string
   - plugin_dir_url(dirname(__FILE__)).'assets/...' for all assets
   - outermost group: align:full + metadata{name,categories,patternName} + margin top/bottom:0
   - placeholder text only — "This is a title" / "This is an example of paragraph text"
   - social icons: core/social-links + core/social-link, not question.svg

─── STEP 4: WRITE + VALIDATE (after Approved) ────────────────────────────────
Reconfirm MCP. Write file.

Fast (stop on failure): php -l → dhali/lint-pattern-authoring-rules → dhali/validate-pattern-markup

Deep — always for: core/cover, outermost/icon-block+SVG, linked core/group (href/animationType).
Also follow get-pattern-approach.deep_validation for this type.

Skip: "Fast validation passed. Editor-context validation skipped — no required trigger. Manual editor check recommended."
]]

M.dhali_query_loop_convert_prompt = [[
Skill: dhali-fse. Task: convert approved static pattern to Query Loop.

Pre: identify source file. approved static = source of truth, no redesign.
STEP 0: confirm dhali/lint-pattern-authoring-rules + dhali/validate-pattern-markup registered + execute. FAIL → STOP.
STEP 1: read source pattern fully. confirm image treatment, badge placement, CTA structure.
STEP 2 map:
  image/Cover → core/post-featured-image (no inner blocks — badge overlay not possible)
  heading → core/post-title  |  date → core/post-date  |  category → core/post-terms
  excerpt → core/post-excerpt  |  read-more → core/read-more
If dynamic block can't reproduce overlay → STOP + explain. no silent moves.
STEP 3: proposal + visual limitations. no write until Approved.
STEP 4: core/query + core/post-template → always run dhali/test-pattern-in-editor-context.
]]

M.open_dhali_pattern_prompt = function()
	cli(M.dhali_pattern_prompt)
end
M.open_dhali_query_loop_convert_prompt = function()
	cli(M.dhali_query_loop_convert_prompt)
end

return M
