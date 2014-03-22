/* Any copyright is dedicated to the Public Domain.
 * http://creativecommons.org/publicdomain/zero/1.0/ */
/* For C++ support */

__calc_base: /* Calculate base address since theres no PIC relocation in text section */
	sub r0, pc, #8 /* true address of this function */
	ldr r1,=__calc_base /* unrelocated zero-based offset of this function */
	sub r0, r0, r1 /* subtract offset to get true address of base */
	mov pc, lr

.section .init
__cpp_init: .global __cpp_init
	push {r0, r1, r4, r5, lr}
	bl __calc_base
	mov r5, r0
	adr r4,ctors
	
	ctor_runloop:
	ldr r0, [r4]
	cmp r0, #-1
	cmpne r0, #0
	addne r0, r0, r5
	movne lr,pc
	movne pc,r0
	addne r4, r4, #4
	bne ctor_runloop
	
	pop {r0, r1, r4, r5, pc}
	ctors: /* Begin list of function pointers */
	
	
.section .fini
__cpp_fini: .global __cpp_fini
	push {r0, r4, r5, lr}
	bl __calc_base
	mov r5, r0
	adr r4,dtors
	
	dtor_runloop:
	ldr r0, [r4]
	cmp r0, #-1
	cmpne r0, #0
	addne r0, r0, r5
	movne lr,pc
	movne pc,r0
	addne r4, r4, #4
	bne dtor_runloop
	
	pop {r0, r4, r5, pc}
	dtors: