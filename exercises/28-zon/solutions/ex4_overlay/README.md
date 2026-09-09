# Exercise 28.4: a mod overlay with addAnonymousImport

Finish `build.zig` so that `@import("tuning_zon")` in `src/main.zig` resolves to
`data/tuning.zon` by default, or to `<dir>/tuning.zon` when you pass `-Ddata=<dir>`.

    zig build run
    zig build run -Ddata=mods/hardcore
    zig build test --summary all
