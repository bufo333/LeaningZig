//! Chapter 35, exercise 3: a tiny SQLite binding.
//! Run with:  zig run -lc -lsqlite3 ex3_sqlite.zig
//! Goal: declare the eight SQLite functions needed to open a database,
//! create a table, insert rows with a prepared statement and read them
//! back. Wrap return codes in Zig errors. Expected output:
//!   sqlite 3.51.0
//!   Grayson earns 1500
//!   Clay earns 800
//!   2 rows
//! STARTER: this file does not compile until you fill in the TODOs.

const std = @import("std");

const Handle = opaque {};
const StmtHandle = opaque {};

extern fn sqlite3_libversion() [*:0]const u8;
extern fn sqlite3_open(filename: [*:0]const u8, db: *?*Handle) c_int;
extern fn sqlite3_close(db: *Handle) c_int;
extern fn sqlite3_exec(db: *Handle, sql: [*:0]const u8, cb: ?*anyopaque, arg: ?*anyopaque, errmsg: ?*?[*:0]u8) c_int;
extern fn sqlite3_free(p: ?*anyopaque) void;
// TODO: declare sqlite3_prepare_v2, sqlite3_step, sqlite3_finalize, sqlite3_reset,
// sqlite3_bind_int64, sqlite3_bind_text, sqlite3_column_int64, sqlite3_column_text,
// sqlite3_errmsg. See src/persist/sqlite.zig in the game for the signatures.

const SQLITE_OK = 0;
const SQLITE_ROW = 100;
const SQLITE_DONE = 101;
const transient: ?*const anyopaque = @ptrFromInt(std.math.maxInt(usize));

pub const Error = error{SqliteError};

pub const Db = struct {
    h: *Handle,

    pub fn open(path: [*:0]const u8) Error!Db {
        var h: ?*Handle = null;
        if (sqlite3_open(path, &h) != SQLITE_OK or h == null) return error.SqliteError;
        return .{ .h = h.? };
    }

    pub fn close(self: Db) void {
        _ = sqlite3_close(self.h);
    }

    pub fn exec(self: Db, sql: [*:0]const u8) Error!void {
        var err: ?[*:0]u8 = null;
        if (sqlite3_exec(self.h, sql, null, null, &err) != SQLITE_OK) {
            if (err) |e| {
                std.debug.print("sqlite: {s}\n", .{e});
                sqlite3_free(e);
            }
            return error.SqliteError;
        }
    }

    // TODO: pub fn prepare(self: Db, sql: []const u8) Error!Stmt
};

pub const Stmt = struct {
    h: *StmtHandle,

    // TODO: finalize, bindInt, bindText, run, next, int, text
};

pub fn main() !void {
    std.debug.print("sqlite {s}\n", .{sqlite3_libversion()});
    const db = try Db.open(":memory:");
    defer db.close();
    try db.exec("CREATE TABLE person (name TEXT, salary INTEGER)");
    // TODO: prepare an INSERT, bind and run it for Grayson/1500 and Clay/800,
    // then prepare a SELECT and print each row, then the row count.
}
