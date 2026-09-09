# Exercise 31.3: custom steps

Add a `demo` step that runs the program with three fixed arguments, and a `fmt` step
that checks formatting; make `test` depend on the format check too.

    zig build -l
    zig build demo
    zig build test --summary all
