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

#include <os.h>

/* For internal use only since it depends on the internal function nputs().
 * synchronous and doesn't require the IRQ to be enabled (actually the IRQ *must* be disabled)
 * TODO: nputs() shouldn't be used since it outputs '\n'. */
void nprintf(const char *fmt, ...) {
	char sbuf[500];
	va_list vl;
	va_start(vl, fmt);
	// TODO use vnsprintf
	vsprintf(sbuf, fmt, vl);
  va_end(vl);
	nputs(sbuf);
}
