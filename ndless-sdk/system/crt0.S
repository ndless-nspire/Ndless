__base: .global __base /* For backwards compatibility */
_start: .global _start
	/* r12 doesn't need to be pushed, but this preserves 8-byte stack alignment */
	push {r4-r12,lr}
	str  sp, __crt0_savedsp
	push {r0, r1}
	bl initialise_monitor_handles /* Grab stdin, -out and -err, required for newlib */
	bl __cpp_init /* C++ static initializers */
	pop {r0, r1}
	bl   main
	push {r0, r1} /* r0 for return value, r1 for stack alignment */
	bl __cpp_fini /* C++ static destructors */
	pop {r0, r1}
	bl exit /* Jump to newlibs exit, which calls functions registered by atexit */
	
__crt0exit:.global __crt0exit /* For backwards compatibility */
__crt0_exit: .global __crt0_exit
	ldr sp, __crt0_savedsp
	pop {r4-r12,pc}

__crt0_savedsp: .global __crt0_savedsp
	.long 0

/* If linked with -nostdlib */
initialise_monitor_handles: .weak initialise_monitor_handles
	bx lr
