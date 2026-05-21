-- lua/snippets/html.lua
-- LuaSnip snippets for HTML files.
-- Loaded by snippets.lua via luasnip.loaders.from_lua.
--
-- Filetype: html
-- Also active in PHP buffers via filetype_extend("php", { "html" }) in snippets.lua.
-- Emmet is already configured for html/php — these snippets complement it for
-- structural boilerplate and semantic patterns Emmet doesn't cover well.
--
-- Indentation: 2 spaces (matches prettier HTML config in mdsf.json).

local ls = require("luasnip")
local s, t, i, f, c = ls.snippet, ls.text_node, ls.insert_node, ls.function_node, ls.choice_node

local function mirror(args)
	return args[1][1]
end

ls.add_snippets("html", {

	-- ── _skel ─────────────────────────────────────────────────────────────────
	-- Full HTML5 document boilerplate.
	-- add a BufNewFile *.html autocmd to auto-fire this (see autocmds.lua).
	s({ trig = "_skel", name = "HTML5 document boilerplate" }, {
		t({ "<!DOCTYPE html>", '<html lang="' }),
		i(1, "en"),
		t({
			'">',
			"<head>",
			'  <meta charset="UTF-8" />',
			'  <meta name="viewport" content="width=device-width, initial-scale=1.0" />',
			'  <meta name="description" content="',
		}),
		i(2, "Page description"),
		t({ '" />', "  <title>" }),
		i(3, "Document Title"),
		t({ "</title>", "</head>", "<body>", "  " }),
		i(0),
		t({ "", "</body>", "</html>" }),
	}),

	-- ── Semantic structure ────────────────────────────────────────────────────

	s({ trig = "hdr", name = "<header>" }, {
		t({ '<header class="' }),
		i(1, "site-header"),
		t({ '">', "  " }),
		i(0),
		t({ "", "</header>" }),
	}),

	s({ trig = "nav", name = "<nav>" }, {
		t('<nav class="'),
		i(1, "site-nav"),
		t({ '">', "  <ul>", '    <li><a href="' }),
		i(2, "#"),
		t('">'),
		i(3, "Link"),
		t({ "</a></li>", "  </ul>", "</nav>" }),
	}),

	s({ trig = "main", name = "<main>" }, {
		t('<main class="'),
		i(1, "site-main"),
		t({ '">', "  " }),
		i(0),
		t({ "", "</main>" }),
	}),

	s({ trig = "sec", name = "<section>" }, {
		t('<section class="'),
		i(1, "section-name"),
		t({ '">', "  " }),
		i(0),
		t({ "", "</section>" }),
	}),

	s({ trig = "art", name = "<article>" }, {
		t('<article class="'),
		i(1, "article"),
		t({ '">', "  " }),
		i(0),
		t({ "", "</article>" }),
	}),

	s({ trig = "asd", name = "<aside>" }, {
		t('<aside class="'),
		i(1, "sidebar"),
		t({ '">', "  " }),
		i(0),
		t({ "", "</aside>" }),
	}),

	s({ trig = "ftr", name = "<footer>" }, {
		t('<footer class="'),
		i(1, "site-footer"),
		t({ '">', "  " }),
		i(0),
		t({ "", "</footer>" }),
	}),

	-- ── Content elements ──────────────────────────────────────────────────────

	s({ trig = "div", name = "<div> with class" }, {
		t('<div class="'),
		i(1, "container"),
		t({ '">', "  " }),
		i(0),
		t({ "", "</div>" }),
	}),

	s({ trig = "span", name = "<span> with class" }, {
		t('<span class="'),
		i(1),
		t('">'),
		i(0),
		t("</span>"),
	}),

	s({ trig = "p", name = "<p> with class" }, {
		t('<p class="'),
		i(1),
		t('">'),
		i(0),
		t("</p>"),
	}),

	-- ── Media ─────────────────────────────────────────────────────────────────

	s({ trig = "img", name = "<img> with alt" }, {
		t('<img src="'),
		i(1, "image.jpg"),
		t('" alt="'),
		i(2, "Descriptive alt text"),
		t('" width="'),
		i(3, "800"),
		t('" height="'),
		i(4, "600"),
		t('" loading="'),
		c(5, { t("lazy"), t("eager") }),
		t('" />'),
	}),

	s({ trig = "fig", name = "<figure> with <figcaption>" }, {
		t({ "<figure>", '  <img src="' }),
		i(1, "image.jpg"),
		t('" alt="'),
		i(2, "Alt text"),
		t({ '" />', "  <figcaption>" }),
		i(3, "Caption text"),
		t({ "</figcaption>", "</figure>" }),
	}),

	s({ trig = "vid", name = "<video>" }, {
		t('<video src="'),
		i(1, "video.mp4"),
		t('" '),
		c(2, { t("controls"), t("controls autoplay muted loop") }),
		t({ ">", "  <p>Your browser does not support the video element.</p>", "</video>" }),
	}),

	-- ── Links ─────────────────────────────────────────────────────────────────

	s({ trig = "a", name = "<a> link" }, {
		t('<a href="'),
		i(1, "#"),
		t('"'),
		c(2, { t(""), t(' target="_blank" rel="noopener noreferrer"') }),
		t(">"),
		i(3, "Link text"),
		t("</a>"),
	}),

	s({ trig = "lnk", name = "<link> stylesheet" }, {
		t('<link rel="stylesheet" href="'),
		i(1, "style.css"),
		t('" />'),
	}),

	s({ trig = "scrpt", name = "<script>" }, {
		c(1, {
			s("", { t('<script src="'), i(1, "script.js"), t('" defer></script>') }),
			s("", { t({ "<script>", "  " }), i(1), t({ "", "</script>" }) }),
		}),
	}),

	-- ── Forms ─────────────────────────────────────────────────────────────────

	s({ trig = "frm", name = "<form>" }, {
		t('<form action="'),
		i(1, "#"),
		t('" method="'),
		c(2, { t("post"), t("get") }),
		t({ '">', "  " }),
		i(0),
		t({ "", '  <button type="submit">Submit</button>', "</form>" }),
	}),

	-- Input with label — id links label and input.
	s({ trig = "inp", name = "<input> with <label>" }, {
		t('<label for="'),
		i(1, "field-name"),
		t('">'),
		i(2, "Label"),
		t({ "</label>", '<input type="' }),
		c(3, {
			t("text"),
			t("email"),
			t("password"),
			t("number"),
			t("tel"),
			t("url"),
			t("hidden"),
			t("checkbox"),
			t("radio"),
		}),
		t('" id="'),
		f(mirror, { 1 }),
		t('" name="'),
		f(mirror, { 1 }),
		t('" placeholder="'),
		i(4),
		t('" />'),
	}),

	s({ trig = "txta", name = "<textarea> with <label>" }, {
		t('<label for="'),
		i(1, "field-name"),
		t('">'),
		i(2, "Label"),
		t({ "</label>", '<textarea id="' }),
		f(mirror, { 1 }),
		t('" name="'),
		f(mirror, { 1 }),
		t('" rows="'),
		i(3, "4"),
		t({ '"></textarea>' }),
	}),

	s({ trig = "sel", name = "<select> with options" }, {
		t('<label for="'),
		i(1, "field-name"),
		t('">'),
		i(2, "Label"),
		t({ "</label>", '<select id="' }),
		f(mirror, { 1 }),
		t('" name="'),
		f(mirror, { 1 }),
		t({ '">', '  <option value="">Select...</option>', '  <option value="' }),
		i(3, "value"),
		t('">'),
		i(4, "Option"),
		t({ "</option>", "</select>" }),
	}),

	s({ trig = "btn", name = "<button>" }, {
		t('<button type="'),
		c(1, { t("button"), t("submit"), t("reset") }),
		t('" class="'),
		i(2),
		t('">'),
		i(3, "Button text"),
		t("</button>"),
	}),

	-- ── Tables ────────────────────────────────────────────────────────────────

	s({ trig = "tbl", name = "<table> with thead and tbody" }, {
		t({ "<table>", "  <thead>", "    <tr>", "      <th>" }),
		i(1, "Heading 1"),
		t({ "</th>", "      <th>" }),
		i(2, "Heading 2"),
		t({ "</th>", "    </tr>", "  </thead>", "  <tbody>", "    <tr>", "      <td>" }),
		i(3, "Cell 1"),
		t({ "</td>", "      <td>" }),
		i(4, "Cell 2"),
		t({ "</td>", "    </tr>", "  </tbody>", "</table>" }),
	}),

	-- ── Lists ─────────────────────────────────────────────────────────────────

	s({ trig = "ul", name = "<ul> list" }, {
		t({ "<ul>", "  <li>" }),
		i(1, "Item"),
		t({ "</li>", "  <li>" }),
		i(0),
		t({ "</li>", "</ul>" }),
	}),

	s({ trig = "ol", name = "<ol> list" }, {
		t({ "<ol>", "  <li>" }),
		i(1, "Item"),
		t({ "</li>", "  <li>" }),
		i(0),
		t({ "</li>", "</ol>" }),
	}),

	-- ── Details / Summary (disclosure widget) ─────────────────────────────────

	s({ trig = "dtl", name = "<details> with <summary>" }, {
		t({ "<details>", "  <summary>" }),
		i(1, "Summary heading"),
		t({ "</summary>", "  " }),
		i(0),
		t({ "", "</details>" }),
	}),

	-- ── Meta tags ─────────────────────────────────────────────────────────────

	s({ trig = "meta", name = "<meta> tag" }, {
		t('<meta name="'),
		i(1, "name"),
		t('" content="'),
		i(2, "content"),
		t('" />'),
	}),

	s({ trig = "ogmeta", name = "Open Graph meta tags" }, {
		t({ '<meta property="og:title" content="' }),
		i(1, "Page Title"),
		t({ '" />', '<meta property="og:description" content="' }),
		i(2, "Page description"),
		t({ '" />', '<meta property="og:image" content="' }),
		i(3, "https://example.com/image.jpg"),
		t({ '" />', '<meta property="og:url" content="' }),
		i(4, "https://example.com"),
		t({ '" />', '<meta property="og:type" content="website" />' }),
	}),
})
