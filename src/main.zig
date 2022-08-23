const gpio = @import("gpio.zig");
const uart = @import("uart.zig");

extern var __bss_start: u8;
extern var __bss_end: u8;

fn delay() void {
    var def_delay: usize = 1000000;
    const ptr: *volatile usize = &def_delay;

    while (def_delay > 0) {
        ptr.* -= 1;
    }
}

fn talker() void {
    while (true) {
        uart.print("Zoot\n");
    }
}

/// Zig entry point for the first bit of user code loaded by the BROM into the
/// 192K SRAM. The main goal is to initialize DDR Memory, then we can load
/// programs to RAM and run there.
export fn zigMain() noreturn {
    // zero BSS
    @memset(@as(*volatile [1]u8, &__bss_start), 0, @ptrToInt(&__bss_end) - @ptrToInt(&__bss_start));
    uart.uartInit();
    var rk_gpio = gpio.Gpio.init(gpio.GpioBase.zero);
    const led_mask = @as(u32, 0x800);
    rk_gpio.dir.write(led_mask);
    rk_gpio.data.write(led_mask);
    delay();
    rk_gpio.data.write(0);
    delay();
    talker();
    unreachable;
}
