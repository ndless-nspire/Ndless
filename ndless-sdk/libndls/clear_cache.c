/****************************************************************************
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
 * Portions created by the Initial Developer are Copyright (C) 2010
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s): 
 ****************************************************************************/

#include <os.h>

/* As a non-inline function to be called from Thumb state */
void clear_cache(void) {
	unsigned dummy;
	__asm volatile(
		" .arm \n"
		"0: mrc p15, 0, r15, c7, c10, 3 @ test and clean DCache \n"
		" bne 0b \n"
		" mov %0, #0 \n"
		" mcr p15, 0, %0, c7, c7, 0 @ invalidate ICache and DCache \n"
	: "=r" (dummy));
}
