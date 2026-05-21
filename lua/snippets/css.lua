-- lua/snippets/css.lua
-- LuaSnip snippets for CSS, SCSS, and Tailwind CSS-side patterns.
-- Loaded by snippets.lua via luasnip.loaders.from_lua.
--
-- Scope:
--   "css"      → pure CSS files
--   "scss"     → standard SCSS (if not using the compound ftdetect)
--   "scss.css" → Ryan's compound filetype from ftdetect/filetype.lua
--
-- Add these filetype_extend lines to lua/config/plugins/snippets.lua:
--   require("luasnip").filetype_extend("scss",     { "css" })
--   require("luasnip").filetype_extend("scss.css", { "css", "scss" })
--   require("luasnip").filetype_extend("less",     { "css" })
--
-- Strategy: Emmet handles property/value expansion perfectly.
--   These snippets fill the gaps Emmet doesn't cover:
--   media queries, container queries, @keyframes, CSS Grid/Flex skeletons,
--   custom properties, layers, and Tailwind @apply/@layer patterns.
--
-- Breakpoints align with Tailwind's default scale

local ls = require("luasnip")
local s, t, i, f, c = ls.snippet, ls.text_node, ls.insert_node, ls.function_node, ls.choice_node

local function mirror(args)
	return args[1][1]
end

-- ── Pure CSS ──────────────────────────────────────────────────────────────────

local css_snippets = {

	-- ── _skel ──────────────────────────────────────────────────────────────────
	-- CSS file header with custom properties block.
	s({ trig = "_skel", name = "CSS file header + :root vars" }, {
		t({ "/* ==========================================================================", "   " }),
		i(1, "Component / File Description"),
		t({
			"",
			"   ========================================================================== */",
			"",
			":root {",
			"  /* Colours */",
			"  --color-primary: ",
		}),
		i(2, "#3b82f6"),
		t({ ";", "  --color-secondary: " }),
		i(3, "#64748b"),
		t({
			";",
			"",
			"  /* Spacing */",
			"  --spacing-sm: 0.5rem;",
			"  --spacing-md: 1rem;",
			"  --spacing-lg: 2rem;",
			"",
			"  /* Typography */",
			"  --font-sans: ",
		}),
		i(4, "system-ui, sans-serif"),
		t({ ";", "  --font-mono: " }),
		i(5, "monospace"),
		t({ ";", "}", "" }),
		i(0),
	}),

	-- ── vars ───────────────────────────────────────────────────────────────────
	-- :root custom properties block.
	s({ trig = "vars", name = ":root custom properties" }, {
		t({ ":root {", "  --" }),
		i(1, "property-name"),
		t(": "),
		i(2, "value"),
		t({ ";", "}" }),
	}),

	-- ── prop ───────────────────────────────────────────────────────────────────
	-- Single CSS custom property.
	s({ trig = "prop", name = "--custom-property: value" }, {
		t("--"),
		i(1, "property-name"),
		t(": "),
		i(2, "value"),
		t(";"),
	}),

	-- ── var ────────────────────────────────────────────────────────────────────
	-- var() reference with optional fallback.
	s({ trig = "var", name = "var() reference" }, {
		t("var(--"),
		i(1, "property-name"),
		c(2, {
			t(")"),
			s("", { t(", "), i(1, "fallback"), t(")") }),
		}),
	}),

	-- ── Media queries ─────────────────────────────────────────────────────────
	-- Breakpoints match Tailwind's default scale.

	-- mq: mobile-first min-width query with preset breakpoints.
	s({ trig = "mq", name = "@media min-width (mobile-first)" }, {
		t("@media ( min-width: "),
		c(1, { t("640px"), t("768px"), t("1024px"), t("1280px"), t("1536px") }),
		t({ " ) {", "  " }),
		i(0),
		t({ "", "}" }),
	}),

	-- mqmax: desktop-first max-width query.
	s({ trig = "mqmax", name = "@media max-width (desktop-first)" }, {
		t("@media ( max-width: "),
		c(1, { t("639px"), t("767px"), t("1023px"), t("1279px"), t("1535px") }),
		t({ " ) {", "  " }),
		i(0),
		t({ "", "}" }),
	}),

	-- mqrange: min AND max range query.
	s({ trig = "mqrange", name = "@media range (min + max)" }, {
		t("@media ( min-width: "),
		i(1, "768px"),
		t(" ) and ( max-width: "),
		i(2, "1023px"),
		t({ " ) {", "  " }),
		i(0),
		t({ "", "}" }),
	}),

	-- dark: prefers-color-scheme dark mode.
	s({ trig = "dark", name = "@media prefers-color-scheme dark" }, {
		t({ "@media ( prefers-color-scheme: dark ) {", "  " }),
		i(0),
		t({ "", "}" }),
	}),

	-- reduced: prefers-reduced-motion — always include for animation.
	s({ trig = "reduced", name = "@media prefers-reduced-motion" }, {
		t({ "@media ( prefers-reduced-motion: reduce ) {", "  " }),
		i(1, "/* disable transitions/animations */"),
		t({ "", "}" }),
	}),

	-- print: print stylesheet block.
	s({ trig = "print", name = "@media print" }, {
		t({ "@media print {", "  " }),
		i(0),
		t({ "", "}" }),
	}),

	-- ── Container queries ──────────────────────────────────────────────────────

	-- cq: @container query — requires container-type on parent.
	s({ trig = "cq", name = "@container query" }, {
		t("@container "),
		i(1, "sidebar"),
		t(" ( min-width: "),
		i(2, "400px"),
		t({ " ) {", "  " }),
		i(0),
		t({ "", "}" }),
	}),

	-- ctype: set container-type on the parent element.
	s({ trig = "ctype", name = "container-type (parent)" }, {
		t("container-type: "),
		c(1, { t("inline-size"), t("size"), t("normal") }),
		t(";"),
		t({ "", "container-name: " }),
		i(2, "name"),
		t(";"),
	}),

	-- ── @layer ────────────────────────────────────────────────────────────────

	-- layer: @layer block — useful for specificity management.
	s({ trig = "layer", name = "@layer block" }, {
		t("@layer "),
		c(1, { t("base"), t("components"), t("utilities"), i(nil, "layer-name") }),
		t({ " {", "  " }),
		i(0),
		t({ "", "}" }),
	}),

	-- layers: declare @layer order at top of file.
	s({ trig = "layers", name = "@layer order declaration" }, {
		t("@layer base, components, utilities;"),
	}),

	-- ── @keyframes ────────────────────────────────────────────────────────────

	-- anim: @keyframes block + animation property together.
	s({ trig = "anim", name = "@keyframes animation" }, {
		t("@keyframes "),
		i(1, "animation-name"),
		t({ " {", "  from {", "    " }),
		i(2, "opacity: 0;"),
		t({ "", "  }", "  to {", "    " }),
		i(3, "opacity: 1;"),
		t({ "", "  }", "}", "", "." }),
		i(4, "element"),
		t(" {"),
		t({ "", "  animation: " }),
		f(mirror, { 1 }),
		t(" "),
		i(5, "300ms"),
		t(" "),
		c(6, { t("ease"), t("ease-in"), t("ease-out"), t("ease-in-out"), t("linear") }),
		t({ ";", "}" }),
	}),

	-- ── Layout skeletons ───────────────────────────────────────────────────────
	-- Emmet doesn't scaffold multi-property layouts — these do.

	-- flex: Flexbox container.
	s({ trig = "flex", name = "flexbox container" }, {
		t({ "display: flex;", "align-items: " }),
		c(1, { t("center"), t("flex-start"), t("flex-end"), t("stretch"), t("baseline") }),
		t({ ";", "justify-content: " }),
		c(2, { t("flex-start"), t("center"), t("flex-end"), t("space-between"), t("space-around") }),
		t({ ";", "gap: " }),
		i(3, "1rem"),
		t(";"),
	}),

	-- grid: CSS Grid container.
	s({ trig = "grid", name = "CSS Grid container" }, {
		t({ "display: grid;", "grid-template-columns: " }),
		c(1, {
			t("repeat(auto-fit, minmax(250px, 1fr))"),
			s("", { t("repeat("), i(1, "3"), t(", 1fr)") }),
			i(nil, "custom"),
		}),
		t({ ";", "gap: " }),
		i(2, "1rem"),
		t(";"),
	}),

	-- gridarea: named grid template areas.
	s({ trig = "gridarea", name = "grid-template-areas" }, {
		t({ "grid-template-areas:", '  "' }),
		i(1, "header header"),
		t({ '"', '  "' }),
		i(2, "sidebar main"),
		t({ '"', '  "' }),
		i(3, "footer footer"),
		t({ '"', ";" }),
	}),

	-- ── @font-face ────────────────────────────────────────────────────────────

	s({ trig = "font", name = "@font-face" }, {
		t({ "@font-face {", '  font-family: "' }),
		i(1, "FontName"),
		t({ '";', "  src: url('" }),
		i(2, "fonts/font.woff2"),
		t("') format('woff2'),"),
		t({ "", "       url('" }),
		i(3, "fonts/font.woff"),
		t({ "') format('woff');", "  font-weight: " }),
		i(4, "400"),
		t({ ";", "  font-style: normal;", "  font-display: swap;", "}" }),
	}),

	-- ── Scroll snap ───────────────────────────────────────────────────────────

	s({ trig = "snapcon", name = "scroll-snap container" }, {
		t({ "overflow: auto;", "scroll-snap-type: " }),
		c(1, { t("x mandatory"), t("y mandatory"), t("both mandatory"), t("x proximity"), t("y proximity") }),
		t(";"),
	}),

	s({ trig = "snapitem", name = "scroll-snap child" }, {
		t("scroll-snap-align: "),
		c(1, { t("start"), t("center"), t("end") }),
		t(";"),
	}),

	-- ── Utility patterns ──────────────────────────────────────────────────────

	-- sr: screen-reader-only (visually hidden but accessible).
	s({ trig = "sr", name = "visually hidden / sr-only" }, {
		t({
			"position: absolute;",
			"width: 1px;",
			"height: 1px;",
			"padding: 0;",
			"margin: -1px;",
			"overflow: hidden;",
			"clip: rect(0, 0, 0, 0);",
			"white-space: nowrap;",
			"border-width: 0;",
		}),
	}),

	-- clamp: fluid typography / spacing with clamp().
	s({ trig = "clamp", name = "clamp() fluid value" }, {
		t("clamp("),
		i(1, "1rem"),
		t(", "),
		i(2, "4vw"),
		t(", "),
		i(3, "2rem"),
		t(")"),
	}),

	-- aspect: aspect-ratio shorthand.
	s({ trig = "aspect", name = "aspect-ratio" }, {
		t("aspect-ratio: "),
		c(1, { t("16 / 9"), t("4 / 3"), t("1 / 1"), t("3 / 2") }),
		t(";"),
	}),
}

-- ── Tailwind CSS-side patterns ─────────────────────────────────────────────────
-- These are useful inside .css / .scss files in a Tailwind project.
-- The Tailwind LSP handles utility class autocomplete in HTML/TSX.

local tailwind_css_snippets = {

	-- twlayer: full Tailwind @layer block.
	s({ trig = "twlayer", name = "Tailwind @layer block" }, {
		t("@layer "),
		c(1, { t("base"), t("components"), t("utilities") }),
		t({ " {", "  ." }),
		i(2, "class-name"),
		t({ " {", "    @apply " }),
		i(0),
		t({ ";", "  }", "}" }),
	}),

	-- twapply: @apply directive — compose utilities into a class.
	s({ trig = "twapply", name = "@apply Tailwind utilities" }, {
		t("@apply "),
		i(0, "flex items-center gap-2"),
		t(";"),
	}),

	-- twscreen: @screen breakpoint shorthand (Tailwind v3).
	s({ trig = "twscreen", name = "@screen breakpoint" }, {
		t("@screen "),
		c(1, { t("sm"), t("md"), t("lg"), t("xl"), t("2xl") }),
		t({ " {", "  " }),
		i(0),
		t({ "", "}" }),
	}),

	-- twbase: Tailwind base reset additions.
	s({ trig = "twbase", name = "Tailwind @layer base block" }, {
		t({ "@layer base {", "  :root {", "    " }),
		i(0),
		t({ "", "  }", "}" }),
	}),
}

-- ── SCSS-specific ─────────────────────────────────────────────────────────────
-- Register under both "scss" and "scss.css" (Ryan's compound filetype).

local scss_snippets = {

	-- use: @use (modern SCSS — replaces @import).
	s({ trig = "use", name = "@use module" }, {
		t('@use "'),
		i(1, "sass:math"),
		t('" as '),
		i(2, "math"),
		t(";"),
	}),

	-- fwd: @forward — re-export from a partial.
	s({ trig = "fwd", name = "@forward module" }, {
		t('@forward "'),
		i(1, "variables"),
		t('";'),
	}),

	-- mixin: @mixin definition with @include usage comment.
	s({ trig = "mixin", name = "@mixin definition" }, {
		t("@mixin "),
		i(1, "mixin-name"),
		t("( "),
		i(2, "$param: default"),
		t({ " ) {", "  " }),
		i(0),
		t({ "", "}", "// Usage: @include " }),
		f(mirror, { 1 }),
		t("( value );"),
	}),

	-- inc: @include a mixin.
	s({ trig = "inc", name = "@include mixin" }, {
		t("@include "),
		i(1, "mixin-name"),
		t("( "),
		i(2),
		t(" );"),
	}),

	-- func: SCSS @function.
	s({ trig = "func", name = "@function" }, {
		t("@function "),
		i(1, "function-name"),
		t("( "),
		i(2, "$param"),
		t({ " ) {", "  @return " }),
		i(0),
		t({ ";", "}" }),
	}),

	-- each: @each loop over a list/map.
	s({ trig = "each", name = "@each loop" }, {
		t("@each $"),
		i(1, "item"),
		t(" in "),
		i(2, "list"),
		t({ " {", "  " }),
		i(0),
		t({ "", "}" }),
	}),

	-- for: @for loop.
	s({ trig = "for", name = "@for loop" }, {
		t("@for $"),
		i(1, "i"),
		t(" from "),
		i(2, "1"),
		t(" through "),
		i(3, "12"),
		t({ " {", "  " }),
		i(0),
		t({ "", "}" }),
	}),

	-- if: @if / @else block.
	s({ trig = "if", name = "@if / @else" }, {
		t("@if "),
		i(1, "condition"),
		t({ " {", "  " }),
		i(2),
		t({ "", "} @else {", "  " }),
		i(0),
		t({ "", "}" }),
	}),

	-- extend: @extend a placeholder or class.
	s({ trig = "extend", name = "@extend" }, {
		t("@extend "),
		i(1, "%placeholder"),
		t(";"),
	}),

	-- placeholder: % placeholder selector (extended via @extend).
	s({ trig = "ph", name = "% placeholder selector" }, {
		t("%"),
		i(1, "placeholder-name"),
		t({ " {", "  " }),
		i(0),
		t({ "", "}" }),
	}),

	-- nparent: parent selector reference (&).
	s({ trig = "nparent", name = "& parent selector nesting" }, {
		t("&:"),
		i(1, "hover"),
		t({ " {", "  " }),
		i(0),
		t({ "", "}" }),
	}),
}

-- ── Register ──────────────────────────────────────────────────────────────────

local all_css = {}
vim.list_extend(all_css, css_snippets)
vim.list_extend(all_css, tailwind_css_snippets)

ls.add_snippets("css", all_css)

-- SCSS gets everything CSS has, plus SCSS-specific.
-- filetype_extend in snippets.lua makes "scss" and "scss.css" inherit "css",
-- so only the SCSS-specific snippets need to be registered here.
ls.add_snippets("scss", scss_snippets)
ls.add_snippets("scss.css", scss_snippets)
