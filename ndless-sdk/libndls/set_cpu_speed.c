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
 * Portions created by the Initial Developer are Copyright (C) 2010
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s): 
 ****************************************************************************/

#include <os.h>

/* speed is one of CPU_SPEED_* */
unsigned set_cpu_speed(unsigned speed) {
  if(is_cx2) // Not sure whether it's worth it to implement that
    return 0;

  unsigned previous_speed = *(volatile unsigned*)0x900B0000;
  *(volatile unsigned*)0x900B0000 = speed;
  *(volatile unsigned*)0x900B000C = 4;
  return previous_speed;
}
