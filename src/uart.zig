const uart_regs = @import("uart-regs.zig");
const iomux = @import("iomux-regs.zig");
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
const uart_clock = 24000000;

const uart_base = uart_regs.UART2_BASE;
const ier_addr = uart_base | uart_regs.IER_OFFSET;
const srr_addr = uart_base | uart_regs.SRR_OFFSET;
const mcr_addr = uart_base | uart_regs.MCR_OFFSET;
const lcr_addr = uart_base | uart_regs.LCR_OFFSET;
const dll_addr = uart_base | uart_regs.DLL_OFFSET;
const dlh_addr = uart_base | uart_regs.DLH_OFFSET;
const sfe_addr = uart_base | uart_regs.SFE_OFFSET;
const srt_addr = uart_base | uart_regs.SRT_OFFSET;
const stet_addr = uart_base | uart_regs.STET_OFFSET;
const usr_addr = uart_base | uart_regs.USR_OFFSET;
const thr_addr = uart_base | uart_regs.THR_OFFSET;

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
    const register = iomux.Register.init(iomux.GRFAddr.GPIO4C);
    var reg_val: u32 = 0;
    // enable write to proper bits
    reg_val |= (1 << 22);
    reg_val |= (1 << 24);
    // can now switch mode to UART2
    reg_val |= (1 << 6);
    reg_val = (1 << 8);
    register.reg.write(reg_val);
}

fn setBaudrate(baud: u32) void {
    // per rk3399 TRM:
    // Baudrate = (serial clock freq) / (16 * divisor)
    //
    // We can solve for divisor given a baudrate since we know the clock freq.
    // where divisor is represented by a 32 bit integer stored in the DLL
    // and DLH registers.
    const rate = uart_clock / 16 / baud;

    // write to div_lat_access field to allow DLL and DLH writes
    const lcr_reg = mmio.Register(u32, u32).init(lcr_addr);
    lcr_reg.modify(0x80);

    // write the rate to the DLL and DLH registers
    mmio.Register(void, u32).init(dll_addr).write(rate & 0xff);
    mmio.Register(void, u32).init(dlh_addr).write((rate >> 8) & 0xff);

    // clear div_lat_access field to prevent future DLL and DLH writes
    lcr_reg.write(lcr_reg.read() & ~(@as(u32, 0x80)));
}

/// Initialization function for the uart
pub fn uartInit() void {
    // setup GPIO pin multiplex functions for UART2
    uartIOMux();

    // disable all interrupts
    mmio.Register(void, u32).init(ier_addr).write_raw(0);

    // Reset the uart and both fifos
    mmio.Register(void, u32).init(srr_addr).write(0x1 | 0x2 | 0x4);

    // set MCR register to 0 (broadly disables some stuff)
    mmio.Register(void, u32).init(mcr_addr).write(0);

    // disable parity, set one stop bit, 8 bit width, aka 8n1
    const uart_8n1 = uart_regs.uart_lcr{
        .data_len_sel = 3,
        .stop_bits_num = false, // 0 = 1 bit, 1 = 1.5 bits
        .parity_en = false,
        .even_parity_sel = false,
        .break_ctrl = false,
        .div_lat_access = false,
    };
    mmio.Register(void, uart_regs.uart_lcr).init(lcr_addr).write(uart_8n1);

    setBaudrate(115200);

    // enable the FIFOs and tx empty trigger via their shadow registers
    mmio.Register(void, u32).init(sfe_addr).write(1);
    mmio.Register(void, u32).init(srt_addr).write(1);
    mmio.Register(void, u32).init(stet_addr).write(1);
}

fn putc(char: u8) void {
    const usr_reg = mmio.Register(u32, void).init(usr_addr);

    // wait until the transmit fifo is empty (we are only sending one char
    // at a time right now.
    while ((usr_reg.read() & 0x1) != 0x1) {}

    const xmit_reg = mmio.Register(void, u32).init(thr_addr);
    xmit_reg.write(@as(u32, char));
}

pub fn print(str: []const u8) void {
    for (str) |char| {
        putc(char);
    }
}
