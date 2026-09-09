#!/usr/bin/env python3
"""Stitch chapters/*.html fragments into a single index.html book.

Usage: python3 tools/assemble.py            (from the zig-course directory)

Reads the chapter table below, loads each fragment, builds the sidebar from the
<h2>/<h3> headings it finds, and writes index.html next to this folder's
chapters/ directory. Missing fragments become a placeholder section so the book
always assembles.
"""
import html
import os
import re
import sys
from datetime import date

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CH = os.path.join(ROOT, "chapters")
OUT = os.path.join(ROOT, "index.html")

PARTS = [
    ("Part 0 · Getting started", [
        ("00", "00-how-to-use", "How to use this book"),
        ("01", "01-first-program", "Installing Zig and your first program"),
        ("02", "02-printing", "Printing to the screen"),
        ("03", "03-variables", "Variables, constants and types"),
        ("04", "04-integers", "Integers and arithmetic"),
        ("05", "05-floats-bools", "Floats, booleans and comparisons"),
        ("06", "06-control-flow", "Control flow: if, while, for, switch"),
        ("07", "07-functions", "Functions"),
    ]),
    ("Part 1 · Data", [
        ("08", "08-testing", "Testing as you go"),
        ("09", "09-arrays", "Arrays"),
        ("10", "10-slices", "Slices"),
        ("11", "11-strings", "Strings"),
        ("12", "12-structs", "Structs and methods"),
        ("13", "13-enums", "Enums"),
        ("14", "14-unions", "Unions and tagged unions"),
        ("15", "15-optionals", "Optionals"),
        ("16", "16-errors", "Errors"),
        ("17", "17-defer", "defer, errdefer and cleanup"),
        ("18", "18-pointers", "Pointers"),
    ]),
    ("Part 2 · Memory and the standard library", [
        ("19", "19-memory", "Memory: stack, heap and allocators"),
        ("20", "20-allocators", "Choosing an allocator"),
        ("21", "21-arraylist", "Growable lists: ArrayList"),
        ("22", "22-hashmaps", "Hash maps"),
        ("23", "23-formatting", "Formatting and parsing text"),
        ("24", "24-std-tour", "A tour of std.mem, std.sort and friends"),
    ]),
    ("Part 3 · The compile-time language", [
        ("25", "25-comptime", "comptime"),
        ("26", "26-generics", "Generics: types as values"),
        ("27", "27-reflection", "Reflection with @typeInfo"),
        ("28", "28-zon", "ZON: data files as code"),
        ("29", "29-bits", "Packed structs, bit casting and vectors"),
    ]),
    ("Part 4 · Whole programs", [
        ("30", "30-program-structure", "Program structure: files, imports, modules"),
        ("31", "31-build-system", "The build system"),
        ("32", "32-cli", "Command-line programs"),
        ("33", "33-files", "Files and directories with std.Io"),
        ("34", "34-time-random", "Time and randomness"),
        ("35", "35-c-interop", "Calling C"),
        ("36", "36-concurrency", "Threads and atomics"),
        ("37", "37-style", "Style, idioms and reading compile errors"),
        ("38", "38-capstone", "Capstone: a mercenary ledger from scratch"),
    ]),
    ("Part 5 · Reading IRON LEDGER", [
        ("39", "39-il-architecture", "The architecture in one picture"),
        ("40", "40-il-data", "Data: ZON files become typed tables"),
        ("41", "41-il-gamestate", "GameState: one arena, one dice bag"),
        ("42", "42-il-commands", "Commands: the only way in"),
        ("43", "43-il-tick", "The daily tick"),
        ("44", "44-il-queries", "Queries: the only way out"),
        ("45", "45-il-money", "Money without floats"),
        ("46", "46-il-battles", "Battles and events"),
        ("47", "47-il-persistence", "Persistence: SQLite by hand"),
        ("48", "48-il-tui", "The terminal client"),
        ("49", "49-il-determinism", "Determinism and the test suite"),
        ("50", "50-il-keypress", "One keypress, end to end"),
        ("51", "51-il-next", "Where to go next"),
    ]),
    ("Appendices", [
        ("A1", "A1-builtins", "Builtin functions cheat sheet"),
        ("A2", "A2-format", "Format specifier reference"),
        ("A3", "A3-migration", "Zig 0.16 migration notes"),
        ("A4", "A4-errors", "Common compile errors, decoded"),
        ("A5", "A5-glossary", "Glossary"),
    ]),
]

H3 = re.compile(r'<h3\s+id="([^"]+)"[^>]*>(.*?)</h3>', re.S)
TAG = re.compile(r"<[^>]+>")


def sec_id(num):
    return ("app" + num) if num.startswith("A") else ("ch" + num)


def load(num, slug, title):
    path = os.path.join(CH, slug + ".html")
    if not os.path.exists(path):
        return (f'<section id="{sec_id(num)}"><h2>{html.escape(title)}</h2>'
                f'<p class="note">This chapter has not been written yet.</p></section>'), []
    with open(path, encoding="utf-8") as f:
        body = f.read()
    subs = [(i, TAG.sub("", t).strip()) for i, t in H3.findall(body)]
    return body, subs


def main():
    sections, nav, toc = [], [], []
    missing = []
    for part, chapters in PARTS:
        nav.append(f"<h2>{html.escape(part)}</h2>")
        toc.append(f'<div class="toc-part"><h3>{html.escape(part)}</h3><ol{" class=\"alpha\"" if part == "Appendices" else ""}>')
        for num, slug, title in chapters:
            val = f' value="{int(num)}"' if not num.startswith("A") else ""
            toc.append(f'<li{val}><a href="#{sec_id(num)}">{html.escape(title)}</a></li>')
            body, subs = load(num, slug, title)
            if "has not been written yet" in body:
                missing.append(slug)
            label = title if num.startswith("A") else f"{int(num)}. {title}"
            if num.startswith("A"):
                label = f"{num}. {title}"
            nav.append(f'<a class="ch" href="#{sec_id(num)}">{html.escape(label)}</a>')
            for sid, stitle in subs:
                if stitle.lower() in ("exercises", "check your understanding"):
                    continue
                nav.append(f'<a class="sub" href="#{sid}">{html.escape(stitle)}</a>')
            sections.append(body)
        toc.append("</ol></div>")
    with open(os.path.join(ROOT, "tools", "shell.html"), encoding="utf-8") as f:
        shell = f.read()
    page = (shell.replace("{{NAV}}", "\n".join(nav))
                 .replace("{{TOC}}", "\n".join(toc))
                 .replace("{{BODY}}", "\n\n".join(sections))
                 .replace("{{DATE}}", date.today().isoformat()))
    with open(OUT, "w", encoding="utf-8") as f:
        f.write(page)
    words = len(TAG.sub(" ", page).split())
    print(f"wrote {OUT}: {len(page)//1024} KB, ~{words} words, {len(missing)} missing chapters")
    if missing:
        print("missing:", ", ".join(missing))
    return 0


if __name__ == "__main__":
    sys.exit(main())
