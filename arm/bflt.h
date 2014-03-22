/* Loads bFLT binaries
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Original author: Daniel Tang <dt.tangr@gmail.com>
 * Original source code: https://github.com/tangrs/ndless-bflt-loader
 *
 */

#include <os.h>
#include "flat.h"

#ifndef _BFLT_H_
#define _BFLT_H_

int bflt_load(char* filename, void **mem_ptr, size_t* mem_size, int (**entry_address_ptr)(int,char*[]));
int bflt_fload(FILE* fp, void **mem_ptr, size_t* mem_size, int (**entry_address_ptr)(int,char*[]));
void bflt_free(void* ptr);
void bflt_free_cached();

#endif
