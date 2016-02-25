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

#include <libndls.h>
#include <os.h>
#include <syscall-list.h>

#include "lcd_compat.h"
#include "ndless.h"

/* Ndless extensions exposed as syscalls. See os.h for documentation. */

/* Values is an array of values for non-CAS 3.1, CAS 3.1, non-CAS CX 3.1, CAS CX 3.1, CM-C 3.1, CAS CM-C 3.1,
 * non-CAS 3.6, CAS 3.6, non-CAS CX 3.6, CAS CX 3.6,
   non-CAS 3.9.0, CAS 3.9.0, non-CAS CX 3.9.0, CAS CX 3.9.0,
   non-CAS 3.9.1, CAS 3.9.1, non-CAS CX 3.9.1, CAS CX 3.9.1,
   non-CAS CX 4.0.0, CAS CX 4.0.0,
   non-CAS CX 4.0.3 and CAS CX 4.0.3,
   non-CAS CX 4.2.0 and CAS CX 4.2.0 */
int sc_nl_osvalue(const int *values, unsigned size) {
	unsigned index = ut_os_version_index;
	if (index >= size)
		return 0;
	return values[index];
}

/* The lightweight relocation support unfortunately cannot handle 
 * initializers with relocation (for example arrays of function pointers).
 * data.rel and data.rel.ro sections are created, but may contain both
 * non-relocable and relocable data, for which we have no clue.
 * This function allows to relocate an array of pointers.
 * This function is useless if the PRG binary format is not used. */
void sc_ext_relocdatab(unsigned *dataptr, unsigned size, void *base) {
	unsigned i;
	if (ld_bin_format != LD_PRG_BIN) return;
	for (i = size; i > 0; i--) {
		*dataptr++ += (unsigned)base;
	}
}

unsigned sc_nl_hwtype(void) {
	switch(ut_os_version_index)
	{
	case 0:
	case 1:
	case 6:
	case 7:
	case 10:
	case 11:
	case 14:
	case 15:
		return 0;
	default:
		return 1;
	}
}

// same as ut_os_version_index
unsigned sc_nl_osid(void) {
	return ut_os_version_index;
}

unsigned sc_nl_hwsubtype(void) {
	unsigned asic_user_flags_model = (*(volatile unsigned*)0x900A002C & 0x7C000000) >> 26;
	return (/* CM */ asic_user_flags_model == 2 || /* CM CAS */ asic_user_flags_model == 3); // 1 if CM
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

typedef void (*lcd_blit_func)(void *buffer);

static void lcd_blit_simple(void *buffer)
{
    memcpy(SCREEN_BASE_ADDRESS, buffer, 320 * 240 * sizeof(uint16_t));
}

static void lcd_blit_320x240_240x320(void *buffer)
{
    uint16_t *out = SCREEN_BASE_ADDRESS, *in = buffer;
    for (int col = 0; col < 240; ++col)
    {
            uint16_t *outcol = out + col;
            for(int row = 0; row < 320; ++row, outcol += 240)
                    *outcol = *in++;
    }
}

static void lcd_blit_240x320_320x240(void *buffer)
{
    uint16_t *out = SCREEN_BASE_ADDRESS, *in = buffer;
    for (int col = 0; col < 320; ++col)
    {
            uint16_t *outcol = out + col;
            for(int row = 0; row < 240; ++row, outcol += 320)
                    *outcol = *in++;
    }
}

lcd_blit_func sc_nl_lcd_blit(scr_type_t buffer_type)
{
       if (buffer_type == SCR_320x240_565)
       {
            if(!is_hww)
                return lcd_blit_simple;
            else
                return lcd_blit_320x240_240x320;
       }
       else if(buffer_type == SCR_240x320_565)
       {
            if(is_hww)
                return lcd_blit_simple;
            else
                return lcd_blit_240x320_320x240;
       }
       else
           return 0;
}

unsigned const sc_syscall_num = __SYSCALLS_LAST;

bool sc_nl_hassyscall(unsigned syscall_id) {
	return syscall_id <= sc_syscall_num && sc_addrs_ptr[syscall_id];
}

/* Extension syscalls table */
/* Caution, these ones cannot call themselves other syscalls, because of the non-reentrant swi handler */
unsigned sc_ext_table[] = {
	(unsigned)sc_nl_osvalue, (unsigned)sc_ext_relocdatab, (unsigned)sc_nl_hwtype, (unsigned)sc_nl_isstartup,
	(unsigned)luaext_getstate, (unsigned)ld_set_resident, (unsigned)sc_nl_ndless_rev, (unsigned)sc_nl_no_scr_redraw,
	(unsigned)ins_loaded_by_3rd_party_loader, (unsigned)sc_nl_hwsubtype, (unsigned)sc_nl_exec, (unsigned)sc_nl_osid,
	(unsigned)sc_nl_hassyscall, (unsigned)sc_nl_lcd_blit,
};
