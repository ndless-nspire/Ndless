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
#include <syscall-list.h>
#include "ndless.h"

extern void *ints_next_descriptor_ptr; // but static
extern void ints_swi_handler(void);

void ints_setup_handlers(void) {
	void **adr_ptr = (void**)INTS_INIT_HANDLER_ADDR;
	// The address is used by nspire_emu for OS version detection and must be restored to the OS value
	*adr_ptr = *(void**)(OS_BASE_ADDRESS + INTS_INIT_HANDLER_ADDR);
	*(adr_ptr + 2) = &ints_swi_handler;
	// also change the SWI handler in the OS code, required by the N-ext convention
	*(void**)(OS_BASE_ADDRESS + INTS_SWI_HANDLER_ADDR) = &ints_swi_handler;
 	ints_next_descriptor_ptr = &ut_next_descriptor;
}

asm(
" .arm \n"
" @ N-ext convention: a signature and a pointer to the descriptor, before the SWI handler address in the OS copy of the vectors \n"
" .long " STRINGIFY(NEXT_SIGNATURE) "\n"
"ints_next_descriptor_ptr: .long 0 \n"
"ints_swi_handler: .global ints_swi_handler  @ caution: 1) only supports calls from the svc mode (i.e. the mode used by the OS) 2) destroys the caller's mode lr \n"
" stmfd	sp!, {r0-r2, r3}  @ r3 is dummy and will be overwritten with the syscall address. Caution, update the offset below if reg list changed. \n"
" mrs	r0, spsr \n"
" tst	r0, #0b100000     @ caller in thumb state? \n"
" addne	lr, lr, #1        @ so that the final 'bx lr' of the syscall switches back to thumb state \n"
" bicne	r0, #0b100000     @ clear the caller's thumb bit. The syscall is run in 32-bit state \n"
" adr	r1, saved_spsr \n"
" ldr	r2, [r1] \n"
" cmp	r2, #0 \n"
" addne	r1, #8          @ use vars for level-1 recursion \n"
" str	r0, [r1], #4 \n"
" str	lr, [r1]          @ save to saved_lr \n"
" msr	spsr, r0 \n"
" subs  pc, pc, #4        @  move spsr to cpsr (restore the ints mask) \n"
"@ extract the syscall number from the comment field of the swi instruction \n"
" tst	lr, #1            @ was the caller in thumb state? \n"
" ldreq	r0, [lr, #-4]     @ ARM state \n"
" biceq	r0, r0, #0xFF000000 \n"
" ldrneh r0, [lr, #-3]    @ thumb state (-2-1, because of the previous +1) \n"
" bicne	r0, r0, #0xFF00 \n"
" mov	r1, r0            @ syscall number \n"
" and	r1, #0xE00000   @ keep the 3-bit flag \n"
" bic	r0, #0xE00000   @ clear the flag \n"
" cmp	r1, #" STRINGIFY(__SYSCALLS_ISEXT) "\n"
" ldreq	r2, =sc_ext_table \n"
" beq	have_address \n"
" cmp	r1, #" STRINGIFY(__SYSCALLS_ISEMU) "\n"
" ldreq	r2, =emu_sysc_table \n"
" ldrne	r2, sc_addrs_ptr  @ OS syscalls table \n"
"have_address: \n"
" ldr	r0, [r2, r0, lsl #2] @ syscall address \n"
" cmp	r1, #" STRINGIFY(__SYSCALLS_ISVAR) "\n"
" bne	jmp_to_syscall \n"
" str	r0, [sp] \n"
" adr	r0, back_to_caller \n"

"jmp_to_syscall: \n"
" str	r0, [sp, #12] \n" // Overwrite the dummy register previously saved
" mov	lr, pc \n"
" ldmfd	sp!, {r0-r2, pc} \n" // Restore the regs and jump to the syscall

"back_to_caller: \n"
" stmfd	sp!, {r0-r3} \n"
" mrs	r0, cpsr \n"
" adr	r2, saved_spsr2 \n"
" ldr	r1, [r2] \n"
" cmp	r1, #0 \n" // Returning from level-1 recursion?
" ldreq	r1, [r2, #-8]! \n" // No, use saved_spsr
" mov	r3, #0 \n"
" str	r3, [r2], #4 \n" // Update the recursion level, and point to saved_lr(2)
" ldr	lr, [r2] \n" // Read from saved_lr(2)
" and	r1, #0xFFFFFF3F \n" // Remove the mask
" and	r0, #0xC0 \n" // Keep the mask
" orr	r1, r0 \n" // Keep the new mask
" msr	cpsr, r1 \n" // swi *must* restore cpsr. GCC may optimize with a cmp just after the swi for instance
" ldmfd	sp!, {r0-r3} \n"
" bx	lr \n" // Back to the caller

"ext_syscall: \n"
" ldr	r1, =sc_ext_table \n" // Puts sc_ext_table into the literal pool and generates a relocation (ABS32)
" ldr	r0, [r1, r0, lsl #2] \n"
" b	jmp_to_syscall \n"

"emu_syscall: \n"
" ldr	r1, =emu_sysc_table \n"
" ldr	r0, [r1, r0, lsl #2]\n"
" b	jmp_to_syscall \n"

"sc_addrs_ptr: .global sc_addrs_ptr \n" // Defined here to access it relative to pc
" .long 0 \n"
"saved_spsr: .long 0 \n"
"saved_lr: .long 0 \n" // For 1-level recursion (syscall calling a syscall) if not null, in level-1 recursion \n"
"saved_spsr2: .long 0 \n"
"saved_lr2: .long 0 \n"
);

