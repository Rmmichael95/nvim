-- lua/snippets/typescriptreact.lua
-- LuaSnip snippets for React / Next.js TypeScript files (.tsx).
-- Loaded by snippets.lua via luasnip.loaders.from_lua.
--
-- Filetype: typescriptreact
-- snippets.lua also extends typescriptreact → { "typescript", "javascript" },
-- so all TS/JS snippets are available here too.

local ls = require("luasnip")
local s, t, i, f, c = ls.snippet, ls.text_node, ls.insert_node, ls.function_node, ls.choice_node

-- Mirror an insert node's text (used for repeating component names).
local function mirror(args)
	return args[1][1]
end

-- Capitalise first letter — used for useState setter names.
local function capitalise(args)
	local name = args[1][1]
	if name == "" then
		return ""
	end
	return name:sub(1, 1):upper() .. name:sub(2)
end

ls.add_snippets("typescriptreact", {

	-- ── Directives ────────────────────────────────────────────────────────────

	-- usc: "use client" — must be the first line of a Client Component
	s({ trig = "usc", name = '"use client" directive' }, {
		t({ '"use client"', "", "" }),
		i(0),
	}),

	-- uss: "use server" — marks a Server Action module or inline action
	s({ trig = "uss", name = '"use server" directive' }, {
		t({ '"use server"', "", "" }),
		i(0),
	}),

	-- ── Components ────────────────────────────────────────────────────────────

	-- rfc: arrow function component with typed props interface
	-- Tab order: ComponentName → props body → destructured params → JSX body
	s({ trig = "rfc", name = "React arrow function component" }, {
		t("interface "),
		i(1, "Component"),
		t({ "Props {", "  " }),
		i(2, "children?: React.ReactNode"),
		t({ "", "}", "", "const " }),
		f(mirror, { 1 }),
		t(" = ({ "),
		i(3, "children"),
		t(" }: "),
		f(mirror, { 1 }),
		t({ "Props) => {", "  return (", "    <div>" }),
		i(0),
		t({ "", "    </div>", "  )", "}", "", "export default " }),
		f(mirror, { 1 }),
	}),

	-- rfcd: default export function component (preferred in Next.js app router)
	s({ trig = "rfcd", name = "React default export function component" }, {
		t("export default function "),
		i(1, "Component"),
		t({ "() {", "  return (", "    <div>" }),
		i(0),
		t({ "", "    </div>", "  )", "}" }),
	}),

	-- ── React Hooks ───────────────────────────────────────────────────────────

	-- ust: useState with generic type — setter name is auto-capitalised
	s({ trig = "ust", name = "useState" }, {
		t("const ["),
		i(1, "state"),
		t(", set"),
		f(capitalise, { 1 }),
		t("] = useState<"),
		i(2, "string"),
		t(">("),
		i(3),
		t(")"),
	}),

	-- uef: useEffect with dependency array
	s({ trig = "uef", name = "useEffect" }, {
		t({ "useEffect(() => {", "  " }),
		i(1),
		t({ "", "}, [" }),
		i(2),
		t("])"),
	}),

	-- ucb: useCallback — memoised event handler
	s({ trig = "ucb", name = "useCallback" }, {
		t("const "),
		i(1, "handleEvent"),
		t(" = useCallback(("),
		i(2),
		t({ ") => {", "  " }),
		i(3),
		t({ "", "}, [" }),
		i(4),
		t("])"),
	}),

	-- umm: useMemo — memoised derived value
	s({ trig = "umm", name = "useMemo" }, {
		t("const "),
		i(1, "value"),
		t(" = useMemo(() => "),
		i(2, "computation"),
		t(", ["),
		i(3),
		t("])"),
	}),

	-- uctx: useContext — reads a context value
	s({ trig = "uctx", name = "useContext" }, {
		t("const "),
		i(1, "value"),
		t(" = useContext("),
		i(2, "Context"),
		t(")"),
	}),

	-- urf: useRef with DOM element type
	s({ trig = "urf", name = "useRef" }, {
		t("const "),
		i(1, "ref"),
		t(" = useRef<"),
		i(2, "HTMLDivElement"),
		t(">("),
		i(3, "null"),
		t(")"),
	}),

	-- ── className helpers (matches your tailwind classRegex config) ───────────

	-- cn: cn() / clsx() className composition
	s({ trig = "cn", name = "cn() className helper" }, {
		t("cn("),
		i(1),
		t(")"),
	}),

	-- cva: cva() variant helper — matches your tailwind classRegex for cva()
	s({ trig = "cva", name = "cva() variant definition" }, {
		t("const "),
		i(1, "variants"),
		t(' = cva("'),
		i(2, "base-classes"),
		t({ '", {', "  variants: {", "    " }),
		i(3, 'variant: {\n      default: "",\n    }'),
		t({ "", "  },", "  defaultVariants: {", "    " }),
		i(4, 'variant: "default"'),
		t({ "", "  },", "})" }),
	}),

	-- ── Next.js app router ────────────────────────────────────────────────────

	-- npage: async page component — params typed as Promise (Next.js 15+)
	s({ trig = "npage", name = "Next.js page component" }, {
		t({ "interface PageProps {", "  params: Promise<{ " }),
		i(1, "slug: string"),
		t({
			" }>",
			"  searchParams: Promise<{ [key: string]: string | string[] | undefined }>",
			"}",
			"",
			"export default async function Page({ params }: PageProps) {",
			"  const { ",
		}),
		i(2, "slug"),
		t({ " } = await params", "  return (", "    <main>" }),
		i(0),
		t({ "", "    </main>", "  )", "}" }),
	}),

	-- nlyt: layout component wrapping children
	s({ trig = "nlyt", name = "Next.js layout component" }, {
		t({
			"export default function Layout({",
			"  children,",
			"}: {",
			"  children: React.ReactNode",
			"}) {",
			"  return (",
		}),
		t({ "", "    <>" }),
		i(0),
		t({ "", "    </>", "  )", "}" }),
	}),

	-- napi: route handler with HTTP method choice and error handling
	s({ trig = "napi", name = "Next.js route handler" }, {
		t('import { NextRequest, NextResponse } from "next/server"'),
		t({ "", "", "export async function " }),
		c(1, { t("GET"), t("POST"), t("PUT"), t("PATCH"), t("DELETE") }),
		t({ "(request: NextRequest) {", "  try {", "    " }),
		i(0),
		t({
			"",
			"    return NextResponse.json({ })",
			"  } catch (error) {",
			"    return NextResponse.json(",
			'      { error: "Internal Server Error" },',
			"      { status: 500 },",
			"    )",
			"  }",
			"}",
		}),
	}),

	-- nact: server action — form submission or data mutation
	s({ trig = "nact", name = "Next.js server action" }, {
		t({ '"use server"', "", "export async function " }),
		i(1, "actionName"),
		t({ "(formData: FormData) {", "  " }),
		i(0),
		t({ "", "}" }),
	}),

	-- nmeta: Next.js static metadata export
	s({ trig = "nmeta", name = "Next.js static metadata" }, {
		t('import type { Metadata } from "next"'),
		t({ "", "", "export const metadata: Metadata = {", '  title: "' }),
		i(1, "Page Title"),
		t({ '",', '  description: "' }),
		i(2, "Page description"),
		t({ '"', "}" }),
	}),

	-- ngmeta: Next.js generateMetadata (dynamic metadata)
	s({ trig = "ngmeta", name = "Next.js generateMetadata function" }, {
		t('import type { Metadata } from "next"'),
		t({ "", "", "export async function generateMetadata(): Promise<Metadata> {", "  return {", '    title: "' }),
		i(1, "Page Title"),
		t({ '"', "  }", "}" }),
	}),

	-- ── GraphQL client ────────────────────────────────────────────────────────

	-- gql: gql tagged template literal — GraphQL LSP attaches to typescriptreact
	s({ trig = "gql", name = "gql tagged template" }, {
		t("const "),
		i(1, "OPERATION_NAME"),
		t({ " = gql`", "  " }),
		c(2, { t("query"), t("mutation"), t("subscription") }),
		t(" "),
		i(3, "OperationName"),
		t({ " {", "    " }),
		i(0),
		t({ "", "  }", "`" }),
	}),

	-- ── Error & Suspense boundaries ───────────────────────────────────────────

	-- ssp: Suspense wrapper with fallback
	s({ trig = "ssp", name = "Suspense wrapper" }, {
		t({ "<Suspense fallback={<" }),
		i(1, "Loading"),
		t({ " />}>", "  " }),
		i(0),
		t({ "", "</Suspense>" }),
	}),
})
