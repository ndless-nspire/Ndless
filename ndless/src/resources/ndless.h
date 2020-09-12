/****************************************************************************
 * Definitions
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
 *                 Geoffrey ANNEHEIM <geoffrey.anneheim@gmail.com>
 ****************************************************************************/

#ifndef _NDLESS_H_
#define _NDLESS_H_

#include "ndless_version.h"

// Marker at the beginning of a plain-old Ndless program. Deprecated, only used for Ndless itself, Zehn is now used for programs.
#define PRGMSIG "PRG"

/* Debug levels for ut_debug_trace() for installation failure diagnostic. Keep in execution order. */
#define INSTTR_S1_ENTER 0
#define INSTTR_S1_LOADINST 1
#define INSTTR_INS_ENTER 2
#define INSTTR_INS_END 3

// Delay for the exception handlers as a number of loops
#define INTS_EXCEPTION_SLEEP_CNT 0xB30000

#ifndef GNU_AS

#include <os.h>

#ifdef __cplusplus
extern "C" {
#endif

/* emu.c */
extern void *emu_debug_alloc_ptr;
extern size_t emu_debug_alloc_size();
extern unsigned emu_sysc_table[];

/* install.c */
BOOL ins_loaded_by_3rd_party_loader(void);
void ins_uninstall(void);
void ins_install_successmsg_hook(void);

/* ints.c */
extern unsigned ints_scextnum;
extern unsigned *sc_addrs_ptr;
void ints_setup_handlers(void);
#define INTS_INIT_HANDLER_ADDR 0x20
#define INTS_UNDEF_INSTR_HANDLER_ADDR 0x24
#define INTS_SWI_HANDLER_ADDR 0x28
#define INTS_PREFETCH_ABORT_HANDLER_ADDR 0x2C
#define INTS_DATA_ABORT_HANDLER_ADDR 0x30

/* ploaderhook.c */
extern BOOL plh_isstartup;
extern BOOL plh_noscrredraw;
enum e_ld_bin_format {
	LD_ERROR_BIN,
	LD_PRG_BIN,
	LD_BFLT_BIN,
	LD_ZEHN_BIN
};
extern enum e_ld_bin_format ld_bin_format;
void ld_set_resident(void);
int ld_exec(const char *path, void **resident_ptr);
int ld_exec_with_args(const char *path, int argc, char *argv[], void **resident_ptr);
void ld_free(void *resident_ptr);
void plh_startup();

/* stage1 */
void stage1(void);

/* utils.c */
// 'NEXT'
#define NEXT_SIGNATURE 0x4E455854
/* N-ext is a convention for TI-Nspire extensions such as Ndless.
 * Only one N-ext-based extension can be installed at a time.
 * The N-ext descriptor is referenced before the SWI handler.
 * It defines the currently installed extension to programs, emulators, ...
 * and ourself for uninstallation. */
struct next_descriptor {
	unsigned next_version;
	char ext_name[4];
	unsigned ext_version;
};
extern struct next_descriptor ut_next_descriptor;
extern unsigned ut_os_version_index;
void ut_read_os_version_index(void);
void __attribute__ ((noreturn)) ut_calc_reboot(void);
void __attribute__ ((noreturn)) ut_panic(const char * msg);
//void ut_debug_trace(unsigned line);
#define ut_debug_trace(line)
void ut_disable_watchdog(void);
static inline struct next_descriptor *ut_get_next_descriptor(void) {
	if (*(*(unsigned**)(OS_BASE_ADDRESS + INTS_SWI_HANDLER_ADDR) - 2) != NEXT_SIGNATURE)
		return NULL;
	return (struct next_descriptor*)*(*(unsigned**)(OS_BASE_ADDRESS + INTS_SWI_HANDLER_ADDR) - 1);
}
extern unsigned int syscall_addrs[NDLESS_MAX_OSID+1][__SYSCALLS_LAST+1];

/* syscalls.c */
void sc_ext_relocdatab(unsigned *dataptr, unsigned size, void *base);
void sc_install_compat(void);
BOOL nl_is_cx2(void);

/* luaext.c */
void lua_install_hooks(void);
lua_State *luaext_getstate(void);

#ifdef __cplusplus
}
#endif

#endif /* GNU_AS */

#endif /* _NDLESS_H_ */
