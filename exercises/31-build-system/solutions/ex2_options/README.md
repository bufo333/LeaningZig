# Exercise 31.2: -D options become constants

Finish `build.zig` so that `-Ddifficulty`, `-Dfunds` and `-Dcheats` reach the program
through `@import("build_options")`.

    zig build run
    zig build run -Ddifficulty=hard -Dfunds=500000 -Dcheats
    zig build test --summary all
