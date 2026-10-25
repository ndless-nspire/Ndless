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
#include <_dialog.h>

#include "lcd_compat.h"
#include "ndless.h"
#include "icon.h"

// OS-specific
// Call to the dialog box display telling that the format isn't recognized.
static unsigned const ploader_hook_addrs[NDLESS_MAX_OSID+1] =
					       {0x10009984, 0x1000995C, 0x10009924, 0x10009924, 0x100098CC, 0x100098CC,
						0x1000A988, 0x1000A95C, 0x1000A920, 0x1000A924,
						0x1000A810, 0x1000A7D0, 0x0, 0x0,
						0x0, 0x0, 0x1000A79C, 0x1000A78C,
						0x1000A7B0, 0x1000A7AC,
						0x1000A868, 0x1000A864,
						0x1000AA64, 0x1000AA60,
						0x1000AC4C, 0x1000AC48,
						0x1000ACD0, 0x1000ACD8,
						0x1000AD90, 0x1000AD8C,
						0x1000ADAC, 0x1000ADB4,
						0x1000ADAC, 0x1000ADE4,
						0x1002612C, 0x10026144, 0x10026164,
						0x1000B034, 0x1000B074,
						0x10028168, 0x100282A0, 0x100282F8,
						0x1000b030, 0x1000b064,
						0x100280b8, 0x10028194, 0x100281d4,
						0x100280cc, 0x100281ac, 0x100281dc};

// initialized at load time. Kept in resident program memory, use nl_is_3rd_party_loader to read it.
static BOOL loaded_by_3rd_party_loader = FALSE;

BOOL ins_loaded_by_3rd_party_loader(void) {
	return loaded_by_3rd_party_loader;
}

static unsigned const end_of_init_addrs[NDLESS_MAX_OSID+1] =
					       {0x100104F0, 0x10010478, 0x100104BC, 0x1001046C, 0x1000ED30, 0x1000ECE0,
						0x1001264C, 0x100125D0, 0x10012470, 0x10012424,
						0x0, 0x0, 0x0, 0x0,
						0x0, 0x0, 0x0, 0x0,
						0x10012420, 0x100123CC,
						0x100124F4, 0x100124A0,
						0x10012740, 0x100126EC,
						0x10012C78, 0x10012C24,
						0x10012D5C, 0x10012D14,
						0x10012E54, 0x10012E00,
						0x10012E8C, 0x10012E44,
						0x0, 0x0,
						0x0, 0x0, 0x0,
						0x0, 0x0,
						0x0, 0x0, 0x0,
						0x0, 0x0,
						0x0, 0x0, 0x0,
						0x0, 0x0, 0x0};

// OS-specific
// get_res_string + 0xC8
static unsigned const error_msg_patch_addrs[NDLESS_MAX_OSID+1] =
					       {0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
						0x0, 0x0, 0x0, 0x0,
						0x10111778, 0x10111574, 0x0, 0x0,
						0x0, 0x0, 0x1011193C, 0x10111768,
						0x10112DC4, 0x10112C14,
						0x1011811C, 0x10117F6C,
						0x1011BFB8, 0x1011BE10,
						0x10120E84, 0x10120CDC,
						0x10123CC8, 0x10123B14,
						0x10125670, 0x10125508,
						0x10125B58, 0x10125A7C,
						0x10126084, 0x10125FB4,
						0x1015CC6C, 0x1015CE10, 0x1015CDFC,
						0x1012656C, 0x101264F4,
						0x101600AC, 0x10160354, 0x1016038C,
						0x10124394, 0x10124290,
						0x1016ABB8, 0x1016AE18, 0x1016ADDC,
						0x1016ABFC, 0x1016AE68, 0x1016AE38
						};

// OS-specific (only set if the installer document needs to be closed)
// close_document
static unsigned const close_document_addrs[NDLESS_MAX_OSID+1] =
					       {0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
						0x0, 0x0, 0x0, 0x0,
						0x0, 0x0, 0x0, 0x0,
						0x0, 0x0, 0x0, 0x0,
						0x0, 0x0,
						0x0, 0x0,
						0x0, 0x0,
						0x0, 0x0,
						0x0, 0x0,
						0x1000b240, 0x1000b23c,
						0x0, 0x0,
						0x1000B278, 0x1000B2B0,
						0x100265D4, 0x10026614, 0x1002660C,
						0x1000B4E4, 0x1000B524,
						0x10028610, 0x10028770, 0x100287A0,
						0x1000b4e0, 0x1000b514,
						0x10028560, 0x10028664, 0x1002867c,
						0x10028574, 0x1002867c, 0x10028684};

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

	if (!argv[0] || argv[0][0] == 'L' || argv[0][0] == 'P') // not opened from the Documents screen
	{
		sc_install_compat();
		ints_setup_handlers();
	}
	else
		installed = TRUE;

	//These initialization routines need syscalls, so execute them after ints_setup_handlers
	extern void initialise_monitor_handles();
	initialise_monitor_handles();
	extern void __cpp_init();
	__cpp_init();

	if (installed && nl_loaded_by_3rd_party_loader())
		return 0; // do nothing

	if (!installed) {
		// Load is_hww
		lcd_compat_load_hwrev();

		// Patch leftmost column on the CX II being cut off
		if (nl_is_cx2() && *(volatile unsigned int*)0xC0000004 == 0x03780d3f)
			*(volatile unsigned int *)0xC0000004 = 0x0720013F;

		// 3.9, 4.0.3 and 4.2.0 don't need to be rebooted
		if(ut_os_version_index < 10)
		{
			// Startup programs cannot be run safely there, as stage1 is being executed in unregistered memory. Run them asynchronously in another hook.
			if(end_of_init_addrs[ut_os_version_index] != 0)
				HOOK_INSTALL(end_of_init_addrs[ut_os_version_index], plh_startup_hook);
		}
		else // 3.9, 4.0.3, 4.2.0, 4.4.0 and 4.5.0
		{
			// Do persistency if needed
			if (argv[0] && argv[0][0] == 'P') {
				persistency_install();
			}

			// Run startup programs (and successmsg hook installation) now
			plh_startup();

			// Patch the annoying TI_RM_GetString error message
			if (error_msg_patch_addrs[ut_os_version_index] != 0)
				*(volatile uint32_t *) error_msg_patch_addrs[ut_os_version_index] = 0xEA000004;

			// The next HOOK_INSTALL invocation clears the cache for us
		}

		// Cache the path to ndless.cfg.tns to keep working even if the virtual root changes
		cfg_open();
		cfg_close();

		if(ut_os_version_index < 6)
			HOOK_INSTALL(ploader_hook_addrs[ut_os_version_index], plh_hook_31);
		else if(ut_os_version_index < 26) // plh_hook_36 works for 3.9, 4.0 and 4.2 as well
			HOOK_INSTALL(ploader_hook_addrs[ut_os_version_index], plh_hook_36);
		else // plh_hook_44 works for 4.4 and 4.5
			HOOK_INSTALL(ploader_hook_addrs[ut_os_version_index], plh_hook_44);

		lua_install_hooks();
		ins_install_status_dialog_hook();
	}

	if (argv[0] && argv[0][0] == 'L') { // third-party launcher
		loaded_by_3rd_party_loader = TRUE;
		return 0;
	}

	if (installed) { // ndless_resources.tns run: uninstall
		if (show_msgbox_2b("Ndless", "Do you really want to uninstall Ndless r" STRINGIFY(NDLESS_REVISION) "?\nThe device will reboot.", "Yes", "No") == 2)
			return 0;

		persistency_uninstall();
		ins_uninstall();
	}

	if(ut_os_version_index < 6) {
		PCFD fd = NU_Open("/phoenix/install/TI-Nspire.tnc", 0, 0); // any file will do to get a fd
		if (fd > 0){
			NU_Close(fd - 1); // the FILE* is unknown, this is an heuristic
			NU_Close(fd);
		}

		// Continue OS startup
		// Simulate the prolog of the thread function for correct function return. Set r4 to a dummy variable, written to by a sub-function that follows.
		unsigned const init_task_return_addrs[] = {0x10001548, 0x10001548, 0x10001510, 0x10001510, 0x100014F8, 0x100014F8};
		__asm volatile("add lr, pc, #8; stmfd sp!, {r4-r6,lr}; sub sp, sp, #0x18; mov r4, sp; mov pc, %0" : : "r" (init_task_return_addrs[ut_os_version_index]));
	}

	return 0;
}


// OS-specific
// gui_gc_drawIcon + 4
const unsigned ins_successmsg_hook_addrs[NDLESS_MAX_OSID+1] =
					{0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
					 0x1002DE38, 0x1002DDC8, 0x1002D388, 0x1002D348,
					 0x1002E2C0, 0x1002E224, 0x0, 0x0,
					 0x0, 0x0, 0x1002D804, 0x1002D798,
					 0x1002D818, 0x1002D7C0,
					 0x1002F4EC, 0x1002F494,
					 0x1002F92C, 0x1002F8D4,
					 0x1002FF24, 0x1002FEC0,
					 0x1003108C, 0x10031034,
					 0x100310FC, 0x100310A4,
					 0x100311C4, 0x10031164,
					 0x100311C0, 0x10031198,
					 0x1004AD6C, 0x1004ADF4, 0x1004ADB4,
					 0x1003167C, 0x10031660,
					 0x1004CE70, 0x1004D018, 0x1004D00C,
					 0x1003163C, 0x10031614,
					 0x1004CD84, 0x1004CEDC, 0x1004CEAC,
					 0x1004CDA8, 0x1004CF0C, 0x1004CED0};

// OS-specific
// number of the HOME icon
const unsigned ins_successmsg_icon[NDLESS_MAX_OSID+1] =
					{0x171, 0x171, 0x171, 0x171, 0x171, 0x171,
					 0x171, 0x171, 0x171, 0x171,
					 0x171, 0x171, 0x171, 0x171,
					 0x171, 0x171, 0x171, 0x171,
					 0x171, 0x171,
					 0x171, 0x171,
					 0x171, 0x171,
					 0x172, 0x172,
					 0x172, 0x172,
					 0x172, 0x172,
					 0x172, 0x172,
					 0x172, 0x172,
					 0x14F, 0x14F, 0x14F,
					 0x18C, 0x18C,
					 0x14F, 0x14F, 0x14F,
					 0x18C, 0x18C,
					 0x14F, 0x14F, 0x14F,
					 0x14F, 0x14F, 0x14F};

void ins_install_successmsg_hook(void) {
	if(ins_successmsg_hook_addrs[ut_os_version_index] == 0)
		return;

	HOOK_INSTALL(ins_successmsg_hook_addrs[ut_os_version_index], ins_successsuccessmsg_hook);
}

// chained after the startup programs execution
HOOK_DEFINE(ins_successsuccessmsg_hook) {
	unsigned short msg[] = u"Ndless successfully installed!";

	static bool closed = false;
	if (!closed && close_document_addrs[ut_os_version_index] && !ins_loaded_by_3rd_party_loader()) {
		// To not close more than necessary and prevent recursion
		closed = true;
		((void(*)())close_document_addrs[ut_os_version_index])();
	}

	// OS-specific: reg number
	if (HOOK_SAVED_REGS(ins_successsuccessmsg_hook)[2] == ins_successmsg_icon[ut_os_version_index]) {
		Gc gc = (Gc)HOOK_SAVED_REGS(ins_successsuccessmsg_hook)[0];
		gui_gc_setColor(gc, has_colors ? 0x32cd32 : 0x505050);
		gui_gc_setFont(gc, Bold9);

		int str_width = gui_gc_getStringWidth(gc, Bold9, (char*)msg, 0, 0xFFFFFFFF);
		gui_gc_drawString(gc, (char*)msg, (320 - str_width) / 2, 212, GC_SM_TOP);

		static int i = 6;
		if (!i--) {
			HOOK_UNINSTALL(ins_successmsg_hook_addrs[ut_os_version_index], ins_successsuccessmsg_hook);
			clear_cache();
		}
	}

	HOOK_RESTORE_RETURN(ins_successsuccessmsg_hook);
}

// OS-specific
// TI_UI_Dialog_HandheldStatus4 entry
// This requires multiple system calls to be available (e.g. TI_DM_setPanelLayout) that may not be available on all OS versions.
static unsigned const status_dialog_hook_addrs[NDLESS_MAX_OSID+1] =
			       {0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
				0x0, 0x0, 0x0, 0x0,
				0x0, 0x0, 0x0, 0x0,
				0x0, 0x0, 0x0, 0x0,
				0x0, 0x0,
				0x0, 0x0,
				0x0, 0x0,
				0x0, 0x0,
				0x0, 0x0,
				0x0, 0x0,
				0x0, 0x0,
				0x0, 0x0,
				0x0, 0x0, 0x0,
				0x0, 0x0,
				0x0, 0x0, 0x0,
				0x10989B18, 0x109EE474,
				0x109D8C4C, 0x10A37134, 0x10A4091C,
				0x109D9188, 0x10A376AC, 0x10A40F04};

// We can't use draw_image from libndls here because it calls
// UiComponent_setMinSize which clamps the widget to the icon's pixel dimensions and hides the lbl text
static uint32_t status_vtable[32];
static int (*status_orig_handler)(void *, void *);

static int status_canvas_paint_hook(void *widget, void *event) {
	unsigned char event_id = *(unsigned char *)event;
	int result = status_orig_handler(widget, event);
	if (event_id == 0x49) {
		void *gc = *(void **)((uint32_t)event + 0xC);
		if (gc)
			gui_gc_drawImage(gc, (char *)ndless_icon_data, 0, 0);
	}

	return result;
}

static void status_dm_draw_image(void *widget) {
	uint32_t *raw = (uint32_t *)widget;
	uint32_t *orig_vt = (uint32_t *)raw[0];

	memcpy(status_vtable, orig_vt, 32 * sizeof(uint32_t));

	status_orig_handler = (int(*)(void*,void*))orig_vt[1];
	status_vtable[1] = (uint32_t)&status_canvas_paint_hook;

	raw[0] = (uint32_t)status_vtable;
}

static int on_credits_button_click(int w __attribute__((unused)), int e __attribute__((unused)), int val) {
	if (val == DLG_BUTTON_PRESS_VAL) {
		show_msgbox("Ndless Credits",
			"Lead Maintainer:\n"
			"  Fabian Vogt (Vogtinator)\n\n"
			"Creators:\n"
			"  Geoffrey Anneheim (geogeo)\n"
			"  Olivier Armand (ExtendeD)\n\n"
			"Contributors & Testers:\n"
			"  Adriweb, bsl, cherpixel, critor, delta,\n"
			"  Excale, Goplat, hoffa, Jim Bauwens,\n"
			"  Legimet, Levak, Lionel Debroux, lkj,\n"
			"  sasdallas, satyamedh, tangrs,\n"
			"  timmycraft, vailithree...\n\n"
			"ndless.me - github.com/ndless-nspire");
	}

	return 0;
}

static uint32_t *status_ctx = NULL;
static unsigned status_orig_lr = 0;

// this fires in the middle of the button panel builder, between about & ok
HOOK_DEFINE(handheld_status_btn_hook) {
	// OS-specific: reg number
	void *btn_panel = (void *)HOOK_SAVED_REGS(handheld_status_btn_hook)[5];
	if (btn_panel)
		TI_DM_addButton(btn_panel, u"Ndless Credits", 0, 0, 0, DLG_BUTTON_FLAGS, DLG_BUTTON_FLAGS2, 0, (int)on_credits_button_click);

	HOOK_RESTORE_RETURN(handheld_status_btn_hook);
}

static unsigned __attribute__((used)) handheld_status_post_hook_body(void) {
	if (status_ctx[4]) { // bottom button panel
		void *btn_panel = (void *)status_ctx[4];
		// handheld status builds the panel with the two btn layout 0x128ED, so we switch to 0x128E3 to allow 3 instead
		TI_DM_setPanelLayout(btn_panel, DLG_LAYOUT_BUTTON_BAR);
	}

	return status_orig_lr;
}

// called on return from TI_UI handheld status function
// just a simple utility to update the button panel's layout to button bar for 3 buttons
static void __attribute__((naked)) handheld_status_post_hook(void) {
	__asm volatile(
		"push {r0-r3, lr}\n"
		"bl handheld_status_post_hook_body\n"
		"mov ip, r0\n"
		"pop {r0-r3, lr}\n"
		"bx ip\n"
	);
}

HOOK_DEFINE(handheld_status_hook) {
	unsigned *regs = HOOK_SAVED_REGS(handheld_status_hook);
	uint32_t *ctx = (uint32_t *)regs[0];
	if (ctx && ctx[1]) {
		void *root = (void *)ctx[1];
		TI_DM_addSeparatorLine(root);
		void *row = TI_DM_newPanel(root, 0);
		if (row) {
			TI_DM_setPanelLayout(row, DLG_LAYOUT_SETTINGS_ROW);
			TI_DM_setPanelLRBorder(row, 6, 6);
			TI_DM_setPanelTBBorder(row, 3, 2);
			void *lbl = TI_DM_addLabel(row, u"\t  Ndless r" STRINGIFY(NDLESS_REVISION), 0, 0, 0, DLG_LABEL_STYLE, DLG_LABEL_WRAP);
			if (lbl) {
				status_dm_draw_image(lbl);
				TI_DM_groupControlWithLabel(row, lbl, 0);
			}
		}

		status_ctx = ctx;
		status_orig_lr = regs[13];
		regs[13] = (unsigned)handheld_status_post_hook;
	}

	HOOK_RESTORE_RETURN(handheld_status_hook);
}

void ins_install_status_dialog_hook(void) {
	if (status_dialog_hook_addrs[ut_os_version_index] == 0)
		return;

	HOOK_INSTALL(status_dialog_hook_addrs[ut_os_version_index], handheld_status_hook);

	// +0x44 is after the about button is created & stored, before the ok button
	HOOK_INSTALL(status_dialog_hook_addrs[ut_os_version_index] + 0x44, handheld_status_btn_hook);
}
