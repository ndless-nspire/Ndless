/****************************************************************************
 * Ndless program loader hooks
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
 *                 Daniel TANG <dt.tangr@gmail.com>
 ****************************************************************************/

#include <os.h>
#include <sys/stat.h>

#include "ndless.h"
#include "bflt.h"
#include "zehn_loader.h"

struct assoc_file_each_cb_ctx {
	const char *prgm_name;
	char *prgm_path;
	BOOL *isassoc;
};

int assoc_file_each_cb(const char *path, void *context) {
	struct assoc_file_each_cb_ctx *ctx = context;
	if (!strcmp(ctx->prgm_name, strrchr(path, '/') + 1)) {
		strncpy(ctx->prgm_path, path, FILENAME_MAX - 1);
		*ctx->isassoc = TRUE;
		return 1;
	}
	if (!strcmp(path, "/phoenix")) { // we are scanning the whole filesystem for compatiblity with Hide Manager, except this heavy subtree
		return 2; // skip it
	}
	return 0;
}

static BOOL is_current_prgm_resident;

// Can be called through a builtin function by the running program
void ld_set_resident(void) {
	is_current_prgm_resident = TRUE;
}

enum e_ld_bin_format ld_bin_format = LD_ERROR_BIN;

static int ndless_load(const char *docpath, NUC_FILE *docfile, void **base, int (**entry_address_ptr)(int, char*[]))
{
	struct nuc_stat docstat;
	if (nuc_stat(docpath, &docstat)) {
		puts("ndless_load: can't open doc");
		return 1;
	}

	void *docptr;
	if(emu_debug_alloc_ptr)
	{
		if(emu_debug_alloc_size < docstat.st_size)
		{
			puts("ndless_load: emu_debug_alloc_size too small!");
			docptr = malloc(docstat.st_size);	
		}
		else
			docptr = emu_debug_alloc_ptr;
	}
	else
		docptr = malloc(docstat.st_size);

	if (!docptr) {
		puts("ndless_load: can't malloc");
		return 1;
	}
	if (!nuc_fread(docptr, docstat.st_size, 1, docfile)) {
		puts("ndless_load: can't read doc");
		if (!emu_debug_alloc_ptr)
			free(docptr);
		return 1;
	}

	uint32_t *ptr32 = docptr, *ptr32_end = ptr32 + ((docstat.st_size / 4) < 512 ? (docstat.st_size / 4) : 512);
	while(ptr32 < ptr32_end)
	{
		// Found an embedded Zehn file
		if(*ptr32 == 0x6e68655a && *(ptr32 + 1) == 1)
		{
			nuc_fseek(docfile, (uint8_t*)(ptr32) - (uint8_t*)(docptr), SEEK_SET);
			int ret = zehn_load(docfile, base, entry_address_ptr);
			if(ret != 1) // If the Zehn is invalid, continue searching or executing as PRG
			{
				if(!emu_debug_alloc_ptr)
					free(docptr);

				return ret;
			}
		}
		ptr32++;
	}

	*base = docptr;
	*entry_address_ptr = (int (*)(int argc, char *argv[]))(docptr + sizeof(PRGMSIG));

	return 0;
}

int ld_exec(const char *path, void **resident_ptr) {
	return ld_exec_with_args(path, 0, NULL, resident_ptr);
}

// Run a program. Returns 0xDEAD if can't run it or 0xBEEF if the error dialog should be skipped. Else returns the program return code.
// If resident_ptr isn't NULL, the program's memory block isn't freed and is stored in resident_ptr. It may be freed later with ld_free(). 
// Resident program shouldn't use argv after returning.
// argsn/args don't include the program path. args doesn't need to be NULL terminated. Can be 0/NULL.
int ld_exec_with_args(const char *path, int argsn, char *args[], void **resident_ptr) {
	char prgm_path[FILENAME_MAX];
	char doc_path[FILENAME_MAX]; // non const
	unsigned i;
	char **argv = NULL;
	char **argvptr;
	int argc;
	int ret;
	BOOL isassoc = FALSE;
	strcpy(doc_path, path);
	strcpy(prgm_path, path); // may deffer if using file association

	// File association
	char extbuf[FILENAME_MAX];
	strcpy(extbuf, prgm_path);
	char *ext = strrchr(extbuf, '.');
	if (!ext || ext == extbuf) {
		puts("ld_exec: can't find file extension");
		return 0xDEAD; // shouldn't happen, all files have a .tns extension
	}
	*ext = '\0'; // keep the extension before .tns
	ext = strrchr(extbuf, '.');
	unsigned pathlen = strlen(extbuf);
	// without '.'
	#define MAX_EXT_LEN 8
	if (ext && extbuf + pathlen - ext <= (MAX_EXT_LEN+1) && extbuf + pathlen - ext > 1) { // looks like an extension
		cfg_open();
		char ext_key[4 + MAX_EXT_LEN + 1]; // ext.extension
		strcpy(ext_key, "ext");
		strcat(ext_key, ext);
		char *prgm_name_noext = cfg_get(ext_key);
		if (prgm_name_noext) {
			char prgm_name[FILENAME_MAX + 4];
			strcpy(prgm_name, prgm_name_noext);
			strcat(prgm_name, ".tns");
			struct assoc_file_each_cb_ctx context = {prgm_name, prgm_path, &isassoc};
			file_each("/", assoc_file_each_cb, &context);
		}
		cfg_close();
	}

	ld_bin_format = LD_ERROR_BIN;

	uint32_t signature;

	NUC_FILE *prgm = nuc_fopen(prgm_path, "rb");
	if(nuc_fread(&signature, sizeof(signature), 1, prgm) != 1)
	{
		// empty file?
		nuc_fclose(prgm);
		return 0xDEAD;
	}

	nuc_fseek(prgm, 0, SEEK_SET);

	void *base = 0;
	int (*entry)(int argc, char *argv[]);

	switch(signature)
	{
	case 0x00475250: //"PRG\0"
		if((ret = ndless_load(prgm_path, prgm, &base, &entry)) == 0)
		{
			nuc_fclose(prgm);
			ld_bin_format = LD_PRG_BIN;
			break;
		}

		nuc_fclose(prgm);
		return ret == 1 ? 0xDEAD : 0xBEEF;
	case 0x544c4662: //"bFLT"
		if(bflt_load(prgm, &base, &entry) == 0)
		{
			nuc_fclose(prgm);
			ld_bin_format = LD_BFLT_BIN;
			break;
		}

		nuc_fclose(prgm);
		return 0xDEAD;
	case 0x6e68655a: //"Zehn"
		if((ret = zehn_load(prgm, &base, &entry)) == 0)
		{
			nuc_fclose(prgm);
			ld_bin_format = LD_ZEHN_BIN;
			break;
		}
		if(base && base != emu_debug_alloc_ptr)
			free(base);

		nuc_fclose(prgm);
		return ret == 1 ? 0xDEAD : 0xBEEF;
	default:
		nuc_fclose(prgm);
		return 0xDEAD;
	}	
	
	int intmask = TCT_Local_Control_Interrupts(-1); /* TODO workaround: disable the interrupts to avoid the clock on the screen */
	wait_no_key_pressed(); // let the user release the Enter key, to avoid being read by the program
	void *savedscr = malloc(SCREEN_BYTES_SIZE);
	if (!savedscr) {
		puts("ld_exec: can't malloc savedscr");
		ret = 0xDEAD;
		goto ld_exec_with_args_quit;
	}
	memcpy(savedscr, (void*) SCREEN_BASE_ADDRESS, SCREEN_BYTES_SIZE);
	
	argc = 1 + argsn;
	if (isassoc)
		argc++;

	argv = malloc((argc + 1) * sizeof(char*));
	if (!argv) {
		puts("ld_exec: can't malloc argv");
		ret = 0xDEAD;
		goto ld_exec_with_args_quit;
	}
	argv[0] = prgm_path;
	argvptr = &argv[1];
	if (isassoc) {
		argv[1] = doc_path;
		argvptr++;
	}
	if (args)
		memcpy(argvptr, args, argsn * sizeof(char*));

	argv[argc] = NULL;
	
	if (has_colors) {
		volatile unsigned *palette = (volatile unsigned*)0xC0000200;
		for (i = 0; i < 16/2; i++)
			*palette++ = ((i * 2 + 1) << (1 + 16)) | ((i * 2 + 1) << (6 + 16)) | ((i * 2 + 1) << (11 + 16)) | ((i * 2) << 1) | ((i * 2) << 6) | ((i * 2) << 11); // set the grayscale palette
		ut_disable_watchdog(); // seems to be sometimes renabled by the OS
	}
	
	is_current_prgm_resident = FALSE;
	clear_cache();
	ret = entry(argc, argv); /* run the program */
	if (has_colors)
		lcd_incolor(); // in case not restored by the program

	if (!plh_noscrredraw)
		memcpy((void*) SCREEN_BASE_ADDRESS, savedscr, SCREEN_BYTES_SIZE);
	
ld_exec_with_args_quit:
	free(savedscr);
	wait_no_key_pressed(); // let the user release the key used to exit the program, to avoid being read by the OS
	TCT_Local_Control_Interrupts(intmask);
	if (ret != 0xDEAD && resident_ptr) {
		*resident_ptr = base;
		return ret;
	}
	if (is_current_prgm_resident) // required by the program itself
		return ret;
	if (!emu_debug_alloc_ptr)
	    free(base);

	free(argv);
	return ret;
}

// To free the program's memory block when run with ld_exec(non null resident_ptr)
void ld_free(void *resident_ptr) {
	free(resident_ptr);
}

// When opening a document
HOOK_DEFINE(plh_hook) {
	char *halfpath; // [docfolder/]file.tns
	char docpath[FILENAME_MAX];
	halfpath = (char*)(HOOK_SAVED_SP(plh_hook)) + 0x788;
	snprintf(docpath, FILENAME_MAX, "/%s%s", get_documents_dir(), halfpath);
	if (ld_exec(docpath, NULL) == 0xDEAD) {
		HOOK_SAVED_REGS(plh_hook)[3] = HOOK_SAVED_REGS(plh_hook)[0]; // 'mov r3, r0' was overwritten by the hook
		HOOK_RESTORE_RETURN_SKIP(plh_hook, -0x134, 0); // to the error dialog about the unsupported format (we've overwritten a branch with our hook)
	} else {
		HOOK_RESTORE_RETURN_SKIP(plh_hook, -0xF0, 1); // skip the error dialog about the unsupported format
	}
}

static int startup_file_each_cb(const char *path, __attribute__((unused)) void *context) {
	ld_exec(path, NULL);
	return 0;
}

BOOL plh_isstartup = FALSE;
BOOL plh_noscrredraw = FALSE;

// Try to run all the documents in the startup folder and its sub-folders
HOOK_DEFINE(plh_startup_hook) {
	if (!isKeyPressed(KEY_NSPIRE_ESC)) {
		plh_isstartup = TRUE;
		file_each(NDLESS_DIR "/startup", startup_file_each_cb, NULL);
		plh_isstartup = FALSE;
	}
	ins_install_successmsg_hook();
	HOOK_RESTORE_RETURN(plh_startup_hook);
}
