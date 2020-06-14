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
 * The Initial Developer of the Original Code is Goplat.
 * Portions created by the Initial Developer are Copyright (C) 2011
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s): Olivier ARMAND <olivier.calc@gmail.com>
 ****************************************************************************/

#include <os.h>
#include <libndls.h>

// See the Touchpad I²C protocol on Hackspire

/* cached */
BOOL touchpad_info_cached = FALSE;
touchpad_info_t touchpad_info;

inline int bswap16(short s)
{
	return ((s & 0xFF) << 8) | ((s & 0xFF00) >> 8);
}

/* Returns NULL if error */
touchpad_info_t *touchpad_getinfo(void) {
	if (touchpad_info_cached) return &touchpad_info;
	if (!is_touchpad)
		return NULL;
 	int cpsr;
	// Be sure to turn interrupts off when accessing a different touchpad page
	// TI's interrupt handler expects it to be set to page 4
	asm ("mrs %0, cpsr" : "=r" (cpsr));
	asm ("msr cpsr_c, %0" : : "r" (cpsr | 0xC0));
	BOOL err = !touchpad_write(0xFF, 0xFF, "\x10") || !touchpad_read(0x04, 0x07, &touchpad_info)
		|| !touchpad_write(0xFF, 0xFF, "\x04");
	asm ("msr cpsr_c, %0" : : "r" (cpsr));
	if (err)
		return NULL;
	touchpad_info.width = bswap16(touchpad_info.width);
	touchpad_info.height = bswap16(touchpad_info.height);
	touchpad_info_cached = TRUE;
	return &touchpad_info;
}

static tpad_arrow_t touchpad_getarrow(touchpad_report_t *report) {
	touchpad_getinfo();
	if (!report->pressed) return TPAD_ARROW_NONE;
	if (report->y >= (touchpad_info.height * 2)/3) {
		if (report->x >= (touchpad_info.width * 2)/3) return TPAD_ARROW_UPRIGHT;
		if (report->x <= (touchpad_info.width * 1)/3) return TPAD_ARROW_LEFTUP;
		return TPAD_ARROW_UP;
	}
	if (report->y <= (touchpad_info.height * 1)/3) {
		if (report->x >= (touchpad_info.width * 2)/3) return TPAD_ARROW_RIGHTDOWN;
		if (report->x <= (touchpad_info.width * 1)/3) return TPAD_ARROW_DOWNLEFT;
		return TPAD_ARROW_DOWN;
	}
	if (report->x >= (touchpad_info.width * 2)/3) return TPAD_ARROW_RIGHT;
	if (report->x <= (touchpad_info.width * 1)/3) return TPAD_ARROW_LEFT;
	return TPAD_ARROW_CLICK;
}

/* Returns non-zero on error. report->contact and report->pressed are always FALSE on Clickpad. */
int touchpad_scan(touchpad_report_t *report) {
	report->contact = report->pressed = 0;
	report->arrow = TPAD_ARROW_NONE;
	if (!is_touchpad)
		return 0;
	if (!touchpad_read(0x00, 0x0A, report))
		return 1;
	report->x = bswap16(report->x);
	report->y = bswap16(report->y);
	report->arrow = touchpad_getarrow(report);
	return 0;
}

BOOL touchpad_arrow_pressed(tpad_arrow_t arrow) {
	touchpad_report_t report;
	touchpad_scan(&report);
	if (!report.pressed) return false;
	return report.arrow == arrow;
}
