# Authoring contract for "Zig from Zero to IRON LEDGER"

This file is the shared rulebook for everyone (human or agent) writing a chapter.
Read all of it before writing anything. Chapters that break it will not assemble.

## What this course is

A slow, traditional programming-book style course in Zig **0.16**, that starts from
"install the compiler and print a line" and ends by reading the real source of
IRON LEDGER, a 31,000-line BattleTech mercenary-company simulator written in pure
Zig with no libraries (the `game/` folder next to this course). The original
short guide it grew from is in `reference/original-guide.md` (and `.html`). Its
Part I sections are terse; we are expanding each of them into several patient
chapters with exercises. Its Part II (sections 18–30) becomes our Part 5, the
capstone reading.

Audience: someone who has programmed a little in any language (they know what a
loop is) but has never used Zig, C, or manual memory. Assume nothing about
pointers, allocators, or compile errors. Go slowly. Explain the *why*.

## Ground truth: the compiler

Every code example and every exercise solution must be compiled with the installed
compiler (`zig version` → 0.16.0) before it goes in a chapter. No exceptions.
Do it in your scratch directory with `zig run file.zig` or `zig test file.zig`.
Zig 0.16 changed many std APIs; tutorials on the web are wrong for it. The files
in `reference/verified-idioms/` compile today and show the correct forms. Use them.

Verified 0.16 idioms (all compiled 2026-09-09):

```zig
// Simplest program: no main parameter. std.debug.print writes to STDERR.
const std = @import("std");
pub fn main() void {
    std.debug.print("Hello, {s}!\n", .{"world"});
}

// Writing to STDOUT needs an Io instance and a buffer, and a flush at the end.
pub fn main(init: std.process.Init) !void {
    var buf: [1024]u8 = undefined;
    var w = std.Io.File.stdout().writer(init.io, &buf);
    const out = &w.interface;
    try out.print("Hello from stdout, {d}\n", .{42});
    try out.flush();
}

// Command-line args, allocator, stdin line.
pub fn main(init: std.process.Init) !void {
    const gpa = init.gpa;                         // general purpose allocator, leak-checked in Debug
    var list: std.ArrayList(u32) = .empty;        // ArrayList is UNMANAGED in 0.16: pass the allocator to every call
    defer list.deinit(gpa);
    try list.append(gpa, 5);
    var it = std.process.Args.Iterator.init(init.minimal.args);
    _ = it.next(); // program name
    while (it.next()) |a| std.debug.print("arg {s}\n", .{a});
    var rbuf: [256]u8 = undefined;
    var r = std.Io.File.stdin().reader(init.io, &rbuf);
    const line = try r.interface.takeDelimiter('\n'); // ?[]u8 ; null at EOF
    if (line) |l| std.debug.print("you typed: {s}\n", .{l});
}

// Files (0.16 std.Io). Dir/File methods take `io`.
const io = init.io;
var dir = std.Io.Dir.cwd();
var f = try dir.createFile(io, "out.txt", .{});
var wb: [256]u8 = undefined;
var w = f.writer(io, &wb);
try w.interface.print("line {d}\n", .{1});
try w.interface.flush();
f.close(io);
const data = try dir.readFileAlloc(io, "out.txt", init.gpa, .limited(1 << 20));
defer init.gpa.free(data);
const now = std.Io.Clock.now(.real, io);   // NOT an error union; .nanoseconds field

// Hash maps (unmanaged): .empty, pass allocator.
var m: std.AutoHashMapUnmanaged(u32, u32) = .empty;  defer m.deinit(a); try m.put(a, 1, 2); m.get(1) // ?u32
var sm: std.StringHashMapUnmanaged(u32) = .empty;
var am: std.AutoArrayHashMapUnmanaged(u32, u32) = .empty; // keeps insertion order

// Allocators
var gpa_state: std.heap.DebugAllocator(.{}) = .init;  defer _ = gpa_state.deinit();  const a = gpa_state.allocator();
var arena = std.heap.ArenaAllocator.init(std.testing.allocator); defer arena.deinit();
std.testing.allocator  // in tests; fails the test on leaks
std.heap.page_allocator
var fba = std.heap.FixedBufferAllocator.init(&buffer);

// Formatting / strings
try std.fmt.allocPrint(a, "{d}-{s}", .{ 1, "x" });
try std.fmt.bufPrint(&buf, "{d}", .{n});
try std.fmt.parseInt(i32, "-12", 10);  try std.fmt.parseFloat(f64, "1.5");
std.mem.eql(u8, x, y); std.mem.indexOf(u8, hay, needle); std.mem.trim(u8, s, " ");
var it = std.mem.tokenizeScalar(u8, "a b  c", ' ');  while (it.next()) |tok| {}
var sp = std.mem.splitScalar(u8, "a,b", ',');
std.debug.print("{d:.2} {e} {any} {?} {!}\n", ...)  // float precision, scientific, any value, optional, error union
var fw = std.Io.Writer.fixed(&buf); try fw.print("{d}", .{123}); fw.buffered() // []u8 written so far

// Sorting / random / vectors / reflection / threads
std.mem.sort(u8, &arr, {}, std.sort.asc(u8));
var prng = std.Random.DefaultPrng.init(seed); const r = prng.random(); r.intRangeAtMost(u8, 1, 6);
const v: @Vector(4, i32) = .{ 1, 2, 3, 4 }; @reduce(.Add, v)
inline for (@typeInfo(T).@"struct".fields) |f| { f.name; f.type; @field(value, f.name) }
@typeInfo(T).@"enum", .@"union", .int, .float, .pointer, .optional, .error_union, .bool
const p: packed struct(u8) { lo: u4, hi: u4 } = @bitCast(@as(u8, 0xAB));
var th = try std.Thread.spawn(.{}, func, .{arg}); th.join();
var mtx: std.Io.Mutex = .init; try mtx.lock(io); defer mtx.unlock(io);   // std.Thread.Mutex no longer exists
std.testing.expectEqual(@as(i32, 5), add(2, 3))   // expected must have a concrete type
std.testing.expectEqualStrings, expectError(error.X, expr), expect(bool), expectEqualSlices(u8, a, b)
```

Things that DO NOT exist in 0.16 (never write them): `std.io.getStdOut()`, `std.fs.cwd()`,
`std.time.timestamp()`, `std.ArrayList(T).init(alloc)` (managed lists are gone),
`std.rand`, `std.os.exit`, `std.fmt.format`, `writer.writeAll` on a File directly,
`@typeInfo(T).Struct` (the tag is `.@"struct"` now), `usingnamespace`, `async/await`.
Enum-tag fields of `@typeInfo` are lower-case and quoted where they collide with
keywords: `.@"struct"`, `.@"enum"`, `.@"union"`, `.@"fn"`, `.@"opaque"`.

Other rules the compiler enforces that beginners hit constantly, teach them early:
unused locals/parameters are errors (`_ = x;`), shadowing is an error, `var` that is
never mutated is an error (use `const`), an integer literal needs a concrete type when
it hits `expectEqual`, pointer-to-temporary rules, and `try` is only allowed inside a
function whose return type is an error union.

## File layout you produce

```
chapters/NN-slug.html          one fragment per chapter (NN two digits, see table)
exercises/NN-slug/exM_name.zig            starter the learner edits (M one digit)
exercises/NN-slug/solutions/exM_name.zig  complete, verified solution
```

Starters may contain `// TODO` bodies and need not compile as-is (say so in the header
comment), but the solution must compile and pass with the command named in its header.
Every `.zig` file begins with a header comment like:

```zig
//! Chapter 04, exercise 2: overflow arithmetic.
//! Run with:  zig test ex2_overflow.zig
//! Goal: make every test pass without changing the tests.
```

Prefer `zig test` exercises (self-checking, tests at the bottom of the file) for
anything that returns values. Use `zig run` exercises for printing/CLI chapters and put
the expected output in the header comment. The checker (`tools/check.sh`) runs
`zig test` on solution files whose header says `zig test`, and `zig run` on the
others, so the header line must literally contain `zig test` or `zig run`.

## Chapter fragment format

A fragment is an HTML snippet, not a document. No `<html>`, `<head>`, `<body>`.
It starts with `<section id="chNN">` and ends with `</section>`. Inside, exactly this
skeleton, in this order:

```html
<section id="ch04">
<h2>4. Integers and arithmetic</h2>
<p class="goals"><strong>In this chapter</strong> you will … (2–3 sentences, plain prose).</p>

<h3 id="ch04-1">4.1 First subsection</h3>
… prose, code, notes, tables …
<h3 id="ch04-2">4.2 …</h3>
…

<div class="ledger"><strong>In IRON LEDGER.</strong> One or two paragraphs pointing at where this
chapter's idea shows up in the game's source, with a short real snippet and its path.
Pull from reference/original-guide.md or read game/src directly.</div>

<h3 id="ch04-ex">Exercises</h3>
<div class="exercise"><h4>Exercise 4.1 · Title <span class="level">warm-up</span></h4>
  <p>What to do. Name the file: <code>exercises/04-integers/ex1_widths.zig</code>.</p>
  <details class="answer"><summary>Solution</summary>
  <pre><code>…the solution code, HTML-escaped…</code></pre>
  <p>Why it works…</p></details>
</div>
… 3 to 6 exercises, levels: warm-up, practice, challenge …

<h3 id="ch04-quiz">Check your understanding</h3>
<ol class="quiz">
  <li>Question? <details class="answer"><summary>Answer</summary>Answer text.</details></li>
  … 4 to 8 questions …
</ol>

<div class="summary"><strong>What you learned.</strong><ul><li>…</li></ul></div>
</section>
```

Available classes (the shell defines them, do not add `<style>`):
`.goals`, `.note` (callout, amber bar), `.try` (green "Try it" box), `.warn` (red bar, for
traps), `.ledger` (blue bar, IRON LEDGER connection), `.exercise`, `.level`, `.answer`,
`.quiz`, `.summary`, `.file` (a small caption line placed directly above a `<pre>` naming
the file), `table`, `.compare` (a two-column table of old vs new). Headings: `<h2>` for
the chapter title only, `<h3>` for subsections with ids `chNN-k`, `<h4>` inside exercises.

Code: `<pre><code>…</code></pre>` with `&lt; &gt; &amp;` escaped and NO manual highlighting
spans (the shell highlights Zig client-side). Terminal transcripts: `<pre class="term">`.
Inline code: `<code>`. Keep lines under ~90 columns in code blocks.

## Voice and pacing

- Second person, present tense, calm. Short paragraphs. One idea at a time.
- Introduce a concept, show the smallest program that uses it, show the output, then
  show a variation, then explain the rule. Then a trap (`.warn`) if there is one.
- Every non-trivial snippet is followed by its actual output in a `<pre class="term">`.
- Prefer complete runnable files over fragments in the first two Parts. Later Parts may
  show fragments if the surrounding file is obvious.
- Say why Zig makes each choice (no hidden allocation, no hidden control flow, explicit
  errors), and compare briefly with what the reader might know from Python/JS/C.
- Each chapter should be roughly 2,000–4,000 words of prose plus code, i.e. long. The
  original guide's one section becomes three to five of our chapters.
- Never invent APIs. If unsure, compile it. If it will not compile, do not teach it.
- No em dashes. Use commas, colons, or a new sentence.
- Do not number figures. Do not use images.

## Chapter table (fixed; use these numbers, slugs and titles exactly)

Part 0 · Getting started
- 00 `00-how-to-use` How to use this book
- 01 `01-first-program` Installing Zig and your first program
- 02 `02-printing` Printing to the screen
- 03 `03-variables` Variables, constants and types
- 04 `04-integers` Integers and arithmetic
- 05 `05-floats-bools` Floats, booleans and comparisons
- 06 `06-control-flow` Control flow: if, while, for, switch
- 07 `07-functions` Functions

Part 1 · Data
- 08 `08-testing` Testing as you go
- 09 `09-arrays` Arrays
- 10 `10-slices` Slices
- 11 `11-strings` Strings
- 12 `12-structs` Structs and methods
- 13 `13-enums` Enums
- 14 `14-unions` Unions and tagged unions
- 15 `15-optionals` Optionals
- 16 `16-errors` Errors
- 17 `17-defer` defer, errdefer and cleanup
- 18 `18-pointers` Pointers

Part 2 · Memory and the standard library
- 19 `19-memory` Memory: stack, heap and allocators
- 20 `20-allocators` Choosing an allocator
- 21 `21-arraylist` Growable lists: ArrayList
- 22 `22-hashmaps` Hash maps
- 23 `23-formatting` Formatting and parsing text
- 24 `24-std-tour` A tour of std.mem, std.sort and friends

Part 3 · The compile-time language
- 25 `25-comptime` comptime
- 26 `26-generics` Generics: types as values
- 27 `27-reflection` Reflection with @typeInfo
- 28 `28-zon` ZON: data files as code
- 29 `29-bits` Packed structs, bit casting and vectors

Part 4 · Whole programs
- 30 `30-program-structure` Program structure: files, imports, modules
- 31 `31-build-system` The build system
- 32 `32-cli` Command-line programs
- 33 `33-files` Files and directories with std.Io
- 34 `34-time-random` Time and randomness
- 35 `35-c-interop` Calling C
- 36 `36-concurrency` Threads and atomics
- 37 `37-style` Style, idioms and reading compile errors
- 38 `38-capstone` Capstone: a mercenary ledger from scratch

Part 5 · Reading IRON LEDGER (adapted from the original guide, sections 18–30)
- 39 `39-il-architecture` The architecture in one picture
- 40 `40-il-data` Data: ZON files become typed tables
- 41 `41-il-gamestate` GameState: one arena, one dice bag
- 42 `42-il-commands` Commands: the only way in
- 43 `43-il-tick` The daily tick
- 44 `44-il-queries` Queries: the only way out
- 45 `45-il-money` Money without floats
- 46 `46-il-battles` Battles and events
- 47 `47-il-persistence` Persistence: SQLite by hand
- 48 `48-il-tui` The terminal client
- 49 `49-il-determinism` Determinism and the test suite
- 50 `50-il-keypress` One keypress, end to end
- 51 `51-il-next` Where to go next

Appendices (fragments named `A1-…`, ids `appA1` etc.)
- A1 `A1-builtins` Builtin functions cheat sheet
- A2 `A2-format` Format specifier reference
- A3 `A3-migration` Zig 0.16 migration notes (old form → new form)
- A4 `A4-errors` Common compile errors, decoded
- A5 `A5-glossary` Glossary

Cross-reference other chapters as `<a href="#ch16">Chapter 16</a>`.
