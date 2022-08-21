
.section .text.boot
.global _start
_start:
	b	next		// overwritten by mkrock
next:
	msr	DAIFSet, #15		// disable interrupts
    
    // Only proceed on the boot core. Park it otherwise.
	mrs	x1, MPIDR_EL1       // get the core affinities
	and	x1, x1, #3          // isolate core ID with mask 0b11
	cbnz	x1, .L_parking_loop // branch to park loop if core ID is not 0

    // if here, must be boot core
    // jump to C 
	b	zigMain

	// Infinitely wait for events (aka "park the core").
.L_parking_loop:
	wfe
	b	.L_parking_loop


