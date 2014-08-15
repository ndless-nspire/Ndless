/* Any copyright is dedicated to the Public Domain.
 * http://creativecommons.org/publicdomain/zero/1.0/ */
/* For C++ support */

.section .init_array
__cpp_init: .global __cpp_init
	push {r0, r1, r4, r5, lr}
	adr r4,ctors
	
	ctor_runloop:
	ldr r0, [r4]
	cmp r0, #-1
	popeq {r0, r1, r4, r5, pc}
	cmp r0, #0
	popeq {r0, r1, r4, r5, pc}
	mov lr,pc
	mov pc,r0
	add r4, r4, #4
	b ctor_runloop
	
	ctors: /* Begin list of function pointers */
	
	
.section .fini_array
__cpp_fini: .global __cpp_fini
	push {r0, r1, r4, r5, lr}
	adr r4,dtors
	
	dtor_runloop:
	ldr r0, [r4]
	cmp r0, #-1
	popeq {r0, r1, r4, r5, pc}
	cmp r0, #0
	popeq {r0, r1, r4, r5, pc}
	mov lr,pc
	mov pc,r0
	add r4, r4, #4
	b dtor_runloop
	
	dtors:
