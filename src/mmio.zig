/// Function for creating a Register struct. A register can be read or written,
/// but may have different behavior or characteristics depending on which
/// you choose to do. This allows us to instantiate Register instances that
/// can handle that fact.
pub fn mmioRegister(comptime Read: type, comptime Write: type) type {
    return struct {
        // mark the ptr as volatile so the compiler wont
        // reorder reads/writes
        raw_ptr: *volatile u32,

        // The type being returned inside this function doesnt have a name
        // yet when its being created, so we have to refer to it using
        // '@This()'
        const Self = @This();

        pub fn init(addr: usize) Self {
            return .{
                .raw_ptr = addr,
            };
        }

        pub fn read_raw(self: Self) u32 {
            return @bitCast(u32, self.raw_ptr.*);
        }

        pub fn write_raw(self: Self, val: u32) void {
            self.raw_ptr.* = @bitCast(u32, val);
        }

        pub fn read(self: Self) Read {
            return @bitCast(Read, self.raw_ptr.*);
        }

        pub fn write(self: Self, val: Write) void {
            self.raw_ptr.* = @bitCast(Write, val);
        }

        pub fn modify(self: Self, new_val: anytype) void {
            if (Read != Write) {
                @compileError("Can't modify register b/c read and write types for this register aren't the same");
            }
            var old_val = self.read();
            const info = @typeInfo(@TypeOf(new_val));
            inline for (info.Struct.fields) |field| {
                // change the field with old_val to new_val
                @field(old_val, field.name) = @field(new_val, field.name);
            }
            self.write(old_val);
        }
    };
}
