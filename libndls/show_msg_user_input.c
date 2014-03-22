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
  show_msg_user_input allows to invoke a Request popup.

  show_msg_user_input compared to _show_msgUserInput avoids
  manipulations of utf16 strings.
  It initializes a new char array and returns its size or -1 if Cancelled or
  emtpy input.

  How to use:
   const char * title = "Title";
   const char * msg = "Element";
   char * defaultvalue = "default value";
   char * value;
   unsigned len = show_msg_user_input(title, msg, defaultvalue, &value);
   printf("%s (%d)\n", value, len);
   free(value);
*/

#include <os.h>

int show_msg_user_input(const char * title, const char * msg, char * defaultvalue, char ** value_ref) {

	unsigned len_input = strlen(defaultvalue);
	String request_value = string_new();
	String s_title = string_new();	
	String s_msg = string_new();	
	string_set_ascii(request_value, defaultvalue);	
	string_set_ascii(s_title, title);	
	string_set_ascii(s_msg, msg);	
	String request_struct[] = {s_msg, request_value};	

	int no_error = _show_msgUserInput(0, request_struct, s_title->str, s_msg->str);
	unsigned len_out = (no_error) ? request_value->len : 0;	
	string_free(s_title);	
	string_free(s_msg);

	if(no_error && len_out > 0) {
		char * t = string_to_ascii(request_value);
		*value_ref = malloc(sizeof(char)*(len_out+1));
		strncpy(*value_ref, t, len_out);
		(*value_ref)[len_out] = 0;
		string_free(request_value);
		return len_out;
	}
	else {
		string_free(request_value);
		return -1;
	}
}	
