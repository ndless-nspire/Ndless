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

#include <libndls.h>
#include "flat.h"

#ifndef _BFLT_H_
#define _BFLT_H_

/* Verbose level
     3 = Debugging - Prints infomation and errors
     2 = Prints errors only
     1 = Show user readable errors only
     0 = Print nothing and fail silently */
#define VERBOSE_LEVEL 2

int bflt_load(FILE* fp, void **mem_ptr, int (**entry_address_ptr)(int,char*[]));

#endif
