/****************************************************************************
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
 * Portions created by the Initial Developer are Copyright (C) 2014
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s): 
 ****************************************************************************/

#include <os.h>
#include <stdlib.h>

static int scmp(const void *sp1, const void *sp2) {
	return strcmp(*(char**)sp1, *(char**)sp2);
}

// Calls callback() for each file and folder found in folder and its subfolders. context is passed to callback() and can be NULL.
// callback() must return:
//  * 0 to continue the scan
//  * 1 to abort the scan
//  * 2 to continue the scan but not recurse through the current directory
// Returns non-zero if callback() asked to abort.
int file_each(const char *folder, int (*callback)(const char *path, void *context), void *context) {
	char subfolder_or_file[FILENAME_MAX];
	DIR *dp;
	struct dirent *ep;     
	struct stat statbuf;
	#define MAX_FILES_IN_DIR 100
	#define MEAN_FILE_NAME_SIZE 50
	#define FILENAMES_BUF_SIZE (MEAN_FILE_NAME_SIZE * MAX_FILES_IN_DIR)
	char *filenames;
	char *filenames_ptrs[MAX_FILES_IN_DIR];
	if (!(filenames = malloc(FILENAMES_BUF_SIZE)))
		return 0;
	if (!(dp = opendir(folder))) {
		free(filenames);
		return 0;
	}
	// list the directory to sort its content
	unsigned i;
	unsigned filenames_used_bytes = 0;
	char *ptr;
	for (i = 0, ptr = filenames; (ep = readdir(dp)) && i < MAX_FILES_IN_DIR && ptr < filenames + FILENAMES_BUF_SIZE; i++) {
		if (!strcmp(ep->d_name, ".") || !strcmp(ep->d_name, "..")) {
			i--;
			continue;
		}
		size_t dname_len = strlen(ep->d_name);
		if (FILENAMES_BUF_SIZE - filenames_used_bytes < dname_len + 1)
			break;
		strcpy(ptr, ep->d_name);
		filenames_ptrs[i] = ptr;
		ptr += dname_len + 1;
	}
	unsigned filenum = i;
	qsort(filenames_ptrs, filenum, sizeof(char*), scmp);
	
	for (i = 0; i < filenum; i++) {
		strcpy(subfolder_or_file, folder);
		if (subfolder_or_file[strlen(subfolder_or_file) - 1] != '/')
			strcat(subfolder_or_file, "/");
		strcat(subfolder_or_file, filenames_ptrs[i]);
		if (stat(subfolder_or_file, &statbuf) == -1)
			continue;
		int next_action = callback(subfolder_or_file, context);
		if (next_action == 1) {
			closedir(dp);
			free(filenames);
			return 1;
		}
		if (S_ISDIR(statbuf.st_mode) && next_action != 2) {
			if (file_each(subfolder_or_file, callback, context)) {
				closedir(dp);
				free(filenames);
				return 1;
			}
		}
	}
	closedir(dp);
	free(filenames);
	return 0;
}
