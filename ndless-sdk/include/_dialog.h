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
 * The Initial Developer of the Original Code is Delta.
 * Portions created by the Initial Developer are Copyright (C) 2026
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 ****************************************************************************/

#ifndef _DIALOG_H_
#define _DIALOG_H_

#include <os.h>

#ifdef __cplusplus
extern "C" {
#endif

void dm_draw_image(int widget, const char *img_data, int w, int h);
void dm_free_canvases(void);

#define DLG_LAYOUT_BUTTON_BAR   0x128E3
#define DLG_LAYOUT_FLOW         0x128E4
#define DLG_LAYOUT_SETTINGS_ROW 0x128E9
#define DLG_LAYOUT_FLOW_H       0x128EC
#define DLG_LAYOUT_BUTTON_VERT  0x128EF
#define DLG_LABEL_STYLE         0x130B1
#define DLG_LABEL_WRAP          0x13499
#define DLG_COMBO_MAIN          0x13882
#define DLG_COMBO_FOCUS         0x130B2
#define DLG_COMBO_STACK         0x1349B
#define DLG_METER_STYLE         0x130B3
#define DLG_METER_FLAGS         0x13499
#define DLG_CHECKBOX_WIDGET_ID  0x153D9
#define DLG_CHECKBOX_ON          0x13C69
#define DLG_CHECKBOX_OFF         0x13C6A
#define DLG_BUTTON_PRESS_VAL    0x14C0B
#define DLG_BUTTON_FLAGS        78002
#define DLG_BUTTON_FLAGS2       79003
#define DLG_DIALOG_FLAGS        72001
#define DLG_GLYPH_SAVE          0x53
#define DLG_GLYPH_CANCEL        0xF3
#define DLG_RES_SYST            0x73797374

#ifdef __cplusplus
}
#endif

#endif /* _DIALOG_H_ */
