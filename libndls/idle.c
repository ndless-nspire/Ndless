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
 * Portions created by the Initial Developer are Copyright (C) 2010-2011
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s): Goplat
 ****************************************************************************/

#include <os.h>

void idle(void) {
	volatile unsigned *intmask = IO(0xDC000008, 0xDC000010);
	unsigned orig_mask = intmask[0];
	intmask[1] = ~(1 << 19); // Disable all IRQs except timer
	__asm volatile("mcr p15, 0, %0, c7, c0, 4" : : "r"(0) ); // Wait for an interrupt to occur
	*IO(0x900A0020, 0x900D000C) = 1; // Acknowledge timer interrupt at source
	if (is_classic) *(volatile unsigned*)0xDC000028; // Make interrupt controller stop asserting nIRQ if there aren't any active IRQs left
	intmask[1] = 0xFFFFFFFF; // Disable all IRQs
	intmask[0] = orig_mask; // renable IRQs
}
