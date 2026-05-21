-- lua/snippets/csharp.lua
-- LuaSnip snippets for C# files — modern C# (9–13) + xUnit + ASP.NET Core.
-- Loaded by snippets.lua via luasnip.loaders.from_lua.
--
-- Filetype: cs  (Roslyn also attaches to cshtml/razor but those are templated)
--
-- Scope: fills the gaps between friendly-snippets' basic C# coverage and
-- the full VS Code C# + C# Dev Kit experience:
--   • Modern syntax  — record, primary ctor, file-scoped ns, required, init
--   • xUnit tests    — matches neotest-vstest setup
--   • Async patterns — Task, CancellationToken, IAsyncDisposable
--   • ASP.NET Core   — minimal API, controller actions
--   • DI / patterns  — constructor injection, IDisposable
--
-- Indentation: 4 spaces (csharpier default, .NET standard).
-- Naming: PascalCase types/methods, _camelCase private fields (.NET convention).

local ls = require("luasnip")
-- Added `sn` (snippet_node) for nesting inside choice nodes.
local s, t, i, f, c, sn = ls.snippet, ls.text_node, ls.insert_node, ls.function_node, ls.choice_node, ls.snippet_node

local function mirror(args)
	return args[1][1]
end

-- Capitalise first letter — used for field → property name mirroring.
local function capitalise(args)
	local name = args[1][1]
	if name == "" then
		return ""
	end
	return name:sub(1, 1):upper() .. name:sub(2)
end

ls.add_snippets("cs", {

	-- ══════════════════════════════════════════════════════════════════════════
	-- FILE SKELETON
	-- ══════════════════════════════════════════════════════════════════════════

	s({ trig = "_skel", name = "C# file header (file-scoped namespace)" }, {
		t("namespace "),
		i(1, "MyApp.Services"),
		t({ ";", "", "" }),
		i(0),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- NAMESPACES
	-- ══════════════════════════════════════════════════════════════════════════

	s({ trig = "ns", name = "file-scoped namespace (C# 10)" }, {
		t("namespace "),
		i(1, "MyApp.Services"),
		t({ ";", "", "" }),
		i(0),
	}),

	s({ trig = "nsb", name = "block namespace" }, {
		t("namespace "),
		i(1, "MyApp.Services"),
		t({ "", "{", "    " }),
		i(0),
		t({ "", "}" }),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- TYPES
	-- ══════════════════════════════════════════════════════════════════════════

	s({ trig = "record", name = "positional record (C# 9)" }, {
		c(1, { t("public"), t("internal") }),
		t(" record "),
		i(2, "RecordName"),
		t("("),
		i(3, "string Name, int Id"),
		t(");"),
	}),

	s({ trig = "recordc", name = "record with body (C# 9)" }, {
		c(1, { t("public"), t("internal") }),
		t(" record "),
		i(2, "RecordName"),
		t("("),
		i(3, "string Name"),
		t({ ");", "", "{", "    " }),
		i(0),
		t({ "", "}" }),
	}),

	s({ trig = "records", name = "readonly record struct (C# 10)" }, {
		c(1, { t("public"), t("internal") }),
		t(" readonly record struct "),
		i(2, "Point"),
		t("("),
		i(3, "double X, double Y"),
		t(");"),
	}),

	s({ trig = "pcls", name = "class with primary constructor (C# 12)" }, {
		c(1, { t("public"), t("internal"), t("public sealed") }),
		t(" class "),
		i(2, "ClassName"),
		t("("),
		i(3, "ILogger<"),
		f(mirror, { 2 }),
		t("> logger"),
		t({ ")", "{", "    " }),
		i(0),
		t({ "", "}" }),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- PROPERTIES
	-- ══════════════════════════════════════════════════════════════════════════

	s({ trig = "pinit", name = "init-only property (C# 9)" }, {
		t("public "),
		i(1, "string"),
		t(" "),
		i(2, "Name"),
		t(" { get; init; }"),
	}),

	s({ trig = "preq", name = "required property (C# 11)" }, {
		t("public required "),
		i(1, "string"),
		t(" "),
		i(2, "Name"),
		t(" { get; init; }"),
	}),

	s({ trig = "propb", name = "property with backing field" }, {
		t("private "),
		i(1, "string"),
		t(" _"),
		i(2, "name"),
		t({ ";", "" }),
		t("public "),
		f(mirror, { 1 }),
		t(" "),
		f(capitalise, { 2 }),
		t({ "", "{", "    get => _" }),
		f(mirror, { 2 }),
		t({ ";", "    set => _" }),
		f(mirror, { 2 }),
		t({ " = value;", "" }),
		t("}"),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- ASYNC / TASK PATTERNS
	-- ══════════════════════════════════════════════════════════════════════════

	s({ trig = "asyncfn", name = "async Task method" }, {
		c(1, { t("public"), t("private"), t("protected"), t("internal") }),
		t(" async Task"),
		c(2, {
			t(""),
			sn(nil, { t("<"), i(1, "TResult"), t(">") }),
		}),
		t(" "),
		i(3, "MethodNameAsync"),
		t("("),
		i(4),
		t({ ")", "{", "    " }),
		i(0),
		t({ "", "}" }),
	}),

	s({ trig = "asyncct", name = "async method with CancellationToken" }, {
		c(1, { t("public"), t("private"), t("protected") }),
		t(" async Task"),
		c(2, {
			t(""),
			sn(nil, { t("<"), i(1, "TResult"), t(">") }),
		}),
		t(" "),
		i(3, "MethodNameAsync"),
		t("("),
		i(4),
		c(5, { t("CancellationToken ct = default"), t("CancellationToken cancellationToken = default") }),
		t({ ")", "{", "    " }),
		i(0),
		t({ "", "}" }),
	}),

	s({ trig = "ct", name = "CancellationToken parameter" }, {
		t("CancellationToken "),
		i(1, "ct"),
		t(" = default"),
	}),

	s({ trig = "awaitu", name = "await using (IAsyncDisposable)" }, {
		t("await using var "),
		i(1, "resource"),
		t(" = new "),
		i(2, "ResourceType"),
		t("();"),
	}),

	s({ trig = "vatask", name = "var result = await task" }, {
		t("var "),
		i(1, "result"),
		t(" = await "),
		i(2, "taskExpression"),
		t(";"),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- XUNIT TESTS
	-- ══════════════════════════════════════════════════════════════════════════

	s({ trig = "testcls", name = "xUnit test class" }, {
		t("public class "),
		i(1, "SubjectNameTests"),
		t({ "", "{", "    private readonly " }),
		i(2, "SubjectName"),
		t({ " _sut;", "" }),
		t({ "", "    public " }),
		f(mirror, { 1 }),
		t({ "()", "    {", "        _sut = new " }),
		f(mirror, { 2 }),
		t({ "();", "    }", "" }),
		i(0),
		t({ "", "}" }),
	}),

	s({ trig = "fact", name = "[Fact] xUnit test" }, {
		t({ "[Fact]", "public async Task " }),
		i(1, "MethodName_StateUnderTest_ExpectedResult"),
		t({ "()", "{", "    // Arrange", "    " }),
		i(2),
		t({ "", "", "    // Act", "    var result = " }),
		i(3, "_sut.MethodName()"),
		t({ ";", "", "    // Assert", "    " }),
		i(0),
		t({ "", "}" }),
	}),

	s({ trig = "theory", name = "[Theory] xUnit data-driven test" }, {
		t({ "[Theory]", "[InlineData(" }),
		i(1, "input, expected"),
		t({ ")]", "public async Task " }),
		i(2, "MethodName_WithData_ExpectedResult"),
		t("("),
		i(3, "string input, string expected"),
		t({ ")", "{", "    // Arrange", "    " }),
		i(4),
		t({ "", "", "    // Act", "    var result = " }),
		i(5, "_sut.MethodName(input)"),
		t({ ";", "", "    // Assert", "    " }),
		i(0),
		t({ "", "}" }),
	}),

	s({ trig = "assert", name = "xUnit Assert" }, {
		c(1, {
			sn(nil, { t("Assert.Equal("), i(1, "expected"), t(", "), i(2, "actual"), t(");") }),
			sn(nil, { t("Assert.True("), i(1, "condition"), t(");") }),
			sn(nil, { t("Assert.False("), i(1, "condition"), t(");") }),
			sn(nil, { t("Assert.Null("), i(1, "value"), t(");") }),
			sn(nil, { t("Assert.NotNull("), i(1, "value"), t(");") }),
			sn(nil, { t("Assert.Throws<"), i(1, "Exception"), t(">("), i(2, "() => _sut.Method()"), t(");") }),
			sn(nil, {
				t("await Assert.ThrowsAsync<"),
				i(1, "Exception"),
				t(">("),
				i(2, "async () => await _sut.MethodAsync()"),
				t(");"),
			}),
		}),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- ASP.NET CORE
	-- ══════════════════════════════════════════════════════════════════════════

	s({ trig = "mapget", name = "Minimal API MapGet" }, {
		t('app.MapGet("/'),
		i(1, "route"),
		t('", async ('),
		i(2, "HttpContext ctx"),
		t({ ") =>", "{", "    " }),
		i(0),
		t({ "", "});" }),
	}),

	s({ trig = "mappost", name = "Minimal API MapPost" }, {
		t('app.MapPost("/'),
		i(1, "route"),
		t('", async ([FromBody] '),
		i(2, "RequestType"),
		t(" "),
		i(3, "request"),
		t({ ") =>", "{", "    " }),
		i(0),
		t({ "", "});" }),
	}),

	s({ trig = "mapgroup", name = "Minimal API route group" }, {
		t("var "),
		i(1, "group"),
		t(' = app.MapGroup("/'),
		i(2, "api/v1"),
		t({ '");', "" }),
		f(mirror, { 1 }),
		t('.MapGet("/'),
		i(3, "{id}"),
		t('", async ('),
		i(4, "int id"),
		t({ ") =>", "{", "    " }),
		i(0),
		t({ "", "});" }),
	}),

	s({ trig = "ctrl", name = "Controller action method" }, {
		t("[Http"),
		c(1, { t("Get"), t("Post"), t("Put"), t("Patch"), t("Delete") }),
		c(2, {
			t(""),
			sn(nil, { t('("'), i(1, "{id}"), t('")') }),
		}),
		t("]"),
		t({ "", "public async Task<ActionResult<" }),
		i(3, "ResponseType"),
		t(">> "),
		i(4, "MethodNameAsync"),
		t("("),
		i(5),
		t({ ")", "{", "    " }),
		i(0),
		t({ "", "}" }),
	}),

	s({ trig = "middleware", name = "ASP.NET Core middleware" }, {
		t("public class "),
		i(1, "MiddlewareName"),
		t({
			"(RequestDelegate next)",
			"{",
			"    private readonly RequestDelegate _next = next;",
			"",
			"    public async Task InvokeAsync(HttpContext context)",
			"    {",
			"        ",
		}),
		i(2, "// before"),
		t({ "", "        await _next(context);", "        " }),
		i(3, "// after"),
		t({ "", "    }", "}" }),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- DEPENDENCY INJECTION / PATTERNS
	-- ══════════════════════════════════════════════════════════════════════════

	s({ trig = "ctordi", name = "Constructor DI injection" }, {
		t("private readonly "),
		i(1, "IService"),
		t(" _"),
		i(2, "service"),
		t({ ";", "" }),
		t("public "),
		i(3, "ClassName"),
		t("("),
		f(mirror, { 1 }),
		t(" "),
		f(mirror, { 2 }),
		t({ ")", "{", "    _" }),
		f(mirror, { 2 }),
		t(" = "),
		f(mirror, { 2 }),
		t({ ";", "}" }),
	}),

	s({ trig = "dispose", name = "IDisposable implementation" }, {
		t({
			"private bool _disposed;",
			"",
			"public void Dispose()",
			"{",
			"    Dispose(true);",
			"    GC.SuppressFinalize(this);",
			"}",
			"",
			"protected virtual void Dispose(bool disposing)",
			"{",
			"    if (_disposed) return;",
			"    if (disposing)",
			"    {",
			"        ",
		}),
		i(1, "// free managed resources"),
		t({ "", "    }", "    " }),
		i(2, "// free unmanaged resources"),
		t({ "", "    _disposed = true;", "}" }),
	}),

	s({ trig = "adispose", name = "IAsyncDisposable implementation" }, {
		t({ "public async ValueTask DisposeAsync()", "{", "    " }),
		i(1, "await _resource.DisposeAsync();"),
		t({ "", "    GC.SuppressFinalize(this);", "}" }),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- LINQ
	-- ══════════════════════════════════════════════════════════════════════════

	s({ trig = "linqw", name = "LINQ Where + Select + ToList" }, {
		t("var "),
		i(1, "results"),
		t(" = "),
		i(2, "source"),
		t({ "", "    .Where(" }),
		i(3, "x"),
		t(" => "),
		i(4, "x.IsActive"),
		t({ ")", "    .Select(" }),
		f(mirror, { 3 }),
		t(" => "),
		i(5, "x.Name"),
		t({ ")", "    .ToList();" }),
	}),

	s({ trig = "linqfa", name = "LINQ FirstOrDefault" }, {
		t("var "),
		i(1, "item"),
		t(" = "),
		i(2, "source"),
		t(".FirstOrDefault("),
		i(3, "x"),
		t(" => "),
		i(4, "x.Id == id"),
		t(");"),
	}),

	s({ trig = "linqga", name = "LINQ GroupBy" }, {
		t("var "),
		i(1, "grouped"),
		t(" = "),
		i(2, "source"),
		t({ "", "    .GroupBy(" }),
		i(3, "x"),
		t(" => "),
		i(4, "x.Category"),
		t({ ")", "    .ToDictionary(g => g.Key, g => g.ToList());" }),
	}),

	s({ trig = "linqa", name = "async LINQ ToListAsync (EF Core)" }, {
		t("var "),
		i(1, "results"),
		t(" = await "),
		i(2, "_dbContext"),
		t("."),
		i(3, "Entities"),
		t({ "", "    .Where(" }),
		i(4, "x"),
		t(" => "),
		i(5, "x.IsActive"),
		t({ ")", "    .Select(" }),
		f(mirror, { 4 }),
		t(" => "),
		i(6, "x.Name"),
		t({ ")", "    .ToListAsync(ct);" }),
	}),
	-- ══════════════════════════════════════════════════════════════════════════
	-- LOGGING
	-- ══════════════════════════════════════════════════════════════════════════

	s({ trig = "loginfo", name = "_logger.LogInformation" }, {
		t('_logger.LogInformation("'),
		i(1, "Message {Param}"),
		t('", '),
		i(2, "param"),
		t(");"),
	}),

	s({ trig = "logwarn", name = "_logger.LogWarning" }, {
		t('_logger.LogWarning("'),
		i(1, "Warning {Param}"),
		t('", '),
		i(2, "param"),
		t(");"),
	}),

	s({ trig = "logerr", name = "_logger.LogError with exception" }, {
		t("_logger.LogError("),
		i(1, "ex"),
		t(', "'),
		i(2, "Error occurred: {Message}"),
		t('", '),
		f(mirror, { 1 }),
		t(".Message);"),
	}),

	-- ══════════════════════════════════════════════════════════════════════════
	-- GUARDS / NULL HANDLING
	-- ══════════════════════════════════════════════════════════════════════════

	s({ trig = "anull", name = "ArgumentNullException.ThrowIfNull (C# 10)" }, {
		t("ArgumentNullException.ThrowIfNull("),
		i(1, "parameter"),
		t(");"),
	}),

	s({ trig = "arange", name = "ArgumentOutOfRangeException guard (C# 11)" }, {
		t("ArgumentOutOfRangeException.ThrowIf"),
		c(1, { t("Negative"), t("NegativeOrZero"), t("Zero"), t("GreaterThan") }),
		t("("),
		i(2, "value"),
		t(");"),
	}),

	s({ trig = "isnull", name = "null coalescing throw" }, {
		t("var "),
		i(1, "value"),
		t(" = "),
		i(2, "source"),
		t(" ?? throw new "),
		i(3, "InvalidOperationException"),
		t('("'),
		i(4, "Value cannot be null"),
		t('");'),
	}),

	s({ trig = "pattern", name = "switch expression (pattern matching)" }, {
		t("var "),
		i(1, "result"),
		t(" = "),
		i(2, "value"),
		t({ " switch", "{", "    " }),
		i(3, "SomeType x when x.Prop > 0"),
		t(" => "),
		i(4, "x.Prop"),
		t({ ",", "    _ => throw new ArgumentOutOfRangeException()" }),
		t({ "", "};" }),
	}),
})
