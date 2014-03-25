/****************************************************************************
 * Common functions
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

#include "ndless.h"

#ifndef STAGE1
struct next_descriptor ut_next_descriptor = {
	.next_version = 0x00010000,
	.ext_name = "NDLS",
	.ext_version = 0x00010007 // will be incremented only if new functionnalities exposed to third-party tools
};
#endif

unsigned ut_os_version_index;

// OS-specific
extern unsigned syscalls_ncas_3_6_0[];
extern unsigned syscalls_light_ncas_3_6_0[];
extern unsigned syscalls_cas_3_6_0[];
extern unsigned syscalls_light_cas_3_6_0[];
extern unsigned syscalls_ncascx_3_6_0[];
extern unsigned syscalls_light_ncascx_3_6_0[];
extern unsigned syscalls_cascx_3_6_0[];
extern unsigned syscalls_light_cascx_3_6_0[];
extern unsigned syscalls_cmc_3_6_0[];
extern unsigned syscalls_light_cmc_3_6_0[];
extern unsigned syscalls_cascmc_3_6_0[];
extern unsigned syscalls_light_cascmc_3_6_0[];

/* Writes to ut_os_version_index a zero-based index identifying the OS version and HW model.
 * Also sets up the syscalls table.
 * Should be called only once.
 * May be used for OS-specific arrays of constants (marked with "// OS-specific"). */
void ut_read_os_version_index(void) {
	switch (*(unsigned*)(OS_BASE_ADDRESS + 0x20)) {
		// OS-specific
		case 0x10375BB0:  // 3.6.0 non-CAS
			ut_os_version_index = 0;
#ifdef _NDLS_LIGHT
			sc_addrs_ptr = syscalls_light_ncas_3_6_0;
#else
			sc_addrs_ptr = syscalls_ncas_3_6_0;
#endif
			break;
		case 0x103765F0:  // 3.6.0 CAS
			ut_os_version_index = 1;
#ifdef _NDLS_LIGHT
			sc_addrs_ptr = syscalls_light_cas_3_6_0;
#else
			sc_addrs_ptr = syscalls_cas_3_6_0;
#endif
			break;
		case 0x10375620:  // 3.6.0 non-CAS CX
			ut_os_version_index = 2;
#ifdef _NDLS_LIGHT
			sc_addrs_ptr = syscalls_light_ncascx_3_6_0;
#else
			sc_addrs_ptr = syscalls_ncascx_3_6_0;
#endif
			break;
		case 0x10376090:  // 3.6.0 CAS CX
			ut_os_version_index = 3;
#ifdef _NDLS_LIGHT
			sc_addrs_ptr = syscalls_light_cascx_3_6_0;
#else
			sc_addrs_ptr = syscalls_cascx_3_6_0;
#endif
			break;
		default:
			ut_panic("v?");
	}
}
void __attribute__ ((noreturn)) ut_calc_reboot(void) {
	*(unsigned*)0x900A0008 = 2; //CPU reset
	__builtin_unreachable();
}

void __attribute__ ((noreturn)) ut_panic(const char *msg) {
	puts(msg);
	ut_calc_reboot();
}

#if 0
/* draw a dotted line. Line 0 is at the bottom of the screen (to avoid overwriting the installer) */
void ut_debug_trace(unsigned line) {
	volatile unsigned *ptr = (unsigned*)((char*)SCREEN_BASE_ADDRESS + (SCREEN_WIDTH/2) * (SCREEN_HEIGHT - 1 - line));
	unsigned i;
	for (i = 0; i < (SCREEN_WIDTH/2) / 4; i++)
		*ptr++ = line & 1 ? 0xFFFF0000 : 0x0000FFFF;
}
#endif

void ut_disable_watchdog(void) {
	// Disable the watchdog on CX that may trigger a reset
	*(volatile unsigned*)0x90060C00 = 0x1ACCE551; // enable write access to all other watchdog registers
	*(volatile unsigned*)0x90060008 = 0; // disable reset, counter and interrupt
	*(volatile unsigned*)0x90060C00 = 0; // disable write access to all other watchdog registers
}
