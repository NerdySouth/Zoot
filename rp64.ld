/*
OUTPUT_FORMAT("elf64-littleaarch64", "elf64-littleaarch64", "elf64-littleaarch64")
OUTPUT_ARCH(aarch64)
 */

ENTRY(_start)

SECTIONS
{
	. = 0xFF8C2000;

	. = ALIGN(4);
	.text :
	{
        KEEP(*(.text.boot))
		*(.text)
	}

    .rodata : ALIGN(4K) {
        *(.rodata)
        __debug_info_start = .;
        KEEP(*(.debug_info))
        __debug_info_end = .;
        __debug_abbrev_start = .;
        KEEP(*(.debug_abbrev))
        __debug_abbrev_end = .;
        __debug_str_start = .;
        KEEP(*(.debug_str))
        __debug_str_end = .;
        __debug_line_start = .;
        KEEP(*(.debug_line))
        __debug_line_end = .;
        __debug_ranges_start = .;
        KEEP(*(.debug_ranges))
        __debug_ranges_end = .;
    }

    .data : ALIGN(4) {
        *(.data)
    }

    .bss : ALIGN(4) {
        __bss_start = .;
        *(COMMON)
        *(.bss)
        __bss_end = .;
    }
    
	 /*
	 * But there's one thing I do here: I discard all sections that I don't want
	 * but for some reason the compiler generates. I inspected the generated
	 * ELF found them with `zig build dump-elf` to find everything I wanted to
	 * discard.
	 */
	/DISCARD/ : {
			*(.ARM.*)
			*(.debug_*)
			*(.comment)
	}
}
