const native_endian = @import("builtin").target.cpu.arch.endian();
const std = @import("std");
const expect = std.testing.expect;
const uart_regs = @import("uart-regs.zig");
const iomux_regs = @import("iomux-regs.zig");
const mmio = @import("mmio.zig");

/// RK3399 UART's
/// The RK3399 has 5 independent UART's. All 5 contain two 64 Byte FIFOs for
/// data receive and transmit. UART0 and UART3 support auto flow-control.
/// Bitrates:
///     - 115.2Kbps
///     - 460.8Kbps
///     - 921.6Kbps
///     - 1.5Mbps
///     - 3Mbps
///     - 4Mbps
/// All support programmable baud rates, even with non-integer clock divider
/// Start, Stop, Parity bits.
/// Interrupt-based or DMA mode
/// support 5-8 bit width transfer
/// See section UART, page 439 of the RK3399 Technical Reference Manual for
/// more info.
/// Return an integer type with a single bit set at position x.
/// For example, if we want a 4 bit value with bit 2 set (0100), we
/// can call bitAtPos(u4, 2);
pub fn bitAtPos(
    comptime T: type,
    comptime x: comptime_int,
) T {
    return (1 << x);
}

/// Sets the GPIO pins 8 and 10 up for use by the UART2
/// See page 204 in TRM. Note that GRF is General Register Files.
/// On page 55 of the data sheet, we see:
/// GPIO_B0 is our uart Rx when func 3 is selected
/// GPIO_B1 is our uart Tx when func 3 is selected.
/// This particular GRF is described on page 309 of the TRM.
fn uartIOMux() void {
    // The top 16 bits of the IOMUX register control whether or not software
    // can write to the lower 16 bits. Bit 16 controls writes to bit 0.
    //
    // We want to set gpio_4c.sel_3 and sel_4 to mode 1 (0b01), since this is
    // the mode for UART2
    //
    // It does appear that the TRM says we could use the GPIO_4B GRF, but
    // it appears to  work just fine using this method as well.
    const register = iomux_regs.gpio_4c_reg;
    var reg_val = register.read();
    reg_val.write_enable = (reg_val.write_enable & 0xA0);
    register.write(reg_val);

    // can now switch mode to UART2
    reg_val.sel_3 = 1;
    reg_val.sel_4 = 1;
    register.write(reg_val);

    // close off bit write access
    reg_val.write_enable = 0;
    register.write(reg_val);
}

/// Initialization function for the uart
pub fn uartInit() void {
    const uart_base = uart_regs.UART2_BASE;
    
    // setup GPIO pin multiplex functions for UART2 
    uartIOMux();
    
    // Reset the uart and both fifos 
    const srr_reg = mmio.Register(void, uart_regs.uart_srr).init(uart_base + uart_regs.SRR_OFFSET);


    
}
