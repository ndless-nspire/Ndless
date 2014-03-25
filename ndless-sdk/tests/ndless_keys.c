/****************************************************************************
 * Key scan test
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
 ****************************************************************************/
 
#include <os.h>

int main(void) {
	TCT_Local_Control_Interrupts(0);
	while (1) {
		wait_key_pressed();
		if (isKeyPressed(KEY_NSPIRE_RET)) puts("KEY_NSPIRE_RET");
		if (isKeyPressed(KEY_NSPIRE_ENTER)) puts("KEY_NSPIRE_ENTER");
		if (isKeyPressed(KEY_NSPIRE_SPACE)) puts("KEY_NSPIRE_SPACE");
		if (isKeyPressed(KEY_NSPIRE_NEGATIVE)) puts("KEY_NSPIRE_NEGATIVE");
		if (isKeyPressed(KEY_NSPIRE_Z)) puts("KEY_NSPIRE_Z");
		if (isKeyPressed(KEY_NSPIRE_PERIOD)) puts("KEY_NSPIRE_PERIOD");
		if (isKeyPressed(KEY_NSPIRE_Y)) puts("KEY_NSPIRE_Y");
		if (isKeyPressed(KEY_NSPIRE_0)) puts("KEY_NSPIRE_0");
		if (isKeyPressed(KEY_NSPIRE_X)) puts("KEY_NSPIRE_X");
		if (isKeyPressed(KEY_NSPIRE_THETA)) puts("KEY_NSPIRE_THETA");
		if (isKeyPressed(KEY_NSPIRE_COMMA)) puts("KEY_NSPIRE_COMMA");
		if (isKeyPressed(KEY_NSPIRE_PLUS)) puts("KEY_NSPIRE_PLUS");
		if (isKeyPressed(KEY_NSPIRE_W)) puts("KEY_NSPIRE_W");
		if (isKeyPressed(KEY_NSPIRE_3)) puts("KEY_NSPIRE_3");
		if (isKeyPressed(KEY_NSPIRE_V)) puts("KEY_NSPIRE_V");
		if (isKeyPressed(KEY_NSPIRE_2)) puts("KEY_NSPIRE_2");
		if (isKeyPressed(KEY_NSPIRE_U)) puts("KEY_NSPIRE_U");
		if (isKeyPressed(KEY_NSPIRE_1)) puts("KEY_NSPIRE_1");
		if (isKeyPressed(KEY_NSPIRE_T)) puts("KEY_NSPIRE_T");
		if (isKeyPressed(KEY_NSPIRE_eEXP)) puts("KEY_NSPIRE_eEXP");
		if (isKeyPressed(KEY_NSPIRE_PI)) puts("KEY_NSPIRE_PI");
		if (isKeyPressed(KEY_NSPIRE_QUES)) puts("KEY_NSPIRE_QUES");
		if (isKeyPressed(KEY_NSPIRE_QUESEXCL)) puts("KEY_NSPIRE_QUESEXCL");
		if (isKeyPressed(KEY_NSPIRE_MINUS)) puts("KEY_NSPIRE_MINUS");
		if (isKeyPressed(KEY_NSPIRE_S)) puts("KEY_NSPIRE_S");
		if (isKeyPressed(KEY_NSPIRE_6)) puts("KEY_NSPIRE_6");
		if (isKeyPressed(KEY_NSPIRE_R)) puts("KEY_NSPIRE_R");
		if (isKeyPressed(KEY_NSPIRE_5)) puts("KEY_NSPIRE_5");
		if (isKeyPressed(KEY_NSPIRE_Q)) puts("KEY_NSPIRE_Q");
		if (isKeyPressed(KEY_NSPIRE_4)) puts("KEY_NSPIRE_4");
		if (isKeyPressed(KEY_NSPIRE_P)) puts("KEY_NSPIRE_P");
		if (isKeyPressed(KEY_NSPIRE_TENX)) puts("KEY_NSPIRE_TENX");
		if (isKeyPressed(KEY_NSPIRE_EE)) puts("KEY_NSPIRE_EE");
		if (isKeyPressed(KEY_NSPIRE_COLON)) puts("KEY_NSPIRE_COLON");
		if (isKeyPressed(KEY_NSPIRE_MULTIPLY)) puts("KEY_NSPIRE_MULTIPLY");
		if (isKeyPressed(KEY_NSPIRE_O)) puts("KEY_NSPIRE_O");
		if (isKeyPressed(KEY_NSPIRE_9)) puts("KEY_NSPIRE_9");
		if (isKeyPressed(KEY_NSPIRE_N)) puts("KEY_NSPIRE_N");
		if (isKeyPressed(KEY_NSPIRE_8)) puts("KEY_NSPIRE_8");
		if (isKeyPressed(KEY_NSPIRE_M)) puts("KEY_NSPIRE_M");
		if (isKeyPressed(KEY_NSPIRE_7)) puts("KEY_NSPIRE_7");
		if (isKeyPressed(KEY_NSPIRE_L)) puts("KEY_NSPIRE_L");
		if (isKeyPressed(KEY_NSPIRE_SQU)) puts("KEY_NSPIRE_SQU");
		if (isKeyPressed(KEY_NSPIRE_II)) puts("KEY_NSPIRE_II");
		if (isKeyPressed(KEY_NSPIRE_QUOTE)) puts("KEY_NSPIRE_QUOTE");
		if (isKeyPressed(KEY_NSPIRE_DIVIDE)) puts("KEY_NSPIRE_DIVIDE");
		if (isKeyPressed(KEY_NSPIRE_K)) puts("KEY_NSPIRE_K");
		if (isKeyPressed(KEY_NSPIRE_TAN)) puts("KEY_NSPIRE_TAN");
		if (isKeyPressed(KEY_NSPIRE_J)) puts("KEY_NSPIRE_J");
		if (isKeyPressed(KEY_NSPIRE_COS)) puts("KEY_NSPIRE_COS");
		if (isKeyPressed(KEY_NSPIRE_I)) puts("KEY_NSPIRE_I");
		if (isKeyPressed(KEY_NSPIRE_SIN)) puts("KEY_NSPIRE_SIN");
		if (isKeyPressed(KEY_NSPIRE_H)) puts("KEY_NSPIRE_H");
		if (isKeyPressed(KEY_NSPIRE_EXP)) puts("KEY_NSPIRE_EXP");
		if (isKeyPressed(KEY_NSPIRE_GTHAN)) puts("KEY_NSPIRE_GTHAN");
		if (isKeyPressed(KEY_NSPIRE_APOSTROPHE)) puts("KEY_NSPIRE_APOSTROPHE");
		if (isKeyPressed(KEY_NSPIRE_CAT)) puts("KEY_NSPIRE_CAT");
		if (isKeyPressed(KEY_NSPIRE_FRAC)) puts("KEY_NSPIRE_FRAC");
		if (isKeyPressed(KEY_NSPIRE_G)) puts("KEY_NSPIRE_G");
		if (isKeyPressed(KEY_NSPIRE_RP)) puts("KEY_NSPIRE_RP");
		if (isKeyPressed(KEY_NSPIRE_F)) puts("KEY_NSPIRE_F");
		if (isKeyPressed(KEY_NSPIRE_LP)) puts("KEY_NSPIRE_LP");
		if (isKeyPressed(KEY_NSPIRE_E)) puts("KEY_NSPIRE_E");
		if (isKeyPressed(KEY_NSPIRE_VAR)) puts("KEY_NSPIRE_VAR");
		if (isKeyPressed(KEY_NSPIRE_D)) puts("KEY_NSPIRE_D");
		if (isKeyPressed(KEY_NSPIRE_DEL)) puts("KEY_NSPIRE_DEL");
		if (isKeyPressed(KEY_NSPIRE_LTHAN)) puts("KEY_NSPIRE_LTHAN");
		if (isKeyPressed(KEY_NSPIRE_FLAG)) puts("KEY_NSPIRE_FLAG");
		if (isKeyPressed(KEY_NSPIRE_CLICK)) puts("KEY_NSPIRE_CLICK");
		if (isKeyPressed(KEY_NSPIRE_C)) puts("KEY_NSPIRE_C");
		if (isKeyPressed(KEY_NSPIRE_HOME)) puts("KEY_NSPIRE_HOME");
		if (isKeyPressed(KEY_NSPIRE_B)) puts("KEY_NSPIRE_B");
		if (isKeyPressed(KEY_NSPIRE_MENU)) puts("KEY_NSPIRE_MENU");
		if (isKeyPressed(KEY_NSPIRE_A)) puts("KEY_NSPIRE_A");
		if (isKeyPressed(KEY_NSPIRE_ESC)) { puts("KEY_NSPIRE_ESC"); return 0; }
		if (isKeyPressed(KEY_NSPIRE_BAR)) puts("KEY_NSPIRE_BAR");
		if (isKeyPressed(KEY_NSPIRE_TAB)) puts("KEY_NSPIRE_TAB");
		if (isKeyPressed(KEY_NSPIRE_EQU)) puts("KEY_NSPIRE_EQU");
		if (isKeyPressed(KEY_NSPIRE_UP)) puts("KEY_NSPIRE_UP");
		if (isKeyPressed(KEY_NSPIRE_UPRIGHT)) puts("KEY_NSPIRE_UPRIGHT");
		if (isKeyPressed(KEY_NSPIRE_RIGHT)) puts("KEY_NSPIRE_RIGHT");
		if (isKeyPressed(KEY_NSPIRE_RIGHTDOWN)) puts("KEY_NSPIRE_RIGHTDOWN");
		if (isKeyPressed(KEY_NSPIRE_DOWN)) puts("KEY_NSPIRE_DOWN");
		if (isKeyPressed(KEY_NSPIRE_DOWNLEFT)) puts("KEY_NSPIRE_DOWNLEFT");
		if (isKeyPressed(KEY_NSPIRE_LEFT)) puts("KEY_NSPIRE_LEFT");
		if (isKeyPressed(KEY_NSPIRE_LEFTUP)) puts("KEY_NSPIRE_LEFTUP");
		if (isKeyPressed(KEY_NSPIRE_SHIFT)) puts("KEY_NSPIRE_SHIFT");
		if (isKeyPressed(KEY_NSPIRE_CTRL)) puts("KEY_NSPIRE_CTRL");
		if (isKeyPressed(KEY_NSPIRE_DOC)) puts("KEY_NSPIRE_DOC");
		if (isKeyPressed(KEY_NSPIRE_TRIG)) puts("KEY_NSPIRE_TRIG");
		if (isKeyPressed(KEY_NSPIRE_SCRATCHPAD)) puts("KEY_NSPIRE_SCRATCHPAD");
		if (on_key_pressed()) puts("ON");
		wait_no_key_pressed();
	}
	return 0;
}
