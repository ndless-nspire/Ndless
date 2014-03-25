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
 * The Initial Developer of the Original Code is Levak
 * Portions created by the Initial Developer are Copyright (C) 2012
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s): 
 ****************************************************************************/
 
/*
  show_1numeric_input allows to invoke a 1 numeric input popup.

  show_1numeric_input compared to _show_1NumericInput avoids 
  manipulations of utf16 strings.
  It returns 1 if OK, 0 if Cancelled

  Values like -1 or 0 for min_values will cancel the popup.
  Otherwise, you can have negative intervals (but not using -1 or 0)

  How to use:
   const char * title = "Title";
   const char * subtitle = "Sub Title";
   const char * msg = "Element";
   int value = 7;
   int result = show_1numeric_input(title, subtitle, msg, &value, 1, 42);
   printf("%d(%s) : %d\n", result, (result == 1)?"OK":"CANCELLED", value); 
*/

#include <os.h>

int show_1numeric_input(const char * title, const char * subtitle, const char * msg, int * value_ref, int min_value, int max_value) {
  char title16[(strlen(title) + 1) * 2];
  char subtitle16[(strlen(subtitle) + 1) * 2];
  char msg16[(strlen(msg) + 1) * 2];
  ascii2utf16(title16, title, sizeof(title16));
  ascii2utf16(subtitle16, subtitle, sizeof(subtitle16));
  ascii2utf16(msg16, msg, sizeof(msg16));
  int cheatMode = 0;
  int real_min_value = min_value;
  if(min_value == 0 || min_value == -1) {
    real_min_value = -2;
    cheatMode = 1;
  }
  int result = (_show_1NumericInput(0, title16, subtitle16, msg16, value_ref, 1, real_min_value, max_value) == 5103);
  if(cheatMode) {
    if(*value_ref < min_value)
      *value_ref = min_value;
  }

  return result;
}
