/*
 * This file is wrapped as host-side object file pointed to by the symbol binary_snippets_bin_start
 * and ending at binary_armsnippets_bin_end.
 */

// From Ndless's include/syscalls.h
#define __SYSCALLS_ISEMU 0x400000
#define NDLSEMU_DEBUG_ALLOC (__SYSCALLS_ISEMU | 0)
#define NDLSEMU_DEBUG_FREE (__SYSCALLS_ISEMU | 1)

start:
	.word load_snippet - start

snippets_list:      @ defined by SNIPPET_*
	.word ndls_debug_alloc - snippets_list
	.word ndls_debug_free - snippets_list 

@ The snippets should return to the caller with ldmfd sp, {pc}
@ input:
@  lr=return address
@  r12=index (SNIPPET_*)
@ destroys: r10, r12
load_snippet:
	stmfd sp!, {lr}
	adr   r10, snippets_list
	ldr   r12, [r10, r12, lsl#2]
	add   r10, r10, r12
	bx    r10

// See Ndless's emu.c
ndls_debug_alloc:
	swi  NDLSEMU_DEBUG_ALLOC
	ldmfd sp, {pc}

ndls_debug_free:
	swi  NDLSEMU_DEBUG_FREE
	ldmfd sp, {pc}
