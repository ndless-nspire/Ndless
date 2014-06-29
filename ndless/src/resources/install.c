/****************************************************************************
 * Final steps of the installation.
 * Installs the hooks at their target addresses.
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
 *                 Geoffrey ANNEHEIM <geoffrey.anneheim@gmail.com>, Excale
 ****************************************************************************/

#include <os.h>
#include <ngc.h>
#include "ndless.h"

// OS-specific
// Call to the dialog box display telling that the format isn't recognized.
static unsigned const ploader_hook_addrs[] = {0x1000A988, 0x1000A95C, 0x1000A920, 0x1000A924};

// initialized at load time. Kept in resident program memory, use nl_is_3rd_party_loader to read it.
static BOOL loaded_by_3rd_party_loader = FALSE;

BOOL ins_loaded_by_3rd_party_loader(void) {
	return loaded_by_3rd_party_loader;
}

static unsigned const end_of_init_addrs[] = {0x1001264C, 0x100125D0, 0x10012470, 0x10012424};

void ins_uninstall(void) {
	ut_calc_reboot();
}

/* argv[0]=
 *         NULL if loaded by Ndless's stage1 at installation or OS startup
 *         "L" if loaded by a third party loader such as nLaunchy
 *         <path to ndless_resources> if run from the OS documents screen for uninstallation      
 */
int main(int __attribute__((unused)) argc, char* argv[]) {
	ut_debug_trace(INSTTR_INS_ENTER);
	ut_read_os_version_index();
	BOOL installed = FALSE;

// useless if non persistent and won't work since stage1 set it up
#if 0
	struct next_descriptor *installed_next_descriptor = ut_get_next_descriptor();
	if (installed_next_descriptor) {
		if (*(unsigned*)installed_next_descriptor->ext_name == 0x534C444E) // 'NDLS'
			installed = TRUE;
		else
			ut_panic("unknown N-ext");
	}
#endif

	if (!argv[0] || argv[0][0] == 'L') // not opened from the Documents screen
		ints_setup_handlers();
	else
		installed = TRUE;

	if (installed && nl_loaded_by_3rd_party_loader()) {
		return 0; // do nothing
	}

	if (!installed) {
		// Startup programs cannot be run safely there, as stage1 is being executed in unregistered memory. Run them asynchronously in another hook.
		HOOK_INSTALL(end_of_init_addrs[ut_os_version_index], plh_startup_hook);
		HOOK_INSTALL(ploader_hook_addrs[ut_os_version_index], plh_hook);
		lua_install_hooks();
	}

	if (argv[0] && argv[0][0] == 'L') { // third-party launcher
		loaded_by_3rd_party_loader = TRUE;
		return 0;
	}
	
	if (installed) { // ndless_resources_3.6.tns run: uninstall
		if (show_msgbox_2b("Ndless", "Do you really want to uninstall Ndless r" STRINGIFY(NDLESS_REVISION) "?\nThe device will reboot.", "Yes", "No") == 2)
			return 0;
		ins_uninstall();
	}

	// continue OS startup
	return 0;
}


// OS-specific
// gui_gc_drawIcon + 4
const unsigned ins_successmsg_hook_addrs[] = {0x1002DE38, 0x1002DDC8, 0x1002D388, 0x1002D348};

void ins_install_successmsg_hook(void) {
	HOOK_INSTALL(ins_successmsg_hook_addrs[ut_os_version_index], ins_successsuccessmsg_hook);
}

// chained after the startup programs execution
HOOK_DEFINE(ins_successsuccessmsg_hook) {
	// OS-specific: reg number
	if (HOOK_SAVED_REGS(ins_successsuccessmsg_hook)[2] == 0x171) {
		Gc gc = (Gc)HOOK_SAVED_REGS(ins_successsuccessmsg_hook)[0];
		gui_gc_setColor(gc, has_colors ? 0x32cd32 : 0x505050);
		gui_gc_setFont(gc, SerifRegular9);
		gui_gc_drawString(gc, (char*) u"Ndless installed!", 25, 4, GC_SM_TOP);
	}
	HOOK_RESTORE_RETURN(ins_successsuccessmsg_hook);
}
