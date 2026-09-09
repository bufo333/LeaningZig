# Exercise 31.1: two modules

Finish `build.zig`: expose `lib/dice.zig` as a module named `dice`, import it from the
executable rooted at `src/main.zig`, and add `run` and `test` steps.

    zig build run -- 3025
    zig build test --summary all
