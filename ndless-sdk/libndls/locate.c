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
#include <limits.h>

struct file_each_ctx {
	const char *filename;
	char *dst_path;
	size_t dst_path_size;
};

static int file_each_cb(const char *path, void *context) {
	struct file_each_ctx *ctx = (struct file_each_ctx *)context;
	if (!strcmp(strrchr(path, '/') + 1, ctx->filename)) {
		ctx->dst_path[ctx->dst_path_size-1] = '\0';
		strncpy(ctx->dst_path, path, ctx->dst_path_size);
		if (ctx->dst_path[ctx->dst_path_size-1]) return 0;
		return 1;
	}
	return 0;
}

// Search a file in all subdirectories of the virtual root directory
// dst_path must be dst_path_size long.
// Returns 0 if found, 1 if not found (i.e. dst_path not filled).
int locate(const char *filename, char *dst_path, size_t dst_path_size) {
	struct file_each_ctx ctx;
	ctx.filename = filename;
	ctx.dst_path = dst_path;
	ctx.dst_path_size = dst_path_size;
	if (file_each(get_documents_dir(), file_each_cb, &ctx)) {
		return 0;
	}
	return 1;
}