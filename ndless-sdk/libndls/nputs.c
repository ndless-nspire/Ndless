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

/* For internal use only.
 * Synchronous and doesn't require the IRQ to be enabled (actually the IRQ *must* be disabled).
 * But interfers with the OS IRQ handlers when renabled: the OS RS232 out buffer will be entirely
 * retransmitted. */
void nputs(const char *str) {
	volatile unsigned *line_status_reg = (unsigned*)0x90020014;
	volatile unsigned *xmit_holding_reg = (unsigned*)0x90020000;
	while(*str) {
		while(!(*line_status_reg & 0b100000)); // wait for empty xmit holding reg
		*xmit_holding_reg = *str++;
	}
	while(!(*line_status_reg & 0b100000)); // wait for empty xmit holding reg
	*xmit_holding_reg = '\n';
}
