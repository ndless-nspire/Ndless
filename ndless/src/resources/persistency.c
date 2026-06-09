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
 * 
 * Contributors: @delta (primary loader), @sasdallas (cleanup + uninstaller)
 */

#include <stdio.h>
#include <os.h>
#include <sys/stat.h>
#include <stdint.h>
#include <keys.h>
#include "ndless.h"
#include "hook.h"
#include <nucleus.h>

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
                        0x0, 0x0, 0x0,
                        0x0, 0x0,
                        0x0, 0x0, 0x0,
                        0x0, 0x0,
                        0x10027BC8, 0x10027CA4, 0x10027CE4,
                        0x10027BDC, 0x10027CBC, 0x10027CEC};

// OS-specific
// TI_TM_CreateState hook address used to prevent the OS from creating the snapshot
static unsigned const create_state_addrs[NDLESS_MAX_OSID+1] =
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
                        0x0, 0x0,
                        0x10031D38, 0x10031E44, 0x10031E54,
                        0x10031D4C, 0x10031E5C, 0x10031E5C};

// OS-specific
// TI_TM_ClearSnapshot hook address used to prevent the OS from clearing the snapshot
static unsigned const clear_state_addrs[NDLESS_MAX_OSID+1] =
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
                        0x0, 0x0,
                        0x100319d8, 0x10031AE4, 0x10031AF4,
                        0x100319EC, 0x10031AFC, 0x10031AFC};

// the installer tends to be around 1-2K so this is more than enough
// stack-allocating this causes the calculator to complain on real hw but not emulator!
static char buf[1024];


// helper
int copy_file(const char *src, const char *dst) {
	FILE *in = fopen(src, "rb");
	if (!in) return 1;
	FILE *out = fopen(dst, "wb");
	if (!out) { fclose(in); return 1; }

	size_t n;
	while ((n = fread(buf, 1, sizeof(buf), in)) > 0) {
        fwrite(buf, n, 1, out);
    }

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
    
    // Try to copy the file (check persistent.tns first, fallback to currentdoc.tns)
    int c = copy_file("/documents/ndless/persistent.tns", "/phoenix/syst/poweroff/currentdoc.tns");
    if (c != 0) c = copy_file("/documents/persistent.tns", "/phoenix/syst/poweroff/currentdoc.tns");
    if (c != 0) c = copy_file("/documents/ndless/currentdoc.tns", "/phoenix/syst/poweroff/currentdoc.tns");
    if (c != 0) c = copy_file("/documents/currentdoc.tns", "/phoenix/syst/poweroff/currentdoc.tns");

    if (c != 0) {
        // TODO: better error logging
        puts("persistency_install: failed to copy persistent.tns or currentdoc.tns\n");
        unlink("/phoenix/syst/poweroff/currentdoc.data");
        return;
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
}

void persistency_uninstall() {
    // unlink doesn't work here
    // TODO: figure out why unlink doesnt work here, doesnt crash but doesnt delete the file
    // this will truncate the file to 0 anyways
    FILE *f = fopen("/phoenix/syst/poweroff/currentdoc.data", "wb");
    fclose(f);
}
