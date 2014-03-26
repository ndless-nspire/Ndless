__base: .global __base
	/* r12 doesn't need to be pushed, but this preserves 8-byte stack alignment */
    push {r4-r12,lr}
	str  sp, __crt0_savedsp
	push {r0, r1}
	bl initialise_monitor_handles /* Grab stdin, -out and -err, required for newlib */
	#ifdef CRT0_CPP
		bl __cpp_init /* C++ static initializers */
	#endif
	pop {r0, r1}
	bl   main
	#ifdef CRT0_CPP
		bl __cpp_fini /* C++ static destructors */
	#endif
	
__crt0exit: .global __crt0exit
	pop {r4-r12,pc}
	
initialise_monitor_handles: .weak initialise_monitor_handles
	bx lr

__crt0_savedsp: .global __crt0_savedsp
	.long 0
