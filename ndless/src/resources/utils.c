/****************************************************************************
 * Common functions (both used by resources and installer: symlinked)
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

#ifndef STAGE1
#include "ndless.h"
#include <syscall-addrs.h>

struct next_descriptor ut_next_descriptor = {
	.next_version = 0x00010000,
	.ext_name = "NDLS",
	.ext_version = 0x00010007 // will be incremented only if new functionalities exposed to third-party tools
};
#endif

unsigned int ut_os_version_index;

void __attribute__ ((noreturn)) ut_calc_reboot(void) {
	*(volatile unsigned*)0x900A0008 = 2; //CPU reset
	__builtin_unreachable();
}

/* Writes to ut_os_version_index a zero-based index identifying the OS version and HW model.
 * Also sets up the syscalls table.
 * Should be called only once.
 * May be used for OS-specific arrays of constants (marked with "// OS-specific"). */
void ut_read_os_version_index(void) {
	switch (*(unsigned*)(0x10000020)) {
		// OS-specific
#ifndef STAGE1
		case 0x102F0FA0: // 3.1.0 non-CAS
			ut_os_version_index = 0;
			break;
		case 0x102F16D0: // 3.1.0 CAS
			ut_os_version_index = 1;
			break;
		case 0x102F0A10: // 3.1.0 non-CAS CX
			ut_os_version_index = 2;
			break;
		case 0x102F11A0: // 3.1.0 CAS CX
			ut_os_version_index = 3;
			break;
		case 0x102DBF20: // 3.1.0 CM-C
			ut_os_version_index = 4;
			break;
		case 0x102DC6B0: // 3.1.0 CAS CM-C
			ut_os_version_index = 5;
			break;
#endif
#if !defined(STAGE1) || defined(NDLESS_36)
		case 0x10375BB0: // 3.6.0 non-CAS
			ut_os_version_index = 6;
			break;
		case 0x103765F0: // 3.6.0 CAS
			ut_os_version_index = 7;
			break;
		case 0x10375620: // 3.6.0 non-CAS CX
			ut_os_version_index = 8;
			break;
		case 0x10376090: // 3.6.0 CAS CX
			ut_os_version_index = 9;
			break;
#endif
#if !defined(STAGE1) || NDLESS_39 == 39
		case 0x1037CDE0: // 3.9.0 non-CAS
			ut_os_version_index = 10;
			break;
		case 0x1037D320: // 3.9.0 CAS
			ut_os_version_index = 11;
			break;
		case 0x1037C760: // 3.9.0 non-CAS CX
			ut_os_version_index = 12;
			break;
		case 0x1037CCC0: // 3.9.0 CAS CX
			ut_os_version_index = 13;
			break;
#endif
#if !defined(STAGE1) || NDLESS_39 == 391
		case 0x1037D160: // 3.9.1 non-CAS CX
			ut_os_version_index = 16;
			break;
		case 0x1037D6C0: // 3.9.1 CAS CX
			ut_os_version_index = 17;
			break;
#endif
#ifndef STAGE1
		case 0x10386E70: // 4.0.0.235 non-CAS CX
			ut_os_version_index = 18;
			break;
		case 0x103873B0: // 4.0.0.235 CAS CX
			ut_os_version_index = 19;
			break;
#endif
#if !defined(STAGE1) || NDLESS_403
		case 0x1038C290: // 4.0.3.93 non-CAS CX
			ut_os_version_index = 20;
			break;
		case 0x1038C7D0: // 4.0.3.93 CAS CX
			ut_os_version_index = 21;
			break;
#endif
#if !defined(STAGE1) || NDLESS_420
		case 0x1039C7A0: // 4.2.0.532 non-CAS CX
			ut_os_version_index = 22;
			break;
		case 0x1039CD20: // 4.2.0.532 CAS CX
			ut_os_version_index = 23;
			break;
#endif
#if !defined(STAGE1) // No installer for this yet :-/
		case 0x103A3100: // 4.3.0.702 non-CAS CX
			ut_os_version_index = 24;
			break;
		case 0x103A3690: // 4.3.0.702 CAS CX
			ut_os_version_index = 25;
			break;
#endif
#if !defined(STAGE1) || NDLESS_440
		case 0x103A9F50: // 4.4.0.532 non-CAS CX
			ut_os_version_index = 26;
			break;
		case 0x103AA4E0: // 4.4.0.532 CAS CX
			ut_os_version_index = 27;
			break;
#endif
#if !defined(STAGE1) || NDLESS_450
		case 0x103B1860: // 4.5.0.1180 non-CAS CX
			ut_os_version_index = 28;
			break;
		case 0x103B1E60: // 4.5.0.1180 CAS CX
			ut_os_version_index = 29;
			break;
#endif
#if !defined(STAGE1)
		case 0x103B27D0: // 4.5.1.12 non-CAS CX
			ut_os_version_index = 30;
			break;
		case 0x103B2EF0: // 4.5.1.12 CAS CX
			ut_os_version_index = 31;
			break;
#endif
#if !defined(STAGE1)
		case 0x103B3020: // 4.5.3.14 non-CAS CX
			ut_os_version_index = 32;
			break;
		case 0x103B3740: // 4.5.3.14 CAS CX
			ut_os_version_index = 33;
			break;
#endif
#if !defined(STAGE1)
		case 0x1040E4D0: // 5.2.0.771 non-CAS CX II
			ut_os_version_index = 34;
			break;
		case 0x1040EAE0: // 5.2.0.771 non-CAS CX II-T
			ut_os_version_index = 35;
			break;
		case 0x1040F3B0: // 5.2.0.771 CAS CX II
			ut_os_version_index = 36;
			break;
#endif
#if !defined(STAGE1)
		case 0x103B3A10: // 4.5.4.48 non-CAS CX
			ut_os_version_index = 37;
			break;
		case 0x103B4130: // 4.5.4.48 CAS CX
			ut_os_version_index = 38;
			break;
#endif
#if !defined(STAGE1)
		case 0x10416CC0: // 5.3.0.564 non-CAS CX II
			ut_os_version_index = 39;
			break;
		case 0x10417460: // 5.3.0.564 non-CAS CX II-T
			ut_os_version_index = 40;
			break;
		case 0x10417DA0: // 5.3.0.564 CAS CX II
			ut_os_version_index = 41;
			break;
#endif
		default:
			ut_calc_reboot();
	}

#ifndef STAGE1
	sc_addrs_ptr = syscall_addrs[ut_os_version_index];
#endif
}

void ut_disable_watchdog(void) {
	// Disable the watchdog on CX that may trigger a reset
	*(volatile unsigned*)0x90060C00 = 0x1ACCE551; // enable write access to all other watchdog registers
	*(volatile unsigned*)0x90060008 = 0; // disable reset, counter and interrupt
	*(volatile unsigned*)0x90060C00 = 0; // disable write access to all other watchdog registers
}
