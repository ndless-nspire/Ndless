@ startup code

_start: .global _start
	@ signature identifying a program
	.asciz "PRG"

	stmfd sp!, {r4-r12,lr} @ and never destroy r0 and r1 which are C's argc and argv
	@ GOT-based relocation, required for C global variables. The program must be built with the GCC option -fpic.
relocate:
	@ Get the absolute address of the GOT. See http://www.google.com/codesearch/p?hl=en#FiIujMxKUHU/sites/sources.redhat.com/pub/glibc/snapshots/glibc-ports-latest.tar.bz2%7CDNu48aiJSpY/glibc-ports-20090518/sysdeps/arm/dl-machine.h&q=%22.word%20_GLOBAL_OFFSET_TABLE_%22
	ldr   r2, got_offset
get_got_offset:	
	add   r2, pc, r2
	adr   r3, _start
	ldr   r5, =__got_size
relocate_loop:
	subs  r5, #1
	ldrge r4, [r2]       @ next GOT entry
	addge r4, r4, r3     @ calculate the absolute address
	strge r4, [r2], #4   @ store it back to the GOT
	bge   relocate_loop

	str  sp, __crt0_savedsp
	bl   main

__crt0_exit: .global __crt0_exit
	ldr sp, __crt0_savedsp
	ldmfd sp!, {r4-r12,pc}

got_offset:
	.word _GLOBAL_OFFSET_TABLE_ - (get_got_offset+8)
__crt0_savedsp: .global __crt0_savedsp
	.long 0
