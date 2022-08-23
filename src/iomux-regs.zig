const mmio = @import("mmio.zig");
/// IOMUX: IO Multiplexing
/// This is for the problem of having more onboard perpherals/services than
/// we have pins for. Although each pin on the system can only be used for
/// one peripheral/service at a time, we can dynamically assign which perpherals
/// or service it should perform internally.
/// See the GRF (General Register Files) chapter of the RK3399 TRM for more
/// info
const GRF_BASE = 0xFF770000;
const IOMUX_BASE = 0xFF77E000;
const GPIO4B_OFFSET = 0xE024;
const GPIO4C_OFFSET = 0xE028;
const PMU_GRF_BASE = 0xFF320000;

pub const Register = struct {
    reg: mmio.Register(u32, u32),

    pub fn init(comptime addr: GRFAddr) Register {
        return Register{ .reg = mmio.Register(u32, u32).init(@enumToInt(addr)) };
    }
};

pub const GRFAddr = enum(u32) {
    GPIO4B = GRF_BASE + GPIO4B_OFFSET,
    GPIO4C = GRF_BASE + GPIO4C_OFFSET,
};

/// GPIO4B IOMUX Control Register
const gpio_4b_grf = packed struct(u32) {
    sel_0: u2,
    sel_1: u2,
    sel_2: u2,
    sel_3: u2,
    sel_4: u2,
    sel_5: u2,
    _reserbed12_15: u4,
    write_enable: u16,
};

/// GPIO4C IOMUX Control Register
pub const gpio_4c_grf = packed struct(u32) {
    sel_0: u2,
    sel_1: u2,
    sel_2: u2,
    sel_3: u2,
    sel_4: u2,
    sel_5: u2,
    sel_6: u2,
    sel_7: u2,
    write_enable: u16,
};
