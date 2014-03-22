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
 * Portions created by the Initial Developer are Copyright (C) 2012
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s): 
 ****************************************************************************/

#include <os.h>

static unsigned __is_touchpad = 0xFFFFFFFF;

BOOL _is_touchpad(void) {
	if (__is_touchpad == 0xFFFFFFFF) {
		unsigned char *_keypad_type = keypad_type;
		__is_touchpad = (*_keypad_type == 3 /* prototype */ || *_keypad_type == 4 /* normal */);
	}
	return  (BOOL)__is_touchpad;
}
