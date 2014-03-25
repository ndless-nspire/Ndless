/****************************************************************************
 * Ndless interrupt handlers
 *
 * The contents of this file are subject to the Mozilla Public
 * License Version 1.1 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 *
 * The Original Code is Ndless code.
 *
 * The Initial Developer of the Original Code is Olivier ARMAND
 * <olivier.calc@gmail.com>.
 * Portions created by the Initial Developer are Copyright (C) 2010-2013
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s): 
 *                 Geoffrey ANNEHEIM <geoffrey.anneheim@gmail.com>
 ****************************************************************************/

#include <os.h>
#include "ndless.h"

extern void *ints_next_descriptor_ptr; // but static
extern void ints_swi_handler(void);

void ints_setup_handlers(void) {
#ifdef _NDLS_LIGHT
	*(void**)INTS_SWI_HANDLER_ADDR = &ints_swi_handler;
#else
	void **adr_ptr = (void**)INTS_INIT_HANDLER_ADDR;
	// The address is used by nspire_emu for OS version detection and must be restored to the OS value
	*adr_ptr = *(void**)(OS_BASE_ADDRESS + INTS_INIT_HANDLER_ADDR);
	*(adr_ptr + 2) = &ints_swi_handler;
	// also change the SWI handler in the OS code, required by the N-ext convention
	*(void**)(OS_BASE_ADDRESS + INTS_SWI_HANDLER_ADDR) = &ints_swi_handler;
 	ints_next_descriptor_ptr = &ut_next_descriptor;
#endif
}

/* All the code run with _NDLS_LIGHT defined must be PC-relative (the loader is not relocated)
 * TODO:
 * Check that the swi number is correct
 */
asm(
" .arm \n"
#ifndef STAGE1
" @ N-ext convention: a signature and a pointer to the descriptor, before the SWI handler address in the OS copy of the vectors \n"
" .long " STRINGIFY(NEXT_SIGNATURE) "\n"
"ints_next_descriptor_ptr: .long 0 \n"
#endif
"ints_swi_handler: .global ints_swi_handler  @ caution: 1) only supports calls from the svc mode (i.e. the mode used by the OS) 2) destroys the caller's mode lr \n"
" stmfd sp!, {r0-r2, r3}  @ r3 is dummy and will be overwritten with the syscall address. Caution, update the offset below if reg list changed. \n"
" mrs	  r0, spsr \n"
" tst   r0, #0b100000     @ caller in thumb state? \n"
" beq   stateok           @ ARM state \n"
" add   lr, lr, #1        @ so that the final 'bx lr' of the syscall switches back to thumb state \n"
" bic   r0, #0b100000     @ clear the caller's thumb bit. The syscall is run in 32-bit state \n"
"stateok: \n"
" adr   r1, saved_spsr \n"
" ldr   r2, [r1] \n"
#ifndef STAGE1
" @ no recursion support required for stage 1\n"
" cmp   r2, #0 \n"
" addne r1, #8          @ use vars for level-1 recursion \n"
#endif
" str   r0, [r1], #4 \n"
" str   lr, [r1]          @ save to saved_lr \n"
" msr   spsr, r0 \n"
" subs  pc, pc, #4        @  move spsr to cpsr (restore the ints mask) \n"
"@ extract the syscall number from the comment field of the swi instruction \n"
" tst   lr, #1            @ was the caller in thumb state? \n"
" ldreq r0, [lr, #-4]     @ ARM state \n"
" biceq r0, r0, #0xFF000000 \n"
" ldrneh r0, [lr, #-3]    @ thumb state (-2-1, because of the previous +1) \n"
" bicne r0, r0, #0xFF00 \n"
#ifndef _NDLS_LIGHT // with extension/emu support
" mov   r1, r0            @ syscall number \n"
" and   r1, #0xE00000   @ keep the 3-bit flag \n"
" bic   r0, #0xE00000   @ clear the flag \n"
" cmp   r1, #" STRINGIFY(__SYSCALLS_ISEXT) "\n"
" beq   is_ext_syscall \n"
" cmp   r1, #" STRINGIFY(__SYSCALLS_ISEMU) "\n"
" beq   is_emu_syscall \n"
#endif
" ldr   r2, sc_addrs_ptr  @ OS syscalls table \n"
" ldr   r0, [r2, r0, lsl #2] @ syscall address \n"
#ifndef _NDLS_LIGHT // with var support
" cmp   r1, #" STRINGIFY(__SYSCALLS_ISVAR) "\n"
" bne   jmp_to_syscall \n"
" str   r0, [sp]          @ overwrite the saved r0: it's the return value \n"
" adr   r0, back_to_caller @ go directly to back_to_caller instead of jumping to the syscall \n"
#endif
"jmp_to_syscall: \n"
" str   r0, [sp, #12]     @ overwrite the dummy register previously saved \n"
" mov   lr, pc \n"
" ldmfd sp!, {r0-r2, pc}  @ restore the regs and jump to the syscall \n"
"back_to_caller: \n"
" stmfd sp!, {r0-r3} \n"
" mrs   r0, cpsr \n"
#ifdef STAGE1
" @ no recursion support required for stage 1\n"
" adr   r2, saved_spsr \n"
" ldr   r1, [r2], #4 \n"
#else
" adr   r2, saved_spsr2 \n"
" ldr   r1, [r2] \n"
" cmp   r1, #0            @ returning from level-1 recursion? \n"
" ldreq r1, [r2, #-8]!    @ no, use saved_spsr \n"
" mov   r3, #0 \n"
" str   r3, [r2], #4      @ update the recursion level, and point to saved_lr(2) \n"
#endif
" ldr   lr, [r2]          @ read from saved_lr(2) \n"
" and   r1, #0xFFFFFF3F   @ remove the mask \n"
" and   r0, #0xC0         @ keep the mask \n"
" orr   r1, r0            @ keep the new mask \n"
" msr   cpsr, r1          @ swi *must* restore cpsr. GCC may optimize with a cmp just after the swi for instance \n"
" ldmfd sp!, {r0-r3} \n"
" bx    lr                @ back to the caller \n"

#ifndef _NDLS_LIGHT // with extension/emu support
"is_ext_syscall: \n"
" ldr   r1, get_ext_table_reloc @ from here...\n"
" ldr   r2, get_ext_table_reloc+4 \n"
"get_ext_table: \n"
" add   r1, pc \n"
"get_table: \n"
" ldr   r2, [r1, r2]      @ ...to there: GOT-based access to sc_ext_table (defined in another .o). TODO: Could be optimized with http://gcc.gnu.org/bugzilla/show_bug.cgi?id=43129 once available? \n"
" ldr   r0, [r2, r0, lsl #2] @ syscall address \n"
" b jmp_to_syscall \n"

"is_emu_syscall: \n"
" ldr   r1, get_emu_table_reloc \n"
" ldr   r2, get_emu_table_reloc+4 \n"
"get_emu_table: \n"
" add   r1, pc \n"
" b get_table \n"
#endif

"sc_addrs_ptr: .global sc_addrs_ptr @ defined here because accessed with pc-relative instruction \n"
" .long 0 \n"
"@ if not null, in level-1 recursion \n"
"saved_spsr: .long 0 \n"
"saved_lr: .long 0 \n"
#ifndef STAGE1
"@ for 1-level recursion (syscall calling a syscall) \n"
"@ if not null, in level-1 recursion \n"
"saved_spsr2: .long 0 \n"
"saved_lr2: .long 0 \n"
#endif
#ifndef _NDLS_LIGHT
"get_ext_table_reloc: .long _GLOBAL_OFFSET_TABLE_-(get_ext_table+8) \n"
" .long sc_ext_table(GOT) \n"
"get_emu_table_reloc: .long _GLOBAL_OFFSET_TABLE_-(get_emu_table+8) \n"
" .long emu_sysc_table(GOT) \n"
#endif
);

