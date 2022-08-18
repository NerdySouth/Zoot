const native_endian = @import("builtin").target.cpu.arch.endian();
const std = @import("std");
const expect = std.testing.expect;

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
/// UART base MMIO addresses. To find these values, look in the Rk3399 TRM
/// at the address mapping section.
pub const UART0_BASE = 0xFF180000;
pub const UART1_BASE = 0xFF190000;
pub const UART2_BASE = 0xFF1A0000;
pub const UART3_BASE = 0xFF1B0000;
pub const UART4_BASE = 0xFF270000;

/// The default uart to use for serial coms
pub const UART_BASE = UART2_BASE;

/// Return an integer type with a single bit set at position x.
/// For example, if we want a 4 bit value with bit 2 set (0100), we
/// can call bitAtPos(u4, 2);
pub fn bitAtPos(
    comptime T: type,
    comptime x: comptime_int,
) T {
    return (1 << x);
}
