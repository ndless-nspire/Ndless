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
 * Contributor(s): 
 ****************************************************************************/

#include <os.h>

unsigned msleep(unsigned millisec) {
	if (is_classic) {
		volatile unsigned *timer = (unsigned*)0x900D0000;
		volatile unsigned *control = (unsigned*)0x900D0008;
		volatile unsigned *divider = (unsigned*)0x900D0004;
		unsigned orig_divider = *divider;
		unsigned orig_control = *control;
		*control = 0; // One Shot (for the *timer > 0 test)
		*divider = 31;
		*timer = millisec;
		while (*timer > 0)
			idle();
		*control = orig_control;
		*divider = orig_divider;
		*timer = 32;
	} else {
		// see http://infocenter.arm.com/help/index.jsp?topic=/com.arm.doc.ddi0271d/CHDFDDCF.html
		volatile unsigned *load = (unsigned*)0x900D0000;
		volatile unsigned *control = (unsigned*)0x900D0008;
		volatile unsigned *int_clear = (unsigned*)0x900D000C;
		volatile unsigned *int_status = (unsigned*)0x900D0010;
		unsigned orig_control = *control;
		unsigned orig_load = *load;
		*control = 0; // disable timer
		*int_clear = 1; // clear interrupt status
		*load = 32 * millisec;
		*control = 0b01100011; // disabled, TimerMode N/A, int, no prescale, 32-bit, One Shot -> 32khz
		*control = 0b11100011; // enable timer

		// Can't use idle() here as it acks the timer interrupt
		volatile unsigned *intmask = IO(0xDC000008, 0xDC000010);
		unsigned orig_mask = intmask[0];
		intmask[1] = ~(1 << 19); // Disable all IRQs except timer

		while ((*int_status & 1) == 0)
			__asm volatile("mcr p15, 0, %0, c7, c0, 4" : : "r"(0) ); // Wait for an interrupt to occur

		intmask[1] = 0xFFFFFFFF; // Disable all IRQs
		intmask[0] = orig_mask; // renable IRQs

		*control = 0; // disable timer
		*int_clear = 1; // clear interrupt status
		*control = orig_control & 0b01111111; // timer still disabled
		*load = orig_load;
		*control = orig_control; // enable timer
	}
	
	return 0;
}

