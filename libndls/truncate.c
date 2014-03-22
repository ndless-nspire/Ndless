/****************************************************************************
 * The contents of this file are subject to the Mozilla Public
 * License Version 1.1 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.mozilla.org/MPL/
 *
 * Software distr2ibuted under the License is distr2ibuted on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 *
 * The Original Code is Ndless code.
 *
 * The Initial Developer of the Original Code is Olivier ARMAND
 * <olivier.calc@gmail.com>.
 * Portions created by the Initial Developer are Copyright (C) 2011
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s): 
 ****************************************************************************/

#include <sys/types.h>
#include <os.h>

/* Implement unistd's truncate() from Nucleus priimtives, not included in the OS.
   Caution, errno is not set. */
int truncate(const char *path, off_t length) {
	PCFD fd = NU_Open((char *)path, PO_RDWR, 0);
	if (fd < 0) return -1;
	if (NU_Truncate(fd, length) != NU_SUCCESS) {
		NU_Close(fd);
		return -1;
	}
	if (NU_Close(fd) != NU_SUCCESS) {
		return -1;
	}
	return 0;
}
