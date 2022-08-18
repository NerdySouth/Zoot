/*
OUTPUT_FORMAT("elf64-littleaarch64", "elf64-littleaarch64", "elf64-littleaarch64")
OUTPUT_ARCH(aarch64)
 */

ENTRY(_start)

SECTIONS
{
	.text.boot 0xff8c2000 : {
        KEEP(*(.text.boot))
    }

	. = ALIGN(4);
	.text :
	{
		*(.text)
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
