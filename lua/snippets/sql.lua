-- lua/snippets/sql.lua
-- LuaSnip snippets for SQL files — structural patterns dadbod-completion
-- and friendly-snippets don't cover.
-- Loaded by snippets.lua via luasnip.loaders.from_lua.
--
-- DO NOT put autocmds, keymaps, or vim.api calls here.
--
-- Filetype: sql  (also registered under mysql and plsql)
-- dadbod-completion handles: table names, column names, schema identifiers.
-- friendly-snippets handles: basic SELECT, INSERT, UPDATE, DELETE, CREATE TABLE.
-- These snippets fill the structural gaps: CTEs, window functions, transactions,
-- upserts, EXPLAIN, and common aggregate patterns.
--
-- Add to snippets.lua:
--   require("luasnip").filetype_extend("mysql", { "sql" })
--   require("luasnip").filetype_extend("plsql", { "sql" })
--
-- Dialect notes: snippets use ANSI SQL where possible.
-- MySQL-vs-PostgreSQL differences are called out per snippet.
-- Indentation: 2 spaces (matches sql-formatter output).

local ls = require("luasnip")
local s, t, i, f, c = ls.snippet, ls.text_node, ls.insert_node, ls.function_node, ls.choice_node

local function mirror(args)
	return args[1][1]
end

ls.add_snippets("sql", {

	-- ══════════════════════════════════════════════════════════════════════════
	-- QUERY PATTERNS
	-- ══════════════════════════════════════════════════════════════════════════

	-- selj: SELECT with explicit JOIN — alias pattern for readability.
	s({ trig = "selj", name = "SELECT with JOIN" }, {
		t("SELECT"),
		t({ "", "  " }),
		i(1, "t.id, t.name, r.label"),
		t({ "", "FROM " }),
		i(2, "table_name"),
		t(" AS t"),
		t({ "", "" }),
		c(3, { t("INNER JOIN"), t("LEFT JOIN"), t("RIGHT JOIN"), t("FULL OUTER JOIN") }),
		t(" "),
		i(4, "related_table"),
		t(" AS r ON r."),
		i(5, "id"),
		t(" = t."),
		i(6, "related_id"),
		t({ "", "WHERE " }),
		i(7, "t.active = 1"),
		t({ "", "ORDER BY " }),
		i(8, "t.id"),
		t({ "", "LIMIT " }),
		i(0, "100"),
		t(";"),
	}),

	-- sela: SELECT with GROUP BY, HAVING, and ORDER BY — aggregate pattern.
	s({ trig = "sela", name = "SELECT aggregate with GROUP BY + HAVING" }, {
		t("SELECT"),
		t({ "", "  " }),
		i(1, "category"),
		t(", COUNT(*) AS count"),
		t(", "),
		i(2, "SUM(amount)"),
		t(" AS total"),
		t({ "", "FROM " }),
		i(3, "table_name"),
		t({ "", "WHERE " }),
		i(4, "active = 1"),
		t({ "", "GROUP BY " }),
		f(mirror, { 1 }),
		t({ "", "HAVING COUNT(*) > " }),
		i(5, "1"),
		t({ "", "ORDER BY total DESC" }),
		t({ "", "LIMIT " }),
		i(0, "50"),
		t(";"),
	}),

	-- exists: EXISTS / NOT EXISTS correlated subquery.
	s({ trig = "exists", name = "EXISTS correlated subquery" }, {
		t("SELECT "),
		i(1, "t.*"),
		t({ "", "FROM " }),
		i(2, "table_name"),
		t(" t"),
		t({ "", "" }),
		c(3, { t("WHERE EXISTS"), t("WHERE NOT EXISTS") }),
		t({ "", "  (SELECT 1 FROM " }),
		i(4, "other_table"),
		t(" o"),
		t({ "", "   WHERE o." }),
		i(5, "foreign_key"),
		t(" = t."),
		i(6, "id"),
		t({ "", "   AND o." }),
		i(0, "condition = true"),
		t({ "", ");" }),
	}),

	-- case: CASE expression — inline column transform.
	s({ trig = "case", name = "CASE expression" }, {
		t("CASE "),
		i(1, "column_name"),
		t({ "", "  WHEN " }),
		i(2, "value1"),
		t(" THEN '"),
		i(3, "result1"),
		t("'"),
		t({ "", "  WHEN " }),
		i(4, "value2"),
		t(" THEN '"),
		i(5, "result2"),
		t("'"),
		t({ "", "  ELSE '" }),
		i(6, "default"),
		t("'"),
		t({ "", "END AS " }),
		i(0, "alias"),
	}),

	-- casew: searched CASE (condition-based, no column after CASE).
	s({ trig = "casew", name = "searched CASE (WHERE-style conditions)" }, {
		t({ "CASE", "  WHEN " }),
		i(1, "column > 100"),
		t(" THEN '"),
		i(2, "high"),
		t("'"),
		t({ "", "  WHEN " }),
		i(3, "column > 50"),
		t(" THEN '"),
		i(4, "medium"),
		t("'"),
		t({ "", "  ELSE '" }),
		i(5, "low"),
		t("'"),
		t({ "", "END AS " }),
		i(0, "category"),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- CTEs (Common Table Expressions)
	-- ══════════════════════════════════════════════════════════════════════════

	-- cte: single CTE then SELECT.
	s({ trig = "cte", name = "WITH ... AS (CTE)" }, {
		t("WITH "),
		i(1, "cte_name"),
		t(" AS ("),
		t({ "", "  SELECT " }),
		i(2, "id, name"),
		t({ "", "  FROM " }),
		i(3, "table_name"),
		t({ "", "  WHERE " }),
		i(4, "condition"),
		t({ "", ")", "" }),
		t({ "", "SELECT *" }),
		t({ "", "FROM " }),
		f(mirror, { 1 }),
		t({ "", "WHERE " }),
		i(0, "1 = 1"),
		t(";"),
	}),

	-- ctem: multiple CTEs chained.
	s({ trig = "ctem", name = "WITH multiple CTEs" }, {
		t("WITH"),
		t({ "", "  " }),
		i(1, "first_cte"),
		t(" AS ("),
		t({ "", "    SELECT " }),
		i(2, "id"),
		t({ " FROM " }),
		i(3, "table_a"),
		t({ "", "  ),", "", "  " }),
		i(4, "second_cte"),
		t(" AS ("),
		t({ "", "    SELECT " }),
		i(5, "id"),
		t({ " FROM " }),
		i(6, "table_b"),
		t({ "", "  )", "" }),
		t({ "", "SELECT *" }),
		t({ "", "FROM " }),
		f(mirror, { 1 }),
		t({ "", "JOIN " }),
		f(mirror, { 4 }),
		t({ " USING (id);" }),
		i(0),
	}),

	-- rcte: recursive CTE — for trees/hierarchies.
	s({ trig = "rcte", name = "recursive CTE (tree / hierarchy)" }, {
		t("WITH RECURSIVE "),
		i(1, "hierarchy"),
		t(" AS ("),
		t({ "", "  -- Anchor: root rows", "  SELECT id, name, parent_id, 0 AS depth" }),
		t({ "", "  FROM " }),
		i(2, "table_name"),
		t({ "", "  WHERE parent_id IS NULL", "" }),
		t({ "", "  UNION ALL", "" }),
		t({ "", "  -- Recursive: children", "  SELECT c.id, c.name, c.parent_id, h.depth + 1" }),
		t({ "", "  FROM " }),
		f(mirror, { 2 }),
		t(" c"),
		t({ "", "  JOIN " }),
		f(mirror, { 1 }),
		t(" h ON h.id = c.parent_id"),
		t({ "", ")", "" }),
		t({ "", "SELECT *" }),
		t({ "", "FROM " }),
		f(mirror, { 1 }),
		t({ "", "ORDER BY depth, name;" }),
		i(0),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- WINDOW FUNCTIONS
	-- ══════════════════════════════════════════════════════════════════════════

	-- wfn: window function with OVER — choice node for common functions.
	s({ trig = "wfn", name = "window function OVER PARTITION BY" }, {
		c(1, {
			t("ROW_NUMBER()"),
			t("RANK()"),
			t("DENSE_RANK()"),
			t("COUNT(*)"),
			s("", { t("SUM("), i(1, "amount"), t(")") }),
			s("", { t("AVG("), i(1, "amount"), t(")") }),
		}),
		t(" OVER ("),
		t({ "", "  PARTITION BY " }),
		i(2, "category"),
		t({ "", "  ORDER BY " }),
		i(3, "created_at DESC"),
		t({ "", ") AS " }),
		i(0, "row_rank"),
	}),

	-- wfnlag: LAG / LEAD — access previous or next row value.
	s({ trig = "wfnlag", name = "LAG / LEAD window function" }, {
		c(1, { t("LAG"), t("LEAD") }),
		t("("),
		i(2, "amount"),
		t(", "),
		i(3, "1"),
		t(", "),
		i(4, "0"),
		t(")"),
		t(" OVER ("),
		t({ "", "  PARTITION BY " }),
		i(5, "user_id"),
		t({ "", "  ORDER BY " }),
		i(6, "created_at"),
		t({ "", ") AS " }),
		i(0, "prev_amount"),
	}),

	-- wfnnth: NTH_VALUE / FIRST_VALUE / LAST_VALUE.
	s({ trig = "wfnnth", name = "FIRST_VALUE / LAST_VALUE / NTH_VALUE" }, {
		c(1, {
			s("", { t("FIRST_VALUE("), i(1, "column"), t(")") }),
			s("", { t("LAST_VALUE("), i(1, "column"), t(")") }),
			s("", { t("NTH_VALUE("), i(1, "column"), t(", "), i(2, "2"), t(")") }),
		}),
		t(" OVER ("),
		t({ "", "  PARTITION BY " }),
		i(2, "group_col"),
		t({ "", "  ORDER BY " }),
		i(3, "order_col"),
		t({ "", "  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW", ") AS " }),
		i(0, "alias"),
	}),

	-- ntile: NTILE — divide rows into N buckets.
	s({ trig = "ntile", name = "NTILE bucket window function" }, {
		t("NTILE("),
		i(1, "4"),
		t(") OVER ("),
		t({ "", "  ORDER BY " }),
		i(2, "score DESC"),
		t({ "", ") AS " }),
		i(0, "quartile"),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- DATA MANIPULATION
	-- ══════════════════════════════════════════════════════════════════════════

	-- insm: INSERT multiple rows — batch pattern.
	s({ trig = "insm", name = "INSERT multiple rows" }, {
		t("INSERT INTO "),
		i(1, "table_name"),
		t({ "", "  (" }),
		i(2, "col1, col2, col3"),
		t(")"),
		t({ "", "VALUES" }),
		t({ "", "  (" }),
		i(3, "val1, val2, val3"),
		t("),"),
		t({ "", "  (" }),
		i(4, "val1, val2, val3"),
		t(");"),
		i(0),
	}),

	-- upsertpg: INSERT ... ON CONFLICT (PostgreSQL UPSERT).
	s({ trig = "upsertpg", name = "INSERT ON CONFLICT DO UPDATE (PostgreSQL)" }, {
		t("INSERT INTO "),
		i(1, "table_name"),
		t({ "", "  (" }),
		i(2, "id, name, value"),
		t(")"),
		t({ "", "VALUES" }),
		t({ "", "  (" }),
		i(3, "$1, $2, $3"),
		t(")"),
		t({ "", "ON CONFLICT (" }),
		i(4, "id"),
		t(")"),
		t({ "", "DO UPDATE SET" }),
		t({ "", "  name  = EXCLUDED.name," }),
		t({ "", "  value = EXCLUDED.value;" }),
		i(0),
	}),

	-- upsertmy: INSERT ... ON DUPLICATE KEY UPDATE (MySQL UPSERT).
	s({ trig = "upsertmy", name = "INSERT ON DUPLICATE KEY UPDATE (MySQL)" }, {
		t("INSERT INTO "),
		i(1, "table_name"),
		t({ "", "  (" }),
		i(2, "id, name, value"),
		t(")"),
		t({ "", "VALUES" }),
		t({ "", "  (" }),
		i(3, "1, 'name', 'value'"),
		t(")"),
		t({ "", "ON DUPLICATE KEY UPDATE" }),
		t({ "", "  name  = VALUES(name)," }),
		t({ "", "  value = VALUES(value);" }),
		i(0),
	}),

	-- updsafe: UPDATE with explicit WHERE — safe pattern (prevents full-table update).
	s({ trig = "updsafe", name = "UPDATE with WHERE (safe)" }, {
		t("UPDATE "),
		i(1, "table_name"),
		t({ "", "SET" }),
		t({ "", "  " }),
		i(2, "column1"),
		t(" = "),
		i(3, "value1"),
		t({ "", "  , " }),
		i(4, "column2"),
		t(" = "),
		i(5, "value2"),
		t({ "", "WHERE " }),
		i(6, "id = ?"),
		t({ "", "  AND " }),
		i(0, "active = 1"),
		t(";"),
	}),

	-- delsafe: DELETE with explicit WHERE — safe pattern.
	s({ trig = "delsafe", name = "DELETE with WHERE (safe)" }, {
		t("-- Safety check: run SELECT first"),
		t({ "", "-- SELECT COUNT(*) FROM " }),
		i(1, "table_name"),
		t({ " WHERE " }),
		i(2, "id = ?"),
		t({ "", "", "DELETE FROM " }),
		f(mirror, { 1 }),
		t({ "", "WHERE " }),
		f(mirror, { 2 }),
		t(";"),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- TRANSACTIONS
	-- ══════════════════════════════════════════════════════════════════════════

	-- trx: full transaction with error handling comment pattern.
	s({ trig = "trx", name = "transaction block" }, {
		t({ "BEGIN;", "" }),
		t({ "", "  -- " }),
		i(1, "Operation description"),
		t({ "", "  " }),
		i(0),
		t({ "", "", "-- Run SELECT to verify, then:", "-- COMMIT;", "-- or ROLLBACK;" }),
	}),

	-- trxsp: transaction with SAVEPOINT — for partial rollbacks.
	s({ trig = "trxsp", name = "transaction with SAVEPOINT" }, {
		t({ "BEGIN;", "", "SAVEPOINT " }),
		i(1, "sp1"),
		t(";"),
		t({ "", "", "  " }),
		i(2, "-- operations"),
		t({ "", "", "-- On error:", "-- ROLLBACK TO SAVEPOINT " }),
		f(mirror, { 1 }),
		t(";"),
		t({ "", "-- On success:", "RELEASE SAVEPOINT " }),
		f(mirror, { 1 }),
		t(";"),
		t({ "", "", "COMMIT;" }),
		i(0),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- DDL
	-- ══════════════════════════════════════════════════════════════════════════

	-- crts: CREATE TABLE with serial PK (PostgreSQL) / AUTO_INCREMENT (MySQL).
	s({ trig = "crts", name = "CREATE TABLE with PK + timestamps" }, {
		t("CREATE TABLE "),
		i(1, "table_name"),
		t({ " (", "  id " }),
		c(2, {
			t("BIGSERIAL PRIMARY KEY"), -- PostgreSQL
			t("BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY"), -- MySQL
			t("INTEGER PRIMARY KEY AUTOINCREMENT"), -- SQLite
		}),
		t({ ",", "  " }),
		i(3, "name"),
		t(" "),
		i(4, "VARCHAR(255)"),
		t({
			" NOT NULL,",
			"  created_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,",
			"  updated_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP",
		}),
		c(5, {
			t(""), -- PostgreSQL (use trigger)
			t(" ON UPDATE CURRENT_TIMESTAMP"), -- MySQL
		}),
		t({ "", ");" }),
		i(0),
	}),

	-- altadd: ALTER TABLE ADD COLUMN.
	s({ trig = "altadd", name = "ALTER TABLE ADD COLUMN" }, {
		t("ALTER TABLE "),
		i(1, "table_name"),
		t({ "", "  ADD COLUMN " }),
		i(2, "column_name"),
		t(" "),
		i(3, "VARCHAR(255)"),
		c(4, { t(" NOT NULL"), t(" NULL"), t(" NOT NULL DEFAULT ''") }),
		t(";"),
	}),

	-- altdrop: ALTER TABLE DROP COLUMN.
	s({ trig = "altdrop", name = "ALTER TABLE DROP COLUMN" }, {
		t("ALTER TABLE "),
		i(1, "table_name"),
		t({ "", "  DROP COLUMN " }),
		i(2, "column_name"),
		t(";"),
	}),

	-- idxc: CREATE INDEX (covering / composite).
	s({ trig = "idxc", name = "CREATE INDEX (covering)" }, {
		c(1, { t("CREATE INDEX"), t("CREATE UNIQUE INDEX"), t("CREATE INDEX CONCURRENTLY") }),
		t(" idx_"),
		i(2, "table"),
		t("_"),
		i(3, "column"),
		t({ "", "  ON " }),
		f(mirror, { 2 }),
		t(" ("),
		i(4, "column1, column2"),
		t(")"),
		c(5, {
			t(""),
			s("", { t({ "", "  WHERE " }), i(1, "active = true") }), -- partial index
		}),
		t(";"),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- EXPLAIN / DEBUGGING
	-- ══════════════════════════════════════════════════════════════════════════

	-- expln: EXPLAIN ANALYZE — works in both PostgreSQL and MySQL 8+.
	s({ trig = "expln", name = "EXPLAIN ANALYZE" }, {
		c(1, {
			t("EXPLAIN ANALYZE"), -- PostgreSQL (full execution stats)
			t("EXPLAIN"), -- MySQL / portable
			t("EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)"), -- PostgreSQL verbose
		}),
		t({ "", "" }),
		i(0, "SELECT ..."),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- DATE / TIME PATTERNS
	-- ══════════════════════════════════════════════════════════════════════════

	-- datepg: PostgreSQL date arithmetic.
	s({ trig = "datepg", name = "PostgreSQL date range filter" }, {
		i(1, "created_at"),
		t(" BETWEEN"),
		t({ "", "  NOW() - INTERVAL '" }),
		i(2, "30"),
		t(" days'"),
		t({ "", "  AND NOW()" }),
	}),

	-- datemy: MySQL date arithmetic.
	s({ trig = "datemy", name = "MySQL date range filter" }, {
		i(1, "created_at"),
		t(" BETWEEN"),
		t({ "", "  DATE_SUB(NOW(), INTERVAL " }),
		i(2, "30"),
		t(" DAY)"),
		t({ "", "  AND NOW()" }),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- JSON (PostgreSQL 9.3+ / MySQL 5.7+)
	-- ══════════════════════════════════════════════════════════════════════════

	-- jsonpg: PostgreSQL JSON field extraction.
	s({ trig = "jsonpg", name = "PostgreSQL JSON field extraction" }, {
		i(1, "data"),
		t(" ->> '"),
		i(2, "key"),
		t("' AS "),
		i(0, "alias"),
		t({ "", "-- Use -> for JSON, ->> for text" }),
	}),

	-- jsonmy: MySQL JSON field extraction.
	s({ trig = "jsonmy", name = "MySQL JSON_VALUE extraction" }, {
		t("JSON_VALUE("),
		i(1, "data"),
		t(", '$."),
		i(2, "key"),
		t("') AS "),
		i(0, "alias"),
	}),

	-- jsonagg: JSON aggregation — collect rows into a JSON array.
	s({ trig = "jsonagg", name = "JSON aggregation" }, {
		c(1, {
			s("", { t("JSON_AGG("), i(1, "row_expression"), t(")") }), -- PostgreSQL
			s("", { t("JSON_ARRAYAGG("), i(1, "expression"), t(")") }), -- MySQL
		}),
		t(" AS "),
		i(0, "json_result"),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- PIVOT / CROSS-TAB
	-- ══════════════════════════════════════════════════════════════════════════

	-- pivot: CASE-based pivot (works in all dialects).
	s({ trig = "pivot", name = "CASE-based pivot table" }, {
		t("SELECT"),
		t({ "", "  " }),
		i(1, "group_col"),
		t({ "", "  , SUM(CASE WHEN " }),
		i(2, "pivot_col"),
		t(" = '"),
		i(3, "val1"),
		t("' THEN "),
		i(4, "metric"),
		t(" ELSE 0 END) AS "),
		i(5, "val1"),
		t({ "", "  , SUM(CASE WHEN " }),
		f(mirror, { 2 }),
		t(" = '"),
		i(6, "val2"),
		t("' THEN "),
		f(mirror, { 4 }),
		t(" ELSE 0 END) AS "),
		i(7, "val2"),
		t({ "", "FROM " }),
		i(0, "table_name"),
		t({ "", "GROUP BY " }),
		f(mirror, { 1 }),
		t(";"),
	}),
})

-- Register the same snippets for MySQL and plsql filetypes.
-- (filetype_extend in snippets.lua is the cleaner approach;
--  direct registration here means it works even without the extend.)
ls.add_snippets("mysql", ls.get_snippets("sql") or {})
ls.add_snippets("plsql", ls.get_snippets("sql") or {})
