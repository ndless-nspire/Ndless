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
 * Portions created by the Initial Developer are Copyright (C) 2010-2011
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s): 
 ****************************************************************************/

#include <os.h>

unsigned _show_msgbox(const char *title, const char *msg, unsigned button_num, ...) {
	__builtin_va_list ap;
	char title16[(strlen(title) + 1) * 2];
	char msg16[(strlen(msg) + 1) * 2];
	const char *dlg[] = {"DLG", NULL};
	unsigned button_pressed = 0;
	__builtin_va_start(ap, button_num);
	
	ascii2utf16(title16, title, sizeof(title16));
	ascii2utf16(msg16, msg, sizeof(msg16));
	BOOL incolor = lcd_isincolor();
	void *saved_screen = NULL;
	if (has_colors && !incolor) {
		if ((saved_screen = malloc(SCREEN_WIDTH * SCREEN_HEIGHT * 2))) {
			// The screen buffer size of the color mode is used, but before switching to it
			memcpy(saved_screen, (void*) REAL_SCREEN_BASE_ADDRESS, SCREEN_WIDTH * SCREEN_HEIGHT * 2);
			memset((void*) REAL_SCREEN_BASE_ADDRESS, 0xFF, SCREEN_WIDTH * SCREEN_HEIGHT * 2); // clrscr. avoid displaying a grayscaled buffer in colors
		}
		lcd_incolor();
	}
	/* required since OS 2.1 for OS key scan */
	int orig_mask = TCT_Local_Control_Interrupts(0);
	if (button_num == 2 || button_num == 3) {
		char *button1 = __builtin_va_arg(ap, char*);
		char *button2 = __builtin_va_arg(ap, char*);
		char button1_16[(strlen(button1) + 1) * 2];
		char button2_16[(strlen(button2) + 1) * 2];
		ascii2utf16(button1_16, button1, sizeof(button1_16));
		ascii2utf16(button2_16, button2, sizeof(button2_16));
		if (button_num == 2) {
			button_pressed = _show_msgbox_2b(0, title16, msg16, button1_16, 1, button2_16, 2, dlg);
		} else {
			char *button3 = __builtin_va_arg(ap, char*);
			char button3_16[(strlen(button3) + 1) * 2];
			ascii2utf16(button3_16, button3, sizeof(button3_16));
			button_pressed = _show_msgbox_3b(0, title16, msg16, button1_16, 1, button2_16, 2, button3_16, 3, dlg);
		}
	} else {
		show_dialog_box2_(0, title16, msg16, dlg);
	}
	TCT_Local_Control_Interrupts(orig_mask);
	if (has_colors && !incolor) {
		if (saved_screen) {
			memset((void*) REAL_SCREEN_BASE_ADDRESS, 0xFF, SCREEN_WIDTH * SCREEN_HEIGHT * 2); // clrscr. avoid displaying a color buffer in greyscale
			lcd_ingray();
			memcpy((void*) REAL_SCREEN_BASE_ADDRESS, saved_screen, SCREEN_WIDTH * SCREEN_HEIGHT * 2); // the OS may redraw the screen in colors, but it is grayscale. Avoid garbage.
			free(saved_screen);
		} else {
			lcd_ingray();
		}
	}
	__builtin_va_end(ap);
	return button_pressed;
}
