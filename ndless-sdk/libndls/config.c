/****************************************************************************
 * Ndless configuration management
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
 * Portions created by the Initial Developer are Copyright (C) 2012-2013
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s): 
 ****************************************************************************/

#include <os.h>

/* The config file is open whenever needed with cfg_open, and must be closed.
 * Each line of the file contains a key/value pair (key=value).
 * The key and the value are trimmed when read.
 * A comment can be added at the end of a line (# comment).
 * Invalid lines are ignored.
 */

static char *file_content = NULL; // if not NULL, the config file is open. NULL terminated.
static size_t file_size;
static unsigned max_kv_num;
static unsigned kv_num;
static unsigned short (*kv_offsets)[2]; // [line_offset][key_offset, value_offset]. Offsets from file_content.

void cfg_close(void) {
	if (!file_content) return;
	free(file_content);
	file_content = NULL;
	free(kv_offsets);
}

// Only for tests. cfg_open() should be used.
void cfg_open_file(const char *filepath) {
	if (file_content) return;
	FILE *file = fopen(filepath, "rb");
	if (!file) return;
	#define MAX_CFG_FILE_SIZE 10000
	fseek(file, 0, SEEK_END);
	file_size = ftell(file);
	if (!file_size) goto close_quit;
	file_content = malloc(file_size + 1); // +1 for the NULL char
	if (!file_content) goto close_quit;
	rewind(file);
	if (fread(file_content, 1, file_size, file) != file_size) {
		free(file_content);
		file_content = NULL;
close_quit:
		fclose(file);
		return;
	}
	fclose(file);
	file_content[file_size] = '\0';
	file_size++;
	
	unsigned i;
	unsigned line_num = 1;
	for (i = 0; i < file_size; i++) {
		if (file_content[i] == '\n')
			line_num++;
	}
	max_kv_num = line_num;
	kv_offsets = malloc(max_kv_num * sizeof(unsigned short)*2);
	if (!kv_offsets) {
		cfg_close();
		return;
	}
	char *str = file_content;
	unsigned kv_index = 0;
	char *end_of_file = file_content + file_size;
	// fill up kv_offsets[][]
	while (1) {
		char *kv = str;
		char *end_of_pair = strpbrk(str, "#\r\n"); // in case of Windows end of line, will be considered as an empty line, but not really a problem
		BOOL has_comment = FALSE;
		if (end_of_pair) {
			has_comment = (*end_of_pair == '#');
			*end_of_pair++ = 0;
		}
		char *value = strpbrk(kv, "=");
		if (value) {
			value++;
			while (*kv == ' ') kv++; // remove the spaces before the key
			str = kv;
			while (*str != 0 && *str != '=' && *str != ' ') str++;
			if (*str == ' ' || *str == '=') *str = 0; // remove the spaces after the key, and mark the end of the key
			if (*kv != 0) { // key not empty
				while (*value == ' ') value++; // remove the spaces before the value
				str = value;
				while (*str != 0 && *str != ' ') str++;
				if (*str == ' ') *str = 0; // remove the spaces after the value
				kv_offsets[kv_index][0] = kv - file_content;
				kv_offsets[kv_index++][1] = value - file_content;
				if (kv_index >= max_kv_num) break; // too many key-value pairs
			}
		}
		if (!end_of_pair) break; // end of file
		str = end_of_pair; // next key value
		if (str >= end_of_file) break; // end of file
		if (has_comment) {
			str = strpbrk(str, "\n");  // skip it
			if (!str) break; // end of file
			str++;
		}
	}
	kv_num = kv_index;
}

static int cfg_locate_cfg_file(char *dst_path, size_t dst_path_size) {
	return locate("ndless.cfg.tns", dst_path, dst_path_size);
}

void cfg_open(void) {
	static char path[300] = "";
	struct stat statbuf;
	if (path[0] == '\0' || stat(path, &statbuf) != 0)
		if (cfg_locate_cfg_file(path, sizeof(path)))
			return;

	cfg_open_file(path);
}

// Returns the value associated to the key. NULL if not found.
char *cfg_get(const char *key) {
	unsigned i;
	if (!file_content) return NULL;
	for (i = 0; i < kv_num; i++) {
		if (!strcmp(key, kv_offsets[i][0] + file_content))
			return kv_offsets[i][1] + file_content;
	}
	return NULL;
}

// Only for tests. cfg_register_filext() should be used.
void cfg_register_fileext_file(const char *filepath, const char *ext, const char *prgm) {
	char key[15] = "ext.";
	cfg_open_file(filepath);
	strncat(key, ext, 15 - 4 - 1);
	if (cfg_get(key)) {
		cfg_close();
		return;
	}
	cfg_close();
	FILE *file = fopen(filepath, "a+b");
	if (!file) return;
	fseek(file, 0, SEEK_END);
	if (ftell(file) > 0) {
		fseek(file, -1, SEEK_END);
		if (fgetc(file) != '\n') {
			fseek(file, 0, SEEK_END);
			fputc('\n', file);
		}
	}
	fseek(file, 0, SEEK_END);
	fprintf(file, "%s=%s\n", key, prgm);
	fclose(file);
}

// ext without leading '.'
void cfg_register_fileext(const char *ext, const char *prgm) {
	char path[300];
	if (cfg_locate_cfg_file(path, sizeof(path)))
		snprintf(path, sizeof(path), "%s%s", get_documents_dir(), "ndless/ndless.cfg.tns");
	cfg_register_fileext_file(path, ext, prgm);
}
