.org 0x0
@ This is loaded at
@ 0x13FF0000: Fake malloc pool
_start: .global _start
@ empty

.org 0x100
@ 0x13FF0100: Fake malloc chunk and jump target
@ The second four bytes will be overwritten by a pointer,
@ several words after that have to be zero.
b start
.word 0x0
.word 0x0
.word 0x0
start:
bkpt

push {lr}

@ Find broken chunk
ldr r0, =0x11190a44 @ pool->first chunk
ldr r1, =0x13FF0000 @ fake_pool

loop:
ldr r2, [r0, #0x0] @ r2 = r0->next
ldr r3, [r2, #0xc] @ r3 = chunk->next->pool
cmp r3, r1 @ chunk->next->pool == fake_pool?
beq found
mov r0, r2 @ Nope -> next
b loop
found: @ Yep -> r2 is overflown/broken chunk

@ Repair it
add r1, r2, #0xA00000
add r1, r1, #0x10
str r1, [r2, #0x0] @ broken->next = broken + (40*262144) + sizeof(malloc_header)
str r0, [r2, #0x4] @ broken->prev = r0
mov r1, #0
str r1, [r2, #0x8] @ broken->free = 0
ldr r1, =0x11190a10
str r1, [r2, #0xc] @ broken->pool = pool
add r0, r2, #0x10
mov lr, pc
ldr pc, =0x1040E974 @ free(broken + sizeof(malloc_header))

bl call_main
	
mov r0, #0
pop {pc}

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