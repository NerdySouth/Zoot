// This is the real entry point for our program. It simply jumps (or branches,
// using the `b` instruction) to our main function, `zigMain`, written
// in Zig below.
//
// One important thing here is that I place this code in the `.text.boot`
// section of the resulting object. The linker script, `simplest.ld`, makes sure
// this section is placed right at the beginning of the resulting binary. That's
// what I want, because the RockPro64 will start running from the beginning
// of the binary.
//
// Maybe important: the linker will look (by default) for the `_start` symbol as
// the program entry point. As far as I understand, though, this isn't relevant
// for this program, because the RockPro64 will start running from the first
// byte of the image. I am really defining the entry point by using the
// `.text.boot`, and `_start` is effectivelly ignored. However, the linker
// will complain if it can't find `_start`, so I define it here to make our
// tools happy. There's probably a more elegant way to do this...
const gpio = @import("gpio.zig");
//const uart = @import("uart.zig");

extern var __bss_start: u8;
extern var __bss_end: u8;

fn delay() void {
    var def_delay: usize = 1000000;
    const ptr: *volatile usize = &def_delay;

    while (def_delay > 0) {
        ptr.* -= 1;
    }
}

export fn zigMain() noreturn {
    // zero BSS
    @memset(@as(*volatile [1]u8, &__bss_start), 0, @ptrToInt(&__bss_end) - @ptrToInt(&__bss_start));
    // uart.uartInit();
    var rk_gpio = gpio.Gpio.init(gpio.GpioBase.zero);
    const led_mask = @as(u32, 0x800);
    rk_gpio.dir.write(led_mask);
    while (true) {
        rk_gpio.data.write(led_mask);
        delay();
        rk_gpio.data.write(0);
        delay();
    }
    //talker();
    unreachable;
}
