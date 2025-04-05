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
#include <limits.h>

/* The config file is open whenever needed with cfg_open, and must be closed.
 * Each line of the file contains a key/value pair (key=value).
 * The key and the value are trimmed when read.
 * A comment can be added at the end of a line (# comment).
 * Invalid lines are ignored.
 */

static char open_file[PATH_MAX] = {0};
static unsigned max_kv_num;
static unsigned kv_num;
static unsigned cmt_num;
static struct cfg_entry *cfg_entries;
static char **cfg_comments;
static BOOL cfg_changed;

void cfg_save_file(const char *filepath) {
	FILE *file = fopen(filepath, "wb");
	if(!file) return;

	unsigned i;
	for(i = 0; i < kv_num; i++) {
		struct cfg_entry *n_entr = &cfg_entries[i];
		if(i < cmt_num && cfg_comments[i]) {
			fprintf(file, "%s=%s #%s\n", n_entr->key, n_entr->value, cfg_comments[i]);
		} else {
			fprintf(file, "%s=%s\n", n_entr->key, n_entr->value);
		}
	}
	fclose(file);
}

void cfg_close(void) {
	if (!open_file[0]) return;
	if(cfg_changed) {
		cfg_save_file(open_file);
	}
	unsigned i;
	for(i = 0; i < kv_num; i++) {
		free(cfg_entries[i].value);
	}
	cfg_changed = 0;
	free(cfg_entries);
	for(i = 0; i < cmt_num; i++) {
		if(cfg_comments[i]) free(cfg_comments[i]);
	}
	free(cfg_comments);
	open_file[0] = '\0';
	cfg_entries = NULL;
	cfg_comments = NULL;
}

static unsigned pow2_roundup(unsigned x) {
	return 1<<(32 - __builtin_clz(x - 1));
}

// Only for tests. cfg_open() should be used.
void cfg_open_file(const char *filepath) {
	if (open_file[0]) return;
	FILE *file = fopen(filepath, "rb");
	if (!file) return;
	#define MAX_CFG_FILE_SIZE 10000
	fseek(file, 0, SEEK_END);
	size_t file_size = ftell(file);
	char *file_content = malloc(file_size + 1); // +1 for the NULL char
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
	max_kv_num = line_num == 0 ? 1 : pow2_roundup(line_num);
	cfg_entries = malloc(max_kv_num * sizeof(struct cfg_entry));
	cfg_comments = calloc(max_kv_num, sizeof(char *));
	if (!cfg_entries) {
		free(file_content);
		cfg_close();
		return;
	}
	cfg_changed = 0;
	char *str = file_content;
	unsigned kv_index = 0;
	char *end_of_file = file_content + file_size;
	if(line_num == 0) {
		goto loop_end;
	}
	// fill up cfg_entries[]
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
				struct cfg_entry *entry = &cfg_entries[kv_index++];
				strlcpy(entry->key, kv, KEY_SIZE);
				size_t val_len = strlen(value) + 1;
				entry->value_sz = pow2_roundup(val_len);
				entry->value = malloc(entry->value_sz);
				strlcpy(entry->value, value, entry->value_sz);

				if (kv_index >= max_kv_num) break; // too many key-value pairs
			}
		}
		if (!end_of_pair) break; // end of file
		str = end_of_pair; // next key value
		if (str >= end_of_file) break; // end of file
		if (has_comment) {
			char *ns = strpbrk(str, "\n");
			if(value) {
				if(!ns) ns = end_of_file;
				char *cmt = cfg_comments[kv_index - 1] = malloc(ns - str + 1);
				memcpy(cmt, str, ns - str);
				cmt[ns - str] = '\0';
			}
			str = ns;  // skip it
			if (!str) break; // end of file
			str++;
		}
	}
	loop_end:
	cmt_num = kv_num = kv_index;
	strlcpy(open_file, filepath, PATH_MAX);
	free(file_content);
}

static int cfg_locate_cfg_file(char *dst_path, size_t dst_path_size) {
	static char cfg_path[PATH_MAX] = {0};
	if(cfg_path[0] == 0) snprintf(cfg_path, PATH_MAX, "%s%s", get_documents_dir(), "ndless/ndless.cfg.tns");
	if(access(cfg_path, F_OK) == -1) {
		int l = locate("ndless.cfg.tns", cfg_path, PATH_MAX);
		if(l != 0) return l;
	}
	size_t actual_path_len = strlen(cfg_path);
	if(actual_path_len+1 > dst_path_size) return 1;
	memcpy(dst_path, cfg_path, actual_path_len);
	dst_path[actual_path_len] = 0;
	return 0;
}

void cfg_open(void) {
	static char path[PATH_MAX] = "";
	struct stat statbuf;
	if (path[0] == '\0' || stat(path, &statbuf) != 0)
		if (cfg_locate_cfg_file(path, sizeof(path)))
			return;

	cfg_open_file(path);
}

struct cfg_entry *cfg_get_entry(const char *key) {
	unsigned i;
	if (!open_file[0]) return NULL;
	for (i = 0; i < kv_num; i++) {
		struct cfg_entry *e = &cfg_entries[i];
		if (strcmp(key, e->key) == 0)
			return e;
	}
	return NULL;
}

// Returns the value associated to the key. NULL if not found.
const char *cfg_get(const char *key) {
	struct cfg_entry *e = cfg_get_entry(key);
	return e == NULL ? NULL : e->value; 
}

void cfg_set_value(struct cfg_entry *entr, const char *val) {
	if(strcmp(entr->value, val)) {
		size_t vl = strlen(val) + 1;
		if(vl > entr->value_sz || vl <= entr->value_sz / 2) {
			entr->value_sz = pow2_roundup(vl);
			entr->value = realloc(entr->value, entr->value_sz);
		}
		strlcpy(entr->value, val, entr->value_sz);
		cfg_changed = 1;
	}
}

struct cfg_entry *cfg_put(const char *key, const char *val) {
	struct cfg_entry *entr = cfg_get_entry(key);
	if(entr != NULL) {
		cfg_set_value(entr, val);
	} else {
		if(kv_num == max_kv_num) {
			max_kv_num *= 2;
			cfg_entries = realloc(cfg_entries, max_kv_num * sizeof(struct cfg_entry));
		}
		struct cfg_entry *entr = &cfg_entries[kv_num++];
		strlcpy(entr->key, key, 15);
		size_t vl = strlen(val) + 1;
		entr->value_sz = pow2_roundup(vl);
		entr->value = malloc(entr->value_sz);
		strlcpy(entr->value, val, entr->value_sz);
		cfg_changed = 1;
	}
	return entr;
}

void cfg_put_fileext(const char *ext, const char *prgm) {
	char key[15] = "ext.";
	strlcat(key, ext, 15);
	struct cfg_entry *entr;
	if((entr = cfg_get_entry(key))) {
		size_t pl = strlen(prgm);
		size_t vl = strlen(entr->value);
		if(pl > vl || entr->value[0] != '/' || strcmp(entr->value + (vl - pl), prgm)) {
			cfg_set_value(entr, prgm);
		}
	} else {
		cfg_put(key, prgm);
	}
}

// Only for tests. cfg_register_fileext() should be used.
void cfg_register_fileext_file(const char *filepath, const char *ext, const char *prgm) {
	cfg_open_file(filepath);
	cfg_put_fileext(ext, prgm);
	cfg_close();
}

// ext without leading '.'
void cfg_register_fileext(const char *ext, const char *prgm) {
	if (open_file[0] == 0) {
		char path[300];
		if (cfg_locate_cfg_file(path, sizeof(path)))
			snprintf(path, sizeof(path), "%s%s", get_documents_dir(), "ndless/ndless.cfg.tns");
		cfg_register_fileext_file(path, ext, prgm);
	} else {
		cfg_put_fileext(ext, prgm);
	}
}
