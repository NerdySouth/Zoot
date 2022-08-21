/// A register can be read or written, but may have different behavior or characteristics depending on which
/// you choose to do. This allows us to instantiate Register instances that
/// can handle that fact by having distinct read and write types.
pub fn Register(comptime Read: type, comptime Write: type) type {

    // does not make sense to try and make a register that cannot be read from
    // or written to, so raise a compile error to let the programmer know.
    comptime {
        if (Read == void and Write == void) {
            @compileError("Cannot have register that cannot be read or written.");
        }
    }

    return struct {
        // mark the ptr as volatile so the compiler wont
        // reorder reads/writes
        raw_ptr: *volatile u32 = undefined,

        // The type being returned inside this function doesnt have a name
        // yet when its being created, so we have to refer to it using
        // '@This()'
        const Self = @This();

        // Since we are representing MMIO here, the addr of a register should be
        // known at compile time. This will complain if we try to pass it an
        // addr only known at runtime.
        pub fn init(comptime addr: usize) Self {
            // check if we are trying to make a register from the null addr
            comptime {
                if (addr == 0) {
                    @compileError("Cannot assign address 0 as a register.");
                }
            }

            return .{
                .raw_ptr = @intToPtr(*volatile u32, addr),
            };
        }

        pub fn read_raw(self: Self) u32 {
            // Can give a register a void read type to prevent reads to
            // a write only register. This will raise a compiler error to the
            // developer if they try to read after setting the register as
            // Write only.
            comptime {
                if (Read == void) {
                    @compileError("Cannot read from write-only register.");
                }
            }
            return @bitCast(u32, self.raw_ptr.*);
        }

        pub fn write_raw(self: Self, val: u32) void {
            // can give a register a void write type to prevent writes
            // to a read only register
            comptime {
                if (Write == void) {
                    @compileError("Cannot write to read-only register.");
                }
            }
            self.raw_ptr.* = @bitCast(u32, val);
        }

        pub fn read(self: Self) Read {
            // Can give a register a void read type to prevent reads to
            // a write only register
            comptime {
                if (Read == void) {
                    @compileError("Cannot read from write-only register.");
                }
            }
            return @bitCast(Read, self.raw_ptr.*);
        }

        pub fn write(self: Self, val: Write) void {
            // can give a register a void write type to prevent writes
            // to a read only register
            comptime {
                if (Write == void) {
                    @compileError("Cannot write to read-only register.");
                }
            }

            // cast to u32 here because thats what the underlying ptr is expecting
            self.raw_ptr.* = @bitCast(u32, val);
        }

        pub fn modify(self: Self, new_val: anytype) void {
            comptime {
                if (Read != Write) {
                    @compileError(
                        \\Can't modify register b/c read and write types for 
                        \\this register aren't the same
                    );
                }
            }
            var old_val = self.read();
            const info = @typeInfo(@TypeOf(new_val));
            // for every field on our new val, change the value on old val
            // to match it
            inline for (info.Struct.fields) |field| {
                // change the field with old_val to new_val
                @field(old_val, field.name) = @field(new_val, field.name);
            }
            self.write(old_val);
        }
    };
}
