# Zig from Zero to IRON LEDGER

A slow, exercise-driven course in Zig 0.16 that starts from installing the
compiler and ends by reading the source of IRON LEDGER, the pure-Zig
BattleTech mercenary-company simulator in `../game/`
([bufo333/IronLedger](https://github.com/bufo333/IronLedger) on GitHub).

This course lives at [bufo333/LeaningZig](https://github.com/bufo333/LeaningZig).

Open **`index.html`** in a browser. That is the whole book: 57 chapters,
208 exercises with hidden solutions (167 of them runnable files checked against Zig 0.16, the rest done inside the game repo in Part 5), a quiz per chapter, and five appendices.

## Layout

```
index.html              the assembled book (open this)
chapters/NN-slug.html   one HTML fragment per chapter (the source of truth)
exercises/NN-slug/      starter files for that chapter's exercises
exercises/NN-slug/solutions/   verified solutions
reference/original-guide.{html,md}   the short guide this book expanded from
reference/verified-idioms/           small Zig 0.16 programs proving the APIs used
tools/assemble.py       rebuilds index.html from chapters/ and tools/shell.html
tools/check.sh          compiles and runs every solution with zig 0.16
tools/shell.html        page template: styles, sidebar, client-side Zig highlighter
CONTRACT.md             the authoring rules every chapter follows
```

## Working through it

1. Install Zig 0.16 (`brew install zig` on macOS) and confirm with `zig version`.
2. Read chapters in order. Each ends with exercises. Open the starter file
   named in the exercise, complete it, and run the command in its header
   comment (`zig run file.zig` or `zig test file.zig`).
3. Reveal the solution in the book only after your own attempt runs.
4. Part 5 is read alongside the game's source in `../game/`. Clone it
   next to this directory:

   ```
   git clone git@github.com:bufo333/IronLedger.git game
   ```

## Maintaining it

- Edit a chapter fragment in `chapters/`, then run `python3 tools/assemble.py`.
- Run `tools/check.sh` (or `tools/check.sh 04 16` for two chapters) after
  touching any solution; every solution must stay green on Zig 0.16.
- The rules for new chapters are in `CONTRACT.md`.
