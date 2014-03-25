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
#include <libndls.h>

BOOL any_key_pressed(void) {
	volatile int *addr;
	touchpad_report_t report;
	touchpad_scan(&report);
	if (report.pressed) return TRUE;
	for (addr = KEY_MAP + 0x10; addr < (volatile int *)(KEY_MAP + 0x20); addr += 1) {
		if (is_classic ? *addr != -1  : *addr )
			return TRUE;
	}
	return FALSE;
}
