const mmio_register = @import("mmio.zig");
/// IOMUX: IO Multiplexing
/// This is for the problem of having more onboard perpherals/services than
/// we have pins for. Although each pin on the system can only be used for
/// one peripheral/service at a time, we can dynamically assign which perpherals
/// or service it should perform internally.
/// See the GRF (General Register Files) chapter of the RK3399 TRM for more
/// info
pub const GRF_BASE = 0xFF770000;
pub const GPIO4B_OFFSET = 0xE024;
pub const GPIO4C_OFFSET = 0xE028;
pub const PMU_GRF_BASE = 0xFF320000;

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

/// Create a mmio register struct for the gpio 4B grf register
pub const gpio_4b_reg = mmio_register.Register(gpio_4b_grf, gpio_4b_grf).init(GRF_BASE + GPIO4B_OFFSET);

/// GPIO4C IOMUX Control Register
const gpio_4c_grf = packed struct(u32) {
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

pub const gpio_4c_reg = mmio_register.Register(gpio_4c_grf, gpio_4c_grf).init(GRF_BASE + GPIO4C_OFFSET);
