/****************************************************************************
 * Ndless syscalls setup and handlers
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
 * Portions created by the Initial Developer are Copyright (C) 2010-2014
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s): 
 ****************************************************************************/

#include <os.h>
#include <syscall-list.h>
#include "ndless.h"

/* Ndless extensions exposed as syscalls. See os.h for documentation. */

/* Values is an array of values for non-CAS 3.1, CAS 3.1, non-CAS CX 3.1, CAS CX 3.1, CM-C 3.1, CAS CM-C 3.1,
 * non-CAS 3.6, CAS 3.6, non-CAS CX 3.6, CAS CX 3.6 */
int sc_nl_osvalue(const int *values, unsigned size) {
	unsigned index = ut_os_version_index + 6; // the first values are for backward compatibility with Ndless 3.1s
	if (index >= size)
		return 0;
	return values[index];
}

/* The lightweight relocation support unfortunately cannot handle 
 * initializers with relocation (for example arrays of function pointers).
 * data.rel and data.rel.ro sections are created, but may contain both
 * non-relocable and relocable data, for which we have no clue.
 * This function allows to relocate an array of pointers.
 * This function is useless when the bFLT binary format is used. */
void sc_ext_relocdatab(unsigned *dataptr, unsigned size, void *base) {
	unsigned i;
	if (ld_bin_format == LD_BFLT_BIN) return;
	for (i = size; i > 0; i--) {
		*dataptr++ += (unsigned)base;
	}
}

unsigned sc_nl_hwtype(void) {
	return ut_os_version_index >= 2; // 1 if CX
}

// same as ut_os_version_index
unsigned sc_nl_osid(void) {
	return ut_os_version_index;
}

unsigned sc_nl_hwsubtype(void) {
	unsigned asic_user_flags_model = (*(volatile unsigned*)0x900A002C & 0x7C000000) >> 26;
	return  (/* CM */ asic_user_flags_model == 2 || /* CM CAS */ asic_user_flags_model == 3) ? 1 : 0; // 1 if CM
}

BOOL sc_nl_isstartup(void) {
	return plh_isstartup;
}

unsigned sc_nl_ndless_rev(void) {
	return NDLESS_REVISION;
}

void sc_nl_no_scr_redraw(void) {
	plh_noscrredraw = TRUE;
}

int sc_nl_exec(const char *prgm_path, int argsn, char *args[]) {
	return ld_exec_with_args(prgm_path, argsn, args, NULL);
}

unsigned const sc_syscall_num = __SYSCALLS_LAST;

BOOL sc_nl_hassyscall(unsigned syscall_id) {
	return syscall_id <= sc_syscall_num && sc_addrs_ptr[syscall_id];
}

/* Extension syscalls table */
/* Caution, these ones cannot call themselves other syscalls, because of the non-reentrant swi handler */
unsigned sc_ext_table[] = {
	(unsigned)sc_nl_osvalue, (unsigned)sc_ext_relocdatab, (unsigned)sc_nl_hwtype, (unsigned)sc_nl_isstartup,
	(unsigned)luaext_getstate, (unsigned)ld_set_resident, (unsigned)sc_nl_ndless_rev, (unsigned)sc_nl_no_scr_redraw,
	(unsigned)ins_loaded_by_3rd_party_loader, (unsigned)sc_nl_hwsubtype, (unsigned)sc_nl_exec, (unsigned)sc_nl_osid,
	(unsigned)sc_nl_hassyscall,
};
