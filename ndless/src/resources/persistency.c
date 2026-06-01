/****************************************************************************
 * Ndless persistency mechanism
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
 ****************************************************************************/

#include <stdio.h>
#include <os.h>
#include <sys/stat.h>
#include <stdint.h>
#include <keys.h>
#include "ndless.h"
#include "hook.h"
#include <nucleus.h>

/**
 * The way this persistency loader works:
 * On startup the operating system will try to execute /phoenix/syst/poweroff/currentdoc.tns
 * This file is created when the user presses Ctrl + On to poweroff the device,
 * such that if the calculator resets it will restore their work.
 * 
 * We simply need to copy a headless Ndless installer to the directory, then on
 * resources we can copy it again (the OS deletes it) and then patch some routines
 * 
 * This does disable the operating system's mechanism to save documents.
 * The loader will be deleted on Ndless uninstall.
 */

// OS-specific 
// Address of the save dialog function
static unsigned const save_dialog_hook_addrs[NDLESS_MAX_OSID+1] =
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
                        0x10025C3C, 0xDEADBEEF, 0x10025C74,
                        0x0, 0x0,
                        0x10027C78, 0xDEADBEEF, 0x10027E08,
                        0x0, 0x0,
                        0x10027bc8, 0xDEADBEEF, 0x10027CE4,
                        0x10027BDC, 0xDEADBEEF, 0x10027CEC};

// OS-specific
// TI_TM_CreateState hook address used to prevent the OS from creating the snapshot
static unsigned const create_state_addrs[NDLESS_MAX_OSID+1] = {
    0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
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
    0x1002FD6C, 0x0, 0x1002FDA4,
    0x0, 0x0,
    0x10031DE8, 0x0, 0x10031F78,
    0x0, 0x0,
    0x10031d38, 0x0, 0x10031E54,
    0x10031D4C, 0x0, 0x10031E5C
};

// OS-specific
// TI_TM_ClearSnapshot hook address used to prevent the OS from clearing the snapshot
static unsigned const clear_state_addrs[NDLESS_MAX_OSID+1] = {
    0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
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
    0x1002FA0C, 0x0, 0x1002FA44,
    0x0, 0x0,
    0x10031A88, 0x0, 0x10031C18,
    0x0, 0x0,
    0x100319d8, 0x0, 0x10031AF4,
    0x100319EC, 0x0, 0x10031AFC
};

static BOOL is_persistent = FALSE;

// helper
int copy_file(const char *src, const char *dst) {
	FILE *in = fopen(src, "rb");
	if (!in) return 1;
	FILE *out = fopen(dst, "wb");
	if (!out) { fclose(in); return 1; }

	char buf[4096];
	size_t n;
	while ((n = fread(buf, 1, sizeof(buf), in)) > 0)
		fwrite(buf, 1, n, out);

	fclose(in);
	fclose(out);
	return 0;
}

HOOK_DEFINE(save_dialog_hook) {
	// this kills the save dialog that normally appears on startup - makes it auto say no
	unsigned *regs = HOOK_SAVED_REGS(save_dialog_hook);
	
    // zero the flag in the dialog struct
	if (regs[0]) *(unsigned*)regs[0] = 0;

    // set return value to magic no
	regs[0] = 0x13F2;
	
    HOOK_RESTORE_SP(save_dialog_hook);
	HOOK_RESTORE_STATE();
	__asm volatile("bx lr");
}

HOOK_DEFINE(create_state_hook) {
    HOOK_RESTORE_SP(create_state_hook);
	HOOK_RESTORE_STATE();
	__asm volatile("bx lr");
}

HOOK_DEFINE(clear_state_hook) {
    HOOK_RESTORE_SP(clear_state_hook);
    HOOK_RESTORE_STATE();
    __asm volatile ("bx lr");
}

// called when a 'P' is passed to the ndless loader. CX II only for now
void persistency_install() {
    if (isKeyPressed(KEY_NSPIRE_ESC)) {
        return; // last chance to back out
    }

    // Build the currentdoc.data file, format is unknown but this is enough to trick the OS
    uint32_t currentdoc_data[0x21C / sizeof(uint32_t)];
    memset(currentdoc_data, 0, sizeof(currentdoc_data));
    currentdoc_data[0] = 1;
    currentdoc_data[2] = 1;
    currentdoc_data[4] = 1;

    // Save the file
    FILE *data = fopen("/phoenix/syst/poweroff/currentdoc.data", "wb");
    if (data) {
        fwrite(currentdoc_data, sizeof(currentdoc_data), 1, data);
        fclose(data);
    } else {
        // TODO: better error logging
        puts("persistency_install: failed to create currentdoc.data\n");
        return;
    }
    
    // Try to copy the file
    int c = copy_file("/documents/ndless/currentdoc.tns", "/phoenix/syst/poweroff/currentdoc.tns");
    if (c != 0) {
        // We have Ndless generosity...
        c = copy_file("/documents/currentdoc.tns", "/phoenix/syst/poweroff/currentdoc.tns");
        if (c != 0) {
            // TODO: better error logging
            puts("persistency_install: failed to copy currentdoc.tns\n");
            unlink("/phoenix/syst/poweroff/currentdoc.data");
            return;
        }
    }

    // Install hooks
    unsigned create_state_addr = create_state_addrs[ut_os_version_index];
    if (create_state_addr) {
        HOOK_INSTALL(create_state_addr, create_state_hook);
    }

    unsigned clear_state_addr = clear_state_addrs[ut_os_version_index];
    if (clear_state_addr) {
        HOOK_INSTALL(clear_state_addr, clear_state_hook);
    }

    unsigned save_addr = save_dialog_hook_addrs[ut_os_version_index];
    if (save_addr) {
        HOOK_INSTALL(save_addr, save_dialog_hook);
    }

    unlink("/documents/!!!MyDocuments/!!!UnsavedDocument.tns");
    is_persistent = TRUE;
}

void persistency_uninstall_save_hook() {
    if (is_persistent) {
        unsigned save_addr = save_dialog_hook_addrs[ut_os_version_index];
        if (save_addr) {
            HOOK_UNINSTALL(save_addr, save_dialog_hook);
        }
    }
}
