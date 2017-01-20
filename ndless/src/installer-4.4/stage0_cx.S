.org 0x0
@ This is loaded at
@ 0x13FF0000: Fake malloc pool
_start: .global start
@ empty

.org 0x100
@ 0x13FF0100: Fake malloc chunk
.word 0x13FF0110
.word 0x10A91468
.word 0x0
.word 0x13FF0000

.org 0x110
@ 0x13FF0110: Fake malloc chunk and jump target
@ The second four bytes will be overwritten by a pointer,
@ several words after that have to be zero.
b start
.word 0x0
.word 0x0
.word 0x0
start:
push {r0-r5, lr}

@ On HW-W+, we need to jump into a LCD buffer mirror
@ CAS or non-CAS?
ldr r4, =0x100303F8 @ CASCX
cmp lr, r4
ldreq r4, =0x113996DC @ lcd_mirror_ptr on CAS CX
ldrne r4, =0xDEADBEEF @ and on CX
ldr r4, [r4] @ Address of LCD mirror
cmp r4, #0
beq bootstrapped @ Not HW-W+
add r4, r4, #(bootstrapped-_start) @ Calculate address
add r4, r4, #(0x13ff0000-0x13fda800) @ of bootstrapped in mirror
mov pc, r4 @ and jump to it
.ltorg

bootstrapped:
@ CAS or non-CAS?
ldr r4, =0x100303F8 @ CASCX
cmp lr, r4
@ preserve lr
mov r5, lr
bl call_main
mov r0, #0
cmp r5, r4
pop {r0-r5, lr}
ldreq pc, =0x1000E234 @ Jump to overwritten _gui_gc_begin
ldrne pc, =0xDEADBEEF

call_main:
	stmfd sp!, {r4-r11,lr} @ and never destroy r0 and r1 which are C's argc and argv
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
__crt0exit: .global __crt0exit
	ldmfd sp!, {r4-r11,pc}

got_offset:
	.word _GLOBAL_OFFSET_TABLE_ - (get_got_offset+8)
__crt0_savedsp: .global __crt0_savedsp
	.long 0
