-- lua/snippets/graphql.lua
-- LuaSnip snippets for GraphQL schema definition files (.graphql / .gql).
-- Loaded by snippets.lua via luasnip.loaders.from_lua.
--
-- Filetype: graphql (matches *.graphql, *.gql)
-- GraphQL client snippets (gql`` tags in TS/TSX) live in typescriptreact.lua.

local ls = require("luasnip")
local s, t, i, f, c = ls.snippet, ls.text_node, ls.insert_node, ls.function_node, ls.choice_node

local function mirror(args)
	return args[1][1]
end

ls.add_snippets("graphql", {

	-- ── Schema root ───────────────────────────────────────────────────────────

	-- schm: full schema block — use once per schema file
	s({ trig = "schm", name = "schema definition" }, {
		t({ "schema {", "  query: Query", "  mutation: Mutation", "  subscription: Subscription", "}" }),
	}),

	-- ── Type definitions ──────────────────────────────────────────────────────

	-- typ: object type
	s({ trig = "typ", name = "type definition" }, {
		t("type "),
		i(1, "Name"),
		t({ " {", "  " }),
		i(0),
		t({ "", "}" }),
	}),

	-- iface: interface — useful for shared fields across types
	s({ trig = "iface", name = "interface" }, {
		t("interface "),
		i(1, "Name"),
		t({ " {", "  " }),
		i(0),
		t({ "", "}" }),
	}),

	-- inp: input type — conventionally suffixed with Input
	s({ trig = "inp", name = "input type" }, {
		t("input "),
		i(1, "NameInput"),
		t({ " {", "  " }),
		i(0),
		t({ "", "}" }),
	}),

	-- enm: enum type
	s({ trig = "enm", name = "enum" }, {
		t("enum "),
		i(1, "Name"),
		t({ " {", "  " }),
		i(0),
		t({ "", "}" }),
	}),

	-- uni: union type
	s({ trig = "uni", name = "union" }, {
		t("union "),
		i(1, "Name"),
		t(" = "),
		i(2, "TypeA"),
		t(" | "),
		i(0, "TypeB"),
	}),

	-- ext: extend an existing type (e.g. extending Query with new resolvers)
	s({ trig = "ext", name = "extend type" }, {
		t("extend type "),
		i(1, "Name"),
		t({ " {", "  " }),
		i(0),
		t({ "", "}" }),
	}),

	-- ── Operations ────────────────────────────────────────────────────────────

	-- qry: named query operation with optional variable
	s({ trig = "qry", name = "query operation" }, {
		t("query "),
		i(1, "QueryName"),
		t("("),
		i(2, "$id: ID!"),
		t({ ") {", "  " }),
		i(0),
		t({ "", "}" }),
	}),

	-- mut: named mutation with typed input
	s({ trig = "mut", name = "mutation operation" }, {
		t("mutation "),
		i(1, "MutationName"),
		t("("),
		i(2, "$input: "),
		i(3, "NameInput"),
		t({ "!) {", "  " }),
		i(0),
		t({ "", "}" }),
	}),

	-- sub: subscription operation
	s({ trig = "sub", name = "subscription operation" }, {
		t("subscription "),
		i(1, "SubscriptionName"),
		t("("),
		i(2, "$id: ID!"),
		t({ ") {", "  " }),
		i(0),
		t({ "", "}" }),
	}),

	-- ── Fragments ─────────────────────────────────────────────────────────────

	-- frg: reusable fragment on a named type
	s({ trig = "frg", name = "fragment" }, {
		t("fragment "),
		i(1, "FragmentName"),
		t(" on "),
		i(2, "TypeName"),
		t({ " {", "  " }),
		i(0),
		t({ "", "}" }),
	}),

	-- ── Field helpers (useful inside type blocks) ─────────────────────────────

	-- fld: single field with scalar type — Tab stops: name → type → nullability
	s({ trig = "fld", name = "field: name and type" }, {
		i(1, "fieldName"),
		t(": "),
		c(2, { t("String"), t("Int"), t("Float"), t("Boolean"), t("ID") }),
		c(3, { t("!"), t("") }),
	}),

	-- lfld: list field — e.g. tags: [String!]!
	s({ trig = "lfld", name = "list field" }, {
		i(1, "fieldName"),
		t(": ["),
		i(2, "String"),
		t("!]!"),
	}),

	-- relfld: relation field pointing to another type
	s({ trig = "relfld", name = "relation field" }, {
		i(1, "fieldName"),
		t(": "),
		i(2, "RelatedType"),
		c(3, { t("!"), t("") }),
	}),

	-- ── Directives ────────────────────────────────────────────────────────────

	-- dep: @deprecated directive with reason
	s({ trig = "dep", name = "@deprecated directive" }, {
		t('@deprecated(reason: "'),
		i(1, "Use X instead"),
		t('")'),
	}),

	-- auth: common @auth directive pattern (custom directive)
	s({ trig = "auth", name = "@auth directive" }, {
		t("@auth(requires: "),
		c(1, { t("ADMIN"), t("USER"), t("GUEST") }),
		t(")"),
	}),
})
