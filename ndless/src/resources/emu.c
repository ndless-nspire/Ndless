/****************************************************************************
 * Integration with emulators
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
 * Portions created by the Initial Developer are Copyright (C) 2010
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s): 
 *                 
 ****************************************************************************/

#include <os.h>
#include "ndless.h"

// set by emu_debug_alloc()
void *emu_debug_alloc_ptr;

size_t emu_debug_alloc_size()
{
	// 12 MiB if 64MiB of RAM, 8 otherwise
	int mebibytes = (has_colors && !is_cm) ? 12 : 8;
	return mebibytes * 1024 * 1024;
}

// The following functions are exported as syscalls.

/* Allocates a memory block that should be used by the loader to load the program
 * to memory when GDB is used to debug the program. The block must be big enough
 * for any program.
 * This pre-allocated block is required for the gdbstub to be able to attach to
 * the program loaded at a fixed address, since the GDB remote command "qOffsets"
 * is sent only once by GDB for each debug session.
 * Returns a pointer to the memory block, or null in case of error. */
static void *emu_debug_alloc(void) {
	if (!emu_debug_alloc_ptr)
		emu_debug_alloc_ptr = malloc(emu_debug_alloc_size());

	return emu_debug_alloc_ptr;
}

/* Free the memory block allocated with emu_debug_alloc(). */
static void emu_debug_free() {
	free(emu_debug_alloc_ptr);
	emu_debug_alloc_ptr = NULL;
}

/* Emu syscalls table. */
unsigned emu_sysc_table[] = {
	(unsigned)emu_debug_alloc, (unsigned)emu_debug_free
};
