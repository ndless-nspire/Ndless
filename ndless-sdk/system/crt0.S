_start: .global _start
	/* r12 doesn't need to be pushed, but this preserves 8-byte stack alignment */
    push {r4-r12,lr}
	str  sp, __crt0_savedsp
	push {r0, r1}
	bl initialise_monitor_handles /* Grab stdin, -out and -err, required for newlib */
	bl __cpp_init /* C++ static initializers */
	pop {r0, r1}
	bl   main
	bl __cpp_fini /* C++ static destructors */
	
__crt0_exit: .global __crt0_exit
	pop {r4-r12,pc}

__crt0_savedsp: .global __crt0_savedsp
	.long 0
