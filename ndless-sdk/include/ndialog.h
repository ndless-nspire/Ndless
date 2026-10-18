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

#ifndef _NDIALOG_H_
#define _NDIALOG_H_

#include <stdint.h>
#include <dialog.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Types and callbacks */
typedef struct ndialog ndialog_t;
typedef struct ndialog ndialog;

typedef enum {
	NDLG_BTN_SAVE_CANCEL = 0,
	NDLG_BTN_OK_CANCEL,
	NDLG_BTN_OK,
	NDLG_BTN_CLOSE,
	NDLG_BTN_NONE
} ndialog_button_style_t;

typedef ndialog_button_style_t ndialog_button_style;
typedef void (*ndialog_button_callback_t)(void *user_data);
typedef ndialog_button_callback_t ndialog_button_callback;

/* Dialog lifecycle and display */
ndialog_t *ndlg_create(const char *title);
void ndlg_set_button_bar(ndialog_t *dlg, ndialog_button_style_t style);
int ndlg_show(ndialog_t *dlg); /* 1 on OK or save, 0 on cancel / close, -1 on error */
void ndlg_destroy(ndialog_t *dlg);

/* Widgets */
int ndlg_add_label(ndialog_t *dlg, const char *text);
int ndlg_add_separator(ndialog_t *dlg);
int ndlg_add_checkbox(ndialog_t *dlg, const char *label, int *bound_val);
int ndlg_add_combobox(ndialog_t *dlg, const char *label, const char * const items[], int *bound_index);
int ndlg_add_spinbox(ndialog_t *dlg, const char *label, int min, int max, int step, int *bound_val);
int ndlg_add_text_entry(ndialog_t *dlg, const char *label, char *bound_str, int max_len);
int ndlg_add_radio_group(ndialog_t *dlg, const char * const options[], int count, int *bound_index);
int ndlg_add_button(ndialog_t *dlg, const char *label, ndialog_button_callback_t on_click, void *user_data);
int ndlg_add_image(ndialog_t *dlg, const char *ti_image, int w, int h);
int ndlg_add_meter(ndialog_t *dlg, const char *label, int initial_val, int *bound_val);
void ndlg_set_meter_value(ndialog_t *dlg, int *bound_val, int new_val);

/* Layout and hierarchy */
int ndlg_begin_group(ndialog_t *dlg, int layout_id);
int ndlg_end_group(ndialog_t *dlg);
void ndlg_set_padding(ndialog_t *dlg, int top_bottom, int left_right);
int ndlg_get_last_widget(ndialog_t *dlg);

#ifdef __cplusplus
}
#endif

#endif /* _NDIALOG_H_ */
