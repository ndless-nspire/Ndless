#ifndef HOOK_H
#define HOOK_H

#include <os.h>

/* Hooked functions and hooks must be built in ARM and not Thumb.
 * 8 bytes are overwritten. They musn't contain relative accesses such as jumps. */
#define HOOK_INSTALL(address, hookname) do { \
	void hookname(void); \
	extern unsigned __##hookname##_end_instrs[4]; /* orig_instrs1; orig_instrs2; ldr pc, [pc, #-4]; .long return_addr */ \
	__##hookname##_end_instrs[3] = (unsigned)(address) + 8; \
	__##hookname##_end_instrs[0] = *(unsigned*)(address); \
	*(unsigned*)(address) = 0xE51FF004; /* ldr pc, [pc, #-4] */ \
	__##hookname##_end_instrs[1] = *(unsigned*)((address) + 4); \
	*(unsigned*)((address) + 4) = (unsigned)hookname; \
	__##hookname##_end_instrs[2] = 0xE51FF004; /* ldr pc, [pc, #-4] */ \
	clear_cache(); \
	} while (0)

/* Caution, hooks aren't re-entrant.
* Must always exits with either HOOK_RESTORE_RETURN, HOOK_RETURN or HOOK_RESTORE_RETURN_SKIP.
 * A non-inlined body is required because naked function cannot use local variables.
 * A naked function is required because the return is handled by the hook, and to avoid any
 * register modification before they are saved */
#define HOOK_DEFINE(hookname) \
	unsigned __##hookname##_end_instrs[4]; \
	extern unsigned __##hookname##_saved_sp; \
	void __##hookname##_body(void); \
	void __attribute__((naked)) hookname(void) { \
		__asm volatile (" b 0f; " STRINGIFY(__##hookname##_saved_sp) ": .long 0; 0:"); /* accessed with pc-relative instruction. In hookname() else moved too far by GCC. */ \
		__asm volatile(" stmfd sp!, {r0-r12,lr}"); /* used by HOOK_RESTORE_STATE() */ \
		/* save sp */ \
		__asm volatile( \
			" str r0, [sp, #-4] @ push r0 but don't change sp \n " \
			" adr r0," STRINGIFY(__##hookname##_saved_sp) "\n" \
			" str sp, [r0] \n" \
			" ldr r0, [sp, #-4] @ pop r0 but don't change sp \n" \
		); \
		 __##hookname##_body(); \
	} \
	void __##hookname##_body(void)

/* Jump out of the body */
#define HOOK_RESTORE_SP(hookname) do { \
	__asm volatile( \
		" str lr, [sp, #-4]! @ push lr \n" \
		" adr lr," STRINGIFY(__##hookname##_saved_sp) "\n" \
		" ldr lr, [lr] \n" \
		" str lr, [sp, #-4]! \n" /* push lr=saved_sp. trick to restore both saved_sp and the original lr */ \
		" ldmfd sp, {sp, lr} \n" /* lr has been used instead of r0 to avoid a GAS warning about reg order on this instr */ \
	); \
} while (0)

/* Read-write: can be used to access the values that had the registers when the hook was called: {r0-r12,lr} */
#define HOOK_SAVED_REGS(hookname) ((unsigned*) __##hookname##_saved_sp)

#define HOOK_SAVED_SP(hookname) ((void*) __##hookname##_saved_sp)

#define HOOK_RESTORE_STATE() do { \
	__asm volatile(" ldmfd sp!, {r0-r12,lr}"); \
} while (0)


/* Call HOOK_RESTORE() alone to return manually with __asm(). */
#define HOOK_RESTORE(hookname) { \
	HOOK_RESTORE_SP(hookname); \
	HOOK_RESTORE_STATE(); \
} while (0)

/* If register values needs to be changed before a hook return, call HOOK_RESTORE(),
 * set the registers then call HOOK_RETURN. Caution, only assembly without local
 * variables can between the 2 calls. */
#define HOOK_RETURN(hookname) do { \
	__asm volatile(" b " STRINGIFY(__##hookname##_end_instrs)); \
} while (0)

/* Standard hook return */
#define HOOK_RESTORE_RETURN(hookname) do { \
	HOOK_RESTORE(hookname); \
	HOOK_RETURN(hookname); \
} while (0)

/* Hook return skipping instructions.
 * The 2 instructions overwritten by the hook are always skipped, the offset is based from the third instruction.
 * Any use must come with a call to HOOK_SKIP_VAR() outside of the hook function
 * id is a unique id for the hook */
#define HOOK_RESTORE_RETURN_SKIP(hookname, offset,id) do { \
	__asm volatile( \
		" adr r0, " STRINGIFY(__##hookname##_return_skip##id) "\n" \
		"	str %0, [r0] \n" \
		:: "r"(__##hookname##_end_instrs[3] + offset) : "r0"); \
	HOOK_RESTORE(hookname); \
	__asm volatile( \
		" ldr pc, [pc, #-4] \n" \
	  STRINGIFY(__##hookname##_return_skip##id) ":" \
		" .long 0"); \
	} while (0)

#define HOOK_SKIP_VAR(hookname, offset) \
	volatile unsigned __##hookname##_end_instrs_skip##offset[2]; /* ldr pc, [pc, #-4]; .long return_addr */ \

#define HOOK_UNINSTALL(address, hookname) do { \
	extern unsigned __##hookname##_end_instrs[4]; /* orig_instrs1; orig_instrs2; ... */ \
	*(unsigned*)(address) = __##hookname##_end_instrs[0]; \
	*(unsigned*)((address) + 4) = __##hookname##_end_instrs[1]; \
	clear_cache(); \
} while (0)

#endif // !HOOK_H
