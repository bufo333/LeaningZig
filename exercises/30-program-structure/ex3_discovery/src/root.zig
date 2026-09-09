//! Chapter 30, exercise 3: test discovery across a tree of files.
//! Run with:  zig build test --summary all   (inside ex3_discovery/)
//! Goal: make `zig build test` report 4 tests, without touching the
//!       other files. Hint: tests only run in files that are referenced.
//! This starter does not compile until every TODO is filled in.
const std = @import("std");

pub const money = @import("sim/money.zig");
pub const clock = @import("sim/clock.zig");

// TODO: add a test block that makes every file's tests visible.
