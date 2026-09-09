//! Shared typed IDs. Nothing here depends on any other file.
pub const PersonId = enum(u32) {
    _,
    pub fn index(self: PersonId) usize {
        return @intFromEnum(self);
    }
};
