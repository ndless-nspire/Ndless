/* Any copyright is dedicated to the Public Domain.
 * http://creativecommons.org/publicdomain/zero/1.0/ */
/* For C++ support */

.section .init_array.0
__cpp_init: .global __cpp_init
	push {r0, r1, r4, r5, lr}
	adr r4,ctors
runloop:
	ldr r0, [r4], #4
	cmp r0, #-1
	cmpne r0, #0
	popeq {r0, r1, r4, r5, pc}
	blx r0
	b runloop

	ctors: /* Begin list of function pointers */

.section .fini_array
__cpp_fini: .global __cpp_fini
	push {r0, r1, r4, r5, lr}
	adr r4,dtors
	b runloop

	dtors:
