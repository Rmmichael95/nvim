-- lua/snippets/markdown.lua
-- LuaSnip snippet definitions for markdown files.
-- Loaded by snippets.lua via luasnip.loaders.from_lua.
-- BufNewFile skeleton expansion is handled in autocmds.lua.
--
-- DO NOT put autocmds, keymaps, or vim.api calls here.
--
-- Covers the gaps between friendly-snippets' basic markdown and the full
-- render-markdown.nvim + marksman + markdownlint-cli2 setup:
--
--   render-markdown.nvim callout types (all 9 configured variants)
--   render-markdown.nvim custom checkbox states [~] and [-]
--   Mermaid diagram fences (rendered by render-markdown.nvim)
--   marksman wiki-link syntax [[page]] and [[page|Title]]
--   markdown-toc <!-- toc --> marker (triggers the conform formatter)
--   <details>/<kbd> HTML (MD033 is disabled in .markdownlint-cli2.yaml)
--   Table templates beyond the basic friendly-snippets version
--   YAML frontmatter field additions

local ls = require("luasnip")
local s, t, i, f, c = ls.snippet, ls.text_node, ls.insert_node, ls.function_node, ls.choice_node

ls.add_snippets("markdown", {

	-- ══════════════════════════════════════════════════════════════════════════
	-- FRONTMATTER
	-- ══════════════════════════════════════════════════════════════════════════

	-- _skel: YAML frontmatter — auto-fires on BufNewFile via autocmds.lua.
	-- filename evaluated at expand time (wrapped in f() to avoid load-time capture).
	s({ trig = "_skel", name = "YAML frontmatter skeleton" }, {
		t({ "---", "title: " }),
		f(function()
			return vim.fn.expand("%:t:r")
		end),
		t({
			"",
			"author: Ryan M Sullivan",
			"date: " .. os.date("%Y-%m-%d"),
			"tags: []",
			"---",
			"",
			"",
		}),
		i(0),
	}),

	-- fmtag: add a tags field entry — useful when editing existing frontmatter.
	s({ trig = "fmtag", name = "frontmatter tags list" }, {
		t("tags: ["),
		i(1, "tag1, tag2"),
		t("]"),
	}),

	-- fmdate: today's date in YYYY-MM-DD — for frontmatter or inline.
	s({ trig = "fmdate", name = "today's date YYYY-MM-DD" }, {
		t(os.date("%Y-%m-%d")),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- CALLOUT BLOCKS
	-- Matches render-markdown.nvim callout config exactly.
	-- Syntax: > [!TYPE] on the first line, subsequent lines are > content.
	-- ══════════════════════════════════════════════════════════════════════════

	-- note: 󰋽 Note callout
	s({ trig = "note", name = "> [!NOTE] callout" }, {
		t({ "> [!NOTE]", "> " }),
		i(0, "Highlights information the reader should take into account."),
	}),

	-- tip: 󰌶 Tip callout
	s({ trig = "tip", name = "> [!TIP] callout" }, {
		t({ "> [!TIP]", "> " }),
		i(0, "Optional information to help a user be more successful."),
	}),

	-- imp: 󰅾 Important callout
	s({ trig = "imp", name = "> [!IMPORTANT] callout" }, {
		t({ "> [!IMPORTANT]", "> " }),
		i(0, "Crucial information necessary for users to succeed."),
	}),

	-- warn: 󰀪 Warning callout
	s({ trig = "warn", name = "> [!WARNING] callout" }, {
		t({ "> [!WARNING]", "> " }),
		i(0, "Critical content demanding immediate user attention."),
	}),

	-- caut: 󰳦 Caution callout
	s({ trig = "caut", name = "> [!CAUTION] callout" }, {
		t({ "> [!CAUTION]", "> " }),
		i(0, "Negative potential consequences of an action."),
	}),

	-- abst: 󰨸 Abstract callout
	s({ trig = "abst", name = "> [!ABSTRACT] callout" }, {
		t({ "> [!ABSTRACT]", "> " }),
		i(0, "Summary of the content below."),
	}),

	-- todo: 󰗡 Todo callout
	s({ trig = "todoc", name = "> [!TODO] callout" }, {
		t({ "> [!TODO]", "> " }),
		i(0, "Action item or outstanding task."),
	}),

	-- ques: 󰘥 Question callout
	s({ trig = "ques", name = "> [!QUESTION] callout" }, {
		t({ "> [!QUESTION]", "> " }),
		i(0, "Question requiring an answer or decision."),
	}),

	-- callout: generic callout with type choice — when you want to pick at expand time.
	s({ trig = "callout", name = "callout (choose type)" }, {
		t("> [!"),
		c(1, {
			t("NOTE"),
			t("TIP"),
			t("IMPORTANT"),
			t("WARNING"),
			t("CAUTION"),
			t("ABSTRACT"),
			t("TODO"),
			t("QUESTION"),
		}),
		t({ "]", "> " }),
		i(0),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- TASK LIST / CHECKBOXES
	-- Matches render-markdown.nvim checkbox config:
	--   [ ] unchecked  󰄱   (standard)
	--   [x] checked    󰱒   (standard)
	--   [~] in_progress 󰥔  (custom — RenderMarkdownTodo highlight)
	--   [-] cancelled  󰅙   (custom — RenderMarkdownError highlight)
	-- ══════════════════════════════════════════════════════════════════════════

	-- tcp: task in progress [~]
	s({ trig = "tcp", name = "task in progress [~]" }, {
		t("- [~] "),
		i(0, "In progress task"),
	}),

	-- tcc: task cancelled [-]
	s({ trig = "tcc", name = "task cancelled [-]" }, {
		t("- [-] "),
		i(0, "Cancelled task"),
	}),

	-- tcu: task unchecked [ ]
	s({ trig = "tcu", name = "task unchecked [ ]" }, {
		t("- [ ] "),
		i(0, "Task to do"),
	}),

	-- tcx: task checked [x]
	s({ trig = "tcx", name = "task checked [x]" }, {
		t("- [x] "),
		i(0, "Completed task"),
	}),

	-- tasklist: full task list block with all four states.
	s({ trig = "tasklist", name = "task list with all states" }, {
		t({ "- [ ] " }),
		i(1, "Todo"),
		t({ "", "- [~] " }),
		i(2, "In progress"),
		t({ "", "- [x] " }),
		i(3, "Done"),
		t({ "", "- [-] " }),
		i(0, "Cancelled"),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- CODE FENCES
	-- friendly-snippets has ``` but not with language or content.
	-- ══════════════════════════════════════════════════════════════════════════

	-- cf: fenced code block with language — mdsf will format it on save.
	s({ trig = "cf", name = "fenced code block" }, {
		t("```"),
		c(1, {
			t("bash"),
			t("lua"),
			t("typescript"),
			t("javascript"),
			t("python"),
			t("sql"),
			t("css"),
			t("json"),
			t("yaml"),
			t("rust"),
			t("php"),
			t("csharp"),
			t("cpp"),
			i(nil, "lang"),
		}),
		t({ "", "" }),
		i(0),
		t({ "", "```" }),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- MERMAID DIAGRAMS
	-- render-markdown.nvim renders mermaid fences visually.
	-- mdsf will format the mermaid code block on save.
	-- ══════════════════════════════════════════════════════════════════════════

	-- mermaid: bare mermaid fence with diagram type choice.
	s({ trig = "mermaid", name = "mermaid diagram fence" }, {
		t("```mermaid"),
		t({ "", "" }),
		c(1, {
			s("", { t({ "graph TD", "    " }), i(1, "A[Start] --> B[End]") }),
			s("", { t({ "sequenceDiagram", "    " }), i(1, "Alice->>Bob: Hello") }),
			s("", { t({ "flowchart LR", "    " }), i(1, "A --> B") }),
			s("", { t({ "classDiagram", "    " }), i(1, "class Animal") }),
			s("", { t({ "erDiagram", "    " }), i(1, "CUSTOMER ||--o{ ORDER : places") }),
			s("", { t({ "gantt", "    dateFormat YYYY-MM-DD", "    " }), i(1, "section Tasks") }),
			s("", { t({ "pie", "    title Distribution", '    "A" : 60', '    "B" : 40' }) }),
			s("", { t({ "gitGraph", "    commit", "    branch feature", "    commit" }) }),
		}),
		t({ "", "```" }),
	}),

	-- merflow: quick flowchart.
	s({ trig = "merflow", name = "mermaid flowchart" }, {
		t({ "```mermaid", "flowchart " }),
		c(1, { t("TD"), t("LR"), t("BT"), t("RL") }),
		t({ "", "    " }),
		i(2, "A"),
		t("["),
		i(3, "Start"),
		t("] --> "),
		i(4, "B"),
		t("["),
		i(5, "End"),
		t("]"),
		t({ "", "    " }),
		i(0),
		t({ "", "```" }),
	}),

	-- merseq: sequence diagram.
	s({ trig = "merseq", name = "mermaid sequence diagram" }, {
		t({ "```mermaid", "sequenceDiagram", "    " }),
		i(1, "Client"),
		t("->>"),
		i(2, "Server"),
		t(": "),
		i(3, "Request"),
		t({ "", "    " }),
		f(function(args)
			return args[1][1]
		end, { 2 }),
		t("-->>"),
		f(function(args)
			return args[1][1]
		end, { 1 }),
		t(": "),
		i(4, "Response"),
		t({ "", "```" }),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- LINKS — marksman wiki-link syntax
	-- ══════════════════════════════════════════════════════════════════════════

	-- wl: [[wiki-link]] — marksman go-to-def works on these.
	s({ trig = "wl", name = "[[wiki-link]]" }, {
		t("[["),
		i(1, "page-name"),
		t("]]"),
	}),

	-- wlt: [[wiki-link|Display Title]] — wiki-link with custom title.
	s({ trig = "wlt", name = "[[wiki-link|Title]]" }, {
		t("[["),
		i(1, "page-name"),
		t("|"),
		i(2, "Display Title"),
		t("]]"),
	}),

	-- lnk: standard markdown link — [text](url).
	s({ trig = "lnk", name = "[text](url) link" }, {
		t("["),
		i(1, "link text"),
		t("]("),
		i(2, "https://"),
		t(")"),
	}),

	-- lnkr: reference-style link — [text][ref] + [ref]: url at bottom.
	s({ trig = "lnkr", name = "reference-style link" }, {
		t("["),
		i(1, "text"),
		t("]["),
		i(2, "ref"),
		t("]"),
		t({ "", "", "[" }),
		f(function(args)
			return args[1][1]
		end, { 2 }),
		t("]: "),
		i(3, "https://"),
		t(' "'),
		i(4, "Title"),
		t('"'),
	}),

	-- img: image with alt text.
	s({ trig = "img", name = "![alt](url) image" }, {
		t("!["),
		i(1, "alt text"),
		t("]("),
		i(2, "image.png"),
		t(")"),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- TABLES
	-- MD013 off so wide tables are fine; MD033 off so HTML tables allowed.
	-- ══════════════════════════════════════════════════════════════════════════

	-- tbl: pipe table with alignment row — 3 columns.
	s({ trig = "tbl", name = "pipe table (3 columns)" }, {
		t("| "),
		i(1, "Header 1"),
		t(" | "),
		i(2, "Header 2"),
		t(" | "),
		i(3, "Header 3"),
		t(" |"),
		t({ "", "| " }),
		c(4, { t("---"), t(":---"), t("---:"), t(":---:") }),
		t(" | "),
		c(5, { t("---"), t(":---"), t("---:"), t(":---:") }),
		t(" | "),
		c(6, { t("---"), t(":---"), t("---:"), t(":---:") }),
		t(" |"),
		t({ "", "| " }),
		i(7, "Row 1 Col 1"),
		t(" | "),
		i(8, "Row 1 Col 2"),
		t(" | "),
		i(0, "Row 1 Col 3"),
		t(" |"),
	}),

	-- tbl2: 2-column table — common for key/value docs.
	s({ trig = "tbl2", name = "pipe table (2 columns key/value)" }, {
		t("| "),
		i(1, "Key"),
		t(" | "),
		i(2, "Value"),
		t(" |"),
		t({ "", "| --- | --- |" }),
		t({ "", "| " }),
		i(3, "key1"),
		t(" | "),
		i(4, "value1"),
		t(" |"),
		t({ "", "| " }),
		i(0, "key2"),
		t(" | "),
		t("value2"),
		t(" |"),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- DOCUMENT STRUCTURE
	-- ══════════════════════════════════════════════════════════════════════════

	-- toc: <!-- toc --> marker — triggers markdown-toc conform formatter.
	s({ trig = "toc", name = "<!-- toc --> table of contents marker" }, {
		t({ "<!-- toc -->", "<!-- tocstop -->" }),
	}),

	-- details: <details> / <summary> block — MD033 is disabled so this is safe.
	s({ trig = "details", name = "<details> disclosure widget" }, {
		t("<details>"),
		t({ "", "<summary>" }),
		i(1, "Click to expand"),
		t("</summary>"),
		t({ "", "", "" }),
		i(0),
		t({ "", "", "</details>" }),
	}),

	-- kbd: <kbd> keyboard shortcut — MD033 disabled.
	s({ trig = "kbd", name = "<kbd> keyboard shortcut" }, {
		t("<kbd>"),
		i(1, "Ctrl"),
		t("</kbd>"),
		t(" + "),
		t("<kbd>"),
		i(2, "C"),
		t("</kbd>"),
	}),

	-- badge: shields.io badge link — common in READMEs.
	s({ trig = "badge", name = "shields.io badge" }, {
		t("[!["),
		i(1, "label"),
		t("](https://img.shields.io/badge/"),
		i(2, "label-value-color"),
		t(")]("),
		i(3, "https://link-url"),
		t(")"),
	}),

	-- hr: horizontal rule — markdownlint enforces ---.
	s({ trig = "hr", name = "horizontal rule ---" }, {
		t({ "", "---", "" }),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- HEADING SHORTCUTS
	-- friendly-snippets covers h1-h6 but these add anchored heading+anchor patterns.
	-- ══════════════════════════════════════════════════════════════════════════

	-- h2l: ## heading with a marksman-compatible anchor ID.
	s({ trig = "h2l", name = "## heading with anchor id" }, {
		t("## "),
		i(1, "Heading"),
		t(" {#"),
		i(2, "anchor-id"),
		t("}"),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- FOOTNOTES (GitHub Flavored Markdown)
	-- ══════════════════════════════════════════════════════════════════════════

	-- fn: inline footnote reference + definition pair.
	s({ trig = "fn", name = "footnote reference + definition" }, {
		t("[^"),
		i(1, "1"),
		t("]"),
		t({ "", "", "[^" }),
		f(function(args)
			return args[1][1]
		end, { 1 }),
		t("]: "),
		i(0, "Footnote text."),
	}),
})
