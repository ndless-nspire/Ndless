/****************************************************************************
 * Stage 0 of the installation: entry point
 * Unescapes and loads stage1.
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
 * 
 * Portions created by the Initial Developer are Copyright (C) 2013-2014
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s): Excale
 ****************************************************************************/

#include <os.h>

#define FILLER_SIZE_1 0xA800
#define FILLER_SIZE_2 0x80

@ Unescapes forbidden half-words (see tools/MakeEscapeTable) and loads stage1.
@ Will also unescape crt0.
@ Must *not* contain 0000 and 0009.

	@ we are in abt mode, switch to the standard svc mode
	mrs   r1, cpsr
	eor   r1, #0b100 @ svc mode
	msr   cpsr, r1
	
	mov lr, #0x11800000 @ unescaped installer dest
	sub lr, #0x00100000 @ can't be 0x11800000 which is wiped out on OS boot up on classic TI-Nspire
	add lr, #0x00040000 @ somewhere not overwritten on OS boot up, especially on classic non-CAS. Found with a pre/post boot dump diff.
	
	adr r0, padding @ we can t use adr with escaped_start
	add r0, #FILLER_SIZE_1
	add r0, #FILLER_SIZE_2
	ldrh r3, [r0], #2 @ installer size
	ldrh r4, [r0], #2 @ number of entries in offset table
	
	add r5, r0, r4, lsl #1 @ installer entry point
	mov r6, lr @ dest
copy_installer_loop:
	ldr r7, [r5], #4
	str r7, [r6], #4
	subs r3, #4 @ code assumes r3==0 after the loop
	bne copy_installer_loop

	mov r8, #9
unescape_loop:
	ldrh r2, [r0], #2 @ entry in offset table
	add r2, lr @ offset + base
	ldrh r9, [r2]
			   @ use tst and not cmp to avoid the code to contain 0x0000
	tst r9, #0b10000 @ 0xFFFF is 0x0000 escaped -> bit 0=1. 0xEEEE is 0x0009 -> bit 0=0. 
	strneh r3, [r2]
	streqh r8, [r2]
	subs r4, #1 @ number of entries--
	bne unescape_loop
	
	@ inlined clear_cache, because branching to libndls function generates a 0000
clear_cache_loop:
	mrc p15, 0, r15, c7, c10, 3 @ test and clean DCache
	bne clear_cache_loop
	mcr p15, 0, r3, c7, c7, 0 @ invalidate ICache and DCache

	mov pc, lr

padding:
	.fill FILLER_SIZE_1, 		      1, 0x01	    	@ some OS global vars are written to by the OS during the overflow. Don't put installer code there.
	.fill FILLER_SIZE_2/4,        4, 0x11800004	@ same. 0x11800004 is a valid address to avoid abt in the interrupt handler.
escaped_start:
	@ concatenated here by the Makefile. Contains the escape table, then the installer.
	