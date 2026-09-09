//! Chapter 35, exercise 3: a tiny SQLite binding.
//! Run with:  zig run -lc -lsqlite3 ex3_sqlite.zig
//! Goal: declare the eight SQLite functions needed to open a database,
//! create a table, insert rows with a prepared statement and read them
//! back. Wrap return codes in Zig errors. Expected output:
//!   sqlite 3.51.0
//!   Grayson earns 1500
//!   Clay earns 800
//!   2 rows

const std = @import("std");

const Handle = opaque {};
const StmtHandle = opaque {};

extern fn sqlite3_libversion() [*:0]const u8;
extern fn sqlite3_open(filename: [*:0]const u8, db: *?*Handle) c_int;
extern fn sqlite3_close(db: *Handle) c_int;
extern fn sqlite3_exec(db: *Handle, sql: [*:0]const u8, cb: ?*anyopaque, arg: ?*anyopaque, errmsg: ?*?[*:0]u8) c_int;
extern fn sqlite3_free(p: ?*anyopaque) void;
extern fn sqlite3_prepare_v2(db: *Handle, sql: [*]const u8, nbyte: c_int, stmt: *?*StmtHandle, tail: ?*?[*]const u8) c_int;
extern fn sqlite3_step(stmt: *StmtHandle) c_int;
extern fn sqlite3_finalize(stmt: *StmtHandle) c_int;
extern fn sqlite3_reset(stmt: *StmtHandle) c_int;
extern fn sqlite3_bind_int64(stmt: *StmtHandle, idx: c_int, v: i64) c_int;
extern fn sqlite3_bind_text(stmt: *StmtHandle, idx: c_int, text: [*]const u8, n: c_int, destructor: ?*const anyopaque) c_int;
extern fn sqlite3_column_int64(stmt: *StmtHandle, col: c_int) i64;
extern fn sqlite3_column_text(stmt: *StmtHandle, col: c_int) ?[*:0]const u8;
extern fn sqlite3_errmsg(db: *Handle) [*:0]const u8;

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

    pub fn prepare(self: Db, sql: []const u8) Error!Stmt {
        var s: ?*StmtHandle = null;
        const rc = sqlite3_prepare_v2(self.h, sql.ptr, @intCast(sql.len), &s, null);
        if (rc != SQLITE_OK or s == null) {
            std.debug.print("sqlite: {s}\n", .{sqlite3_errmsg(self.h)});
            return error.SqliteError;
        }
        return .{ .h = s.? };
    }
};

pub const Stmt = struct {
    h: *StmtHandle,

    pub fn finalize(self: Stmt) void {
        _ = sqlite3_finalize(self.h);
    }

    pub fn bindInt(self: Stmt, idx: c_int, v: i64) Error!void {
        if (sqlite3_bind_int64(self.h, idx, v) != SQLITE_OK) return error.SqliteError;
    }

    pub fn bindText(self: Stmt, idx: c_int, s: []const u8) Error!void {
        if (sqlite3_bind_text(self.h, idx, s.ptr, @intCast(s.len), transient) != SQLITE_OK)
            return error.SqliteError;
    }

    /// Run an INSERT to completion, then reset so it can be bound again.
    pub fn run(self: Stmt) Error!void {
        const rc = sqlite3_step(self.h);
        if (rc != SQLITE_DONE and rc != SQLITE_ROW) return error.SqliteError;
        _ = sqlite3_reset(self.h);
    }

    /// Advance a SELECT: true while rows remain.
    pub fn next(self: Stmt) Error!bool {
        const rc = sqlite3_step(self.h);
        if (rc == SQLITE_ROW) return true;
        if (rc == SQLITE_DONE) return false;
        return error.SqliteError;
    }

    pub fn int(self: Stmt, col: c_int) i64 {
        return sqlite3_column_int64(self.h, col);
    }

    /// Borrowed: valid only until the next step.
    pub fn text(self: Stmt, col: c_int) []const u8 {
        const p = sqlite3_column_text(self.h, col) orelse return "";
        return std.mem.span(p);
    }
};

pub fn main() !void {
    std.debug.print("sqlite {s}\n", .{sqlite3_libversion()});
    const db = try Db.open(":memory:");
    defer db.close();
    try db.exec("CREATE TABLE person (name TEXT, salary INTEGER)");

    const ins = try db.prepare("INSERT INTO person VALUES (?1, ?2)");
    defer ins.finalize();
    const people = [_]struct { name: []const u8, salary: i64 }{
        .{ .name = "Grayson", .salary = 1500 },
        .{ .name = "Clay", .salary = 800 },
    };
    for (people) |p| {
        try ins.bindText(1, p.name);
        try ins.bindInt(2, p.salary);
        try ins.run();
    }

    const sel = try db.prepare("SELECT name, salary FROM person");
    defer sel.finalize();
    var rows: u32 = 0;
    while (try sel.next()) : (rows += 1) {
        std.debug.print("{s} earns {d}\n", .{ sel.text(0), sel.int(1) });
    }
    std.debug.print("{d} rows\n", .{rows});
}
