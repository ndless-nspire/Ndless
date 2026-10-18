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

#include <ndialog.h>
#include <dialog.h>
#include <os.h>
#include <libndls.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

typedef enum {
	ITEM_LABEL,
	ITEM_SEPARATOR,
	ITEM_CHECKBOX,
	ITEM_COMBOBOX,
	ITEM_SPINBOX,
	ITEM_TEXT_ENTRY,
	ITEM_RADIO_GROUP,
	ITEM_BUTTON,
	ITEM_IMAGE,
	ITEM_METER,
	ITEM_GROUP_BEGIN,
	ITEM_GROUP_END
} item_type_t;

typedef struct dialog_item {
	item_type_t type;
	char *label;
	int *bound_val;
	char *bound_str;
	int max_len;
	int min_val;
	int max_val;
	int step_val;
	char **options;
	int option_count;
	ndialog_button_callback_t on_click;
	void *user_data;
	const char *img_data;
	int img_w;
	int img_h;
	int layout_id;
	int pad_tb;
	int pad_lr;
	int ti_handle;
	int *ti_sub_handles;
	struct dialog_item *next;
} dialog_item_t;

struct ndialog {
	char *title;
	ndialog_button_style_t button_style;
	dialog_item_t *items_head;
	dialog_item_t *items_tail;
	int item_count;
	int pad_tb;
	int pad_lr;
	int last_ti_handle;
};

/* Re-entrant modal dialog execution context */
typedef struct dialog_exec_context {
	int ti_dlg;
	ndialog_t *dlg;
	int modal_result;
	struct dialog_exec_context *prev;
} dialog_exec_context_t;

static dialog_exec_context_t *active_context = NULL;

/* Commit control values back to bound pointers */
static void commit_bound_values(ndialog *dlg) {
	if (!dlg)
		return;

	for (dialog_item_t *it = dlg->items_head; it != NULL; it = it->next) {
		if (it->type == ITEM_CHECKBOX && it->bound_val) {
			int st = _ToggleButton_getToggleButtonState(it->ti_handle);
			*it->bound_val = (st == TI_CHECKBOX_ON) ? 1 : 0;
		} else if (it->type == ITEM_COMBOBOX && it->bound_val) {
			*it->bound_val = _ComboBox_getSelectionIndex(it->ti_handle);
		} else if (it->type == ITEM_SPINBOX && it->bound_val) {
			*it->bound_val = TI_DM_getIntegerSpinBoxResult(it->ti_handle);
		} else if (it->type == ITEM_TEXT_ENTRY && it->bound_str && it->max_len > 0) {
			int len = 0;
			uint16_t *u16 = _TextEntry_getTextExpression(it->ti_handle, &len);
			if (u16) {
				int max = it->max_len - 1;
				int j = 0;
				while (u16[j] != 0 && j < max) {
					it->bound_str[j] = (char)(u16[j] & 0xFF);
					j++;
				}
				it->bound_str[j] = '\0';
			}
		} else if (it->type == ITEM_RADIO_GROUP && it->bound_val && it->ti_sub_handles) {
			for (int i = 0; i < it->option_count; i++) {
				if (_ToggleButton_getToggleButtonState(it->ti_sub_handles[i]) == TI_CHECKBOX_ON) {
					*it->bound_val = i;
					break;
				}
			}
		}
	}
}

/* Convert ASCII to UTF-16LE */
static uint16_t *alloc_utf16(const char *str) {
	if (!str)
		return NULL;

	size_t len = strlen(str);
	uint16_t *u16 = (uint16_t *)calloc(len + 1, sizeof(uint16_t));
	if (u16)
		ascii2utf16(u16, str, len + 1);

	return u16;
}

static char *dup_string(const char *s) {
	if (!s)
		return NULL;

	size_t len = strlen(s);
	char *copy = (char *)malloc(len + 1);
	if (copy)
		memcpy(copy, s, len + 1);

	return copy;
}

static void append_item(ndialog *dlg, dialog_item_t *item) {
	if (!dlg || !item)
		return;

	item->next = NULL;
	if (!dlg->items_head) {
		dlg->items_head = item;
		dlg->items_tail = item;
	} else {
		dlg->items_tail->next = item;
		dlg->items_tail = item;
	}
	dlg->item_count++;
}

ndialog *ndlg_create(const char *title) {
	if (!nl_hassyscall(TI_DM_newDialog2)) {
		show_msgbox("Unsupported OS", "Dialogs are not supported on your Ndless revision.");
		return NULL;
	}

	ndialog *dlg = (ndialog *)malloc(sizeof(ndialog));
	if (!dlg)
		return NULL;

	dlg->title = dup_string(title ? title : "Dialog");
	dlg->button_style = NDLG_BTN_SAVE_CANCEL;
	dlg->items_head = NULL;
	dlg->items_tail = NULL;
	dlg->item_count = 0;
	dlg->pad_tb = 3;
	dlg->pad_lr = -1;
	dlg->last_ti_handle = 0;
	return dlg;
}

void ndlg_set_button_bar(ndialog *dlg, ndialog_button_style style) {
	if (dlg)
		dlg->button_style = style;
}

void ndlg_set_padding(ndialog *dlg, int top_bottom, int left_right) {
	if (dlg) {
		dlg->pad_tb = top_bottom;
		dlg->pad_lr = left_right;
	}
}

int ndlg_get_last_widget(ndialog *dlg) {
	return dlg ? dlg->last_ti_handle : 0;
}

int ndlg_begin_group(ndialog *dlg, int layout_id) {
	if (!dlg)
		return -1;

	dialog_item_t *item = (dialog_item_t *)calloc(1, sizeof(dialog_item_t));
	if (!item)
		return -1;

	item->type = ITEM_GROUP_BEGIN;
	item->layout_id = layout_id;
	item->pad_tb = dlg->pad_tb;
	item->pad_lr = dlg->pad_lr;
	append_item(dlg, item);
	return 0;
}

int ndlg_end_group(ndialog *dlg) {
	if (!dlg)
		return -1;

	dialog_item_t *item = (dialog_item_t *)calloc(1, sizeof(dialog_item_t));
	if (!item)
		return -1;

	item->type = ITEM_GROUP_END;
	append_item(dlg, item);
	return 0;
}

int ndlg_add_label(ndialog *dlg, const char *text) {
	if (!dlg)
		return -1;

	dialog_item_t *item = (dialog_item_t *)calloc(1, sizeof(dialog_item_t));
	if (!item)
		return -1;

	item->type = ITEM_LABEL;
	item->label = dup_string(text);
	append_item(dlg, item);
	return 0;
}

int ndlg_add_separator(ndialog *dlg) {
	if (!dlg)
		return -1;

	dialog_item_t *item = (dialog_item_t *)calloc(1, sizeof(dialog_item_t));
	if (!item)
		return -1;

	item->type = ITEM_SEPARATOR;
	append_item(dlg, item);
	return 0;
}

int ndlg_add_checkbox(ndialog *dlg, const char *label, int *bound_val) {
	if (!dlg)
		return -1;

	dialog_item_t *item = (dialog_item_t *)calloc(1, sizeof(dialog_item_t));
	if (!item)
		return -1;

	item->type = ITEM_CHECKBOX;
	item->label = dup_string(label);
	item->bound_val = bound_val;
	append_item(dlg, item);
	return 0;
}

int ndlg_add_combobox(ndialog *dlg, const char *label, const char * const items[], int *bound_index) {
	if (!dlg || !items)
		return -1;

	dialog_item_t *item = (dialog_item_t *)calloc(1, sizeof(dialog_item_t));
	if (!item)
		return -1;

	item->type = ITEM_COMBOBOX;
	item->label = dup_string(label);
	item->bound_val = bound_index;

	int count = 0;
	while (items[count] != NULL)
		count++;

	item->option_count = count;
	item->options = (char **)calloc(count, sizeof(char *));
	if (!item->options && count > 0) {
		if (item->label)
			free(item->label);
		free(item);
		return -1;
	}

	for (int i = 0; i < count; i++)
		item->options[i] = dup_string(items[i]);

	append_item(dlg, item);
	return 0;
}

int ndlg_add_spinbox(ndialog *dlg, const char *label, int min, int max, int step, int *bound_val) {
	if (!dlg)
		return -1;

	dialog_item_t *item = (dialog_item_t *)calloc(1, sizeof(dialog_item_t));
	if (!item)
		return -1;

	item->type = ITEM_SPINBOX;
	item->label = dup_string(label);
	item->min_val = min;
	item->max_val = max;
	item->step_val = step;
	item->bound_val = bound_val;

	append_item(dlg, item);
	return 0;
}

int ndlg_add_text_entry(ndialog *dlg, const char *label, char *bound_str, int max_len) {
	if (!dlg || !bound_str || max_len <= 0)
		return -1;

	dialog_item_t *item = (dialog_item_t *)calloc(1, sizeof(dialog_item_t));
	if (!item)
		return -1;

	item->type = ITEM_TEXT_ENTRY;
	item->label = dup_string(label);
	item->bound_str = bound_str;
	item->max_len = max_len;

	append_item(dlg, item);
	return 0;
}

int ndlg_add_radio_group(ndialog *dlg, const char * const options[], int count, int *bound_index) {
	if (!dlg || !options || count <= 0)
		return -1;

	dialog_item_t *item = (dialog_item_t *)calloc(1, sizeof(dialog_item_t));
	if (!item)
		return -1;

	item->type = ITEM_RADIO_GROUP;
	item->bound_val = bound_index;
	item->option_count = count;
	item->options = (char **)calloc(count, sizeof(char *));
	if (!item->options) {
		free(item);
		return -1;
	}

	for (int i = 0; i < count; i++)
		item->options[i] = dup_string(options[i]);

	append_item(dlg, item);
	return 0;
}

int ndlg_add_button(ndialog *dlg, const char *label, ndialog_button_callback_t on_click, void *user_data) {
	if (!dlg)
		return -1;

	dialog_item_t *item = (dialog_item_t *)calloc(1, sizeof(dialog_item_t));
	if (!item)
		return -1;

	item->type = ITEM_BUTTON;
	item->label = dup_string(label);
	item->on_click = on_click;
	item->user_data = user_data;

	append_item(dlg, item);
	return 0;
}

int ndlg_add_image(ndialog *dlg, const char *ti_image, int w, int h) {
	if (!dlg || !ti_image)
		return -1;

	dialog_item_t *item = (dialog_item_t *)calloc(1, sizeof(dialog_item_t));
	if (!item)
		return -1;

	item->type = ITEM_IMAGE;
	item->img_data = ti_image;
	item->img_w = w;
	item->img_h = h;

	append_item(dlg, item);
	return 0;
}

int ndlg_add_meter(ndialog *dlg, const char *label, int initial_val, int *bound_val) {
	if (!dlg)
		return -1;

	dialog_item_t *item = (dialog_item_t *)calloc(1, sizeof(dialog_item_t));
	if (!item)
		return -1;

	item->type = ITEM_METER;
	item->label = label ? dup_string(label) : NULL;
	if (initial_val < 0)
		initial_val = 0;
	if (initial_val > 100)
		initial_val = 100;
	item->min_val = initial_val;
	item->bound_val = bound_val;
	if (bound_val)
		*bound_val = initial_val;

	append_item(dlg, item);
	return 0;
}

void ndlg_set_meter_value(ndialog *dlg, int *bound_val, int new_val) {
	if (!dlg)
		return;

	if (new_val < 0)
		new_val = 0;
	if (new_val > 100)
		new_val = 100;

	for (dialog_item_t *it = dlg->items_head; it != NULL; it = it->next) {
		if (it->type == ITEM_METER && it->bound_val == bound_val) {
			if (it->bound_val)
				*it->bound_val = new_val;
			it->min_val = new_val;
			if (it->ti_handle && nl_hassyscall(Meter_setValue))
				Meter_setValue(it->ti_handle, new_val);
			break;
		}
	}
}

static int on_action_save(int w __attribute__((unused)), int e __attribute__((unused)), int val) {
	if (val == DLG_BUTTON_PRESS_VAL && active_context && active_context->dlg) {
		active_context->modal_result = 1;
		commit_bound_values(active_context->dlg);
		TI_DM_setVisible(active_context->ti_dlg, 0);
	}

	return 1;
}

static int on_action_cancel(int w __attribute__((unused)), int e __attribute__((unused)), int val) {
	if (val == DLG_BUTTON_PRESS_VAL && active_context) {
		active_context->modal_result = 0;
		TI_DM_setVisible(active_context->ti_dlg, 0);
	}

	return 1;
}

static int on_custom_button_click(int w, int e __attribute__((unused)), int val) {
	if (val == DLG_BUTTON_PRESS_VAL && active_context && active_context->dlg) {
		for (dialog_item_t *it = active_context->dlg->items_head; it != NULL; it = it->next) {
			if (it->type == ITEM_BUTTON && it->ti_handle == w) {
				if (it->on_click)
					it->on_click(it->user_data);
				break;
			}
		}
	}

	return 1;
}

static int get_widget_parent(ndialog *dlg, int current_container, int root) {
	if (current_container != root)
		return current_container;

	int row = TI_DM_newPanel(root, 0);
	TI_DM_setPanelLayout(row, DLG_LAYOUT_SETTINGS_ROW);
	if (dlg->pad_tb >= 0)
		TI_DM_setPanelTBBorder(row, dlg->pad_tb, dlg->pad_tb);
	if (dlg->pad_lr >= 0)
		TI_DM_setPanelLRBorder(row, dlg->pad_lr, dlg->pad_lr);
	return row;
}

int ndlg_show(ndialog *dlg) {
	if (!dlg)
		return -1;

	if (!nl_hassyscall(TI_DM_newDialog2))
		return -1;

	uint16_t *u16_title = alloc_utf16(dlg->title ? dlg->title : "Dialog");
	uint16_t id[] = {0};
	int params[2] = {(int)id, DLG_DIALOG_FLAGS};

	int ti_dlg = TI_DM_newDialog2(0, u16_title, params);
	free(u16_title);

	if (!ti_dlg)
		return -1;

	int root = TI_CA_getContentPane(ti_dlg);
	if (!root) {
		TI_DM_deleteDialog(ti_dlg);
		return -1;
	}

	dialog_exec_context_t ctx;
	ctx.ti_dlg = ti_dlg;
	ctx.dlg = dlg;
	ctx.modal_result = 0;
	ctx.prev = active_context;
	active_context = &ctx;

	/* Container stack for nested groups and panels */
	int container_stack[16];
	int container_sp = 0;
	container_stack[0] = root;

	/* Track combobox allocations */
	int **combo_u16_ptrs = (int **)calloc(dlg->item_count + 1, sizeof(int *));
	int combo_count = 0;

	/* Construct widgets */
	for (dialog_item_t *it = dlg->items_head; it != NULL; it = it->next) {
		switch (it->type) {
			case ITEM_GROUP_BEGIN: {
				int target = container_stack[container_sp];
				int grp = TI_DM_newPanel(target, 0);
				TI_DM_setPanelLayout(grp, it->layout_id);
				if (it->pad_tb >= 0)
					TI_DM_setPanelTBBorder(grp, it->pad_tb, it->pad_tb);
				if (it->pad_lr >= 0)
					TI_DM_setPanelLRBorder(grp, it->pad_lr, it->pad_lr);
				if (container_sp < 15)
					container_stack[++container_sp] = grp;
				dlg->last_ti_handle = grp;
				break;
			}
			case ITEM_GROUP_END: {
				if (container_sp > 0)
					container_sp--;
				break;
			}
			case ITEM_LABEL: {
				int parent = get_widget_parent(dlg, container_stack[container_sp], root);
				uint16_t *u_text = alloc_utf16(it->label ? it->label : "");
				int lbl = TI_DM_addLabel(parent, u_text, 0, 0, 0, DLG_LABEL_STYLE, DLG_LABEL_WRAP);
				free(u_text);
				TI_DM_groupControlWithLabel(parent, lbl, 0);
				it->ti_handle = lbl;
				dlg->last_ti_handle = lbl;
				break;
			}
			case ITEM_SEPARATOR: {
				int target = container_stack[container_sp];
				TI_DM_addSeparatorLine(target);
				break;
			}
			case ITEM_CHECKBOX: {
				int parent = get_widget_parent(dlg, container_stack[container_sp], root);
				uint16_t *u_lbl = alloc_utf16(it->label ? it->label : "");
				int chk = TI_DM_addCheckBox(parent, DLG_CHECKBOX_WIDGET_ID, u_lbl);
				free(u_lbl);

				int st = (it->bound_val && *it->bound_val) ? TI_CHECKBOX_ON : TI_CHECKBOX_OFF;
				_ToggleButton_setToggleButtonState(chk, st);
				TI_DM_groupControlWithLabel(parent, chk, 0);
				it->ti_handle = chk;
				dlg->last_ti_handle = chk;
				break;
			}
			case ITEM_COMBOBOX: {
				int parent = get_widget_parent(dlg, container_stack[container_sp], root);
				uint16_t *u_lbl = alloc_utf16(it->label ? it->label : "");
				int lbl = TI_DM_addLabel(parent, u_lbl, 0, 0, 0, DLG_LABEL_STYLE, DLG_LABEL_WRAP);
				free(u_lbl);
				int *u16_items = (int *)calloc(it->option_count + 1, sizeof(int));
				for (int i = 0; i < it->option_count; i++)
					u16_items[i] = (int)alloc_utf16(it->options[i]);

				u16_items[it->option_count] = 0;
				if (combo_u16_ptrs)
					combo_u16_ptrs[combo_count++] = u16_items;
				int cmb = TI_DM_addComboBox(parent, DLG_COMBO_MAIN, (int)u16_items, DLG_COMBO_FOCUS, DLG_COMBO_STACK, 0, 0);
				if (it->bound_val && *it->bound_val >= 0 && *it->bound_val < it->option_count)
					ComboBox_setSelectedItem(cmb, *it->bound_val);

				TI_DM_groupControlWithLabel(parent, lbl, cmb);
				it->ti_handle = cmb;
				dlg->last_ti_handle = cmb;
				break;
			}
			case ITEM_SPINBOX: {
				int parent = get_widget_parent(dlg, container_stack[container_sp], root);
				uint16_t *u_lbl = alloc_utf16(it->label ? it->label : "");
				int lbl = TI_DM_addLabel(parent, u_lbl, 0, 0, 0, DLG_LABEL_STYLE, DLG_LABEL_WRAP);
				free(u_lbl);
				int min_val = (it->min_val >= 1) ? it->min_val : 1;
				int cur_val = it->bound_val ? *it->bound_val : min_val;
				if (cur_val < min_val)
					cur_val = min_val;
				if (cur_val > it->max_val)
					cur_val = it->max_val;
				int spin = TI_DM_addIntegerSpinBox(parent, cur_val, min_val, it->max_val, 0, DLG_LABEL_STYLE, DLG_COMBO_STACK, 0, 0);
				TI_DM_groupControlWithLabel(parent, lbl, spin);
				it->ti_handle = spin;
				dlg->last_ti_handle = spin;
				break;
			}
			case ITEM_TEXT_ENTRY: {
				int parent = get_widget_parent(dlg, container_stack[container_sp], root);
				uint16_t *u_lbl = alloc_utf16(it->label ? it->label : "");
				int lbl = TI_DM_addLabel(parent, u_lbl, 0, 0, 0, DLG_LABEL_STYLE, DLG_LABEL_WRAP);
				free(u_lbl);
				int txt = TI_DM_addTextEntry(parent, 80001, 78001, 79003, 0, 0);
				if (it->bound_str) {
					uint16_t *u_val = alloc_utf16(it->bound_str);
					TextEntry_setTextExpression(txt, (const char *)u_val, 0);
					free(u_val);
				}
				TI_DM_groupControlWithLabel(parent, lbl, txt);
				it->ti_handle = txt;
				dlg->last_ti_handle = txt;
				break;
			}
			case ITEM_RADIO_GROUP: {
				if (nl_hassyscall(TI_DM_AddButtonGroup) && nl_hassyscall(TI_DM_addRadioButton)) {
					int target = container_stack[container_sp];
					int sec = (target != root) ? target : TI_DM_newPanel(root, 0);
					if (target == root) {
						TI_DM_setPanelLayout(sec, DLG_LAYOUT_SETTINGS_ROW);
						TI_DM_setPanelLRBorder(sec, 4, 4);
						TI_DM_setPanelTBBorder(sec, 0, 0);
					}

					/* Button group with mutual exclusion */
					int grp = TI_DM_AddButtonGroup(ti_dlg, 2);
					it->ti_sub_handles = (int *)calloc(it->option_count, sizeof(int));
					int sel_idx = (it->bound_val && *it->bound_val >= 0 && *it->bound_val < it->option_count) ? *it->bound_val : 0;
					for (int i = 0; i < it->option_count; i++) {
						uint16_t *u_opt = alloc_utf16(it->options[i]);
						int rb = TI_DM_addRadioButton(sec, DLG_CHECKBOX_WIDGET_ID, u_opt);
						free(u_opt);
						if (it->ti_sub_handles)
							it->ti_sub_handles[i] = rb;
						int is_sel = (sel_idx == i) ? 1 : 0;
						if (nl_hassyscall(TI_DM_ButtonGroupAdd))
							TI_DM_ButtonGroupAdd(grp, rb, is_sel);
					}
					for (int i = 0; i < it->option_count; i++) {
						if (nl_hassyscall(TI_DM_groupControlWithLabel) && it->ti_sub_handles)
							TI_DM_groupControlWithLabel(sec, it->ti_sub_handles[i], 0);
					}
					dlg->last_ti_handle = sec;
				}
				break;
			}
			case ITEM_BUTTON: {
				int parent = get_widget_parent(dlg, container_stack[container_sp], root);
				uint16_t *u_lbl = alloc_utf16(it->label ? it->label : "Button");
				if (nl_hassyscall(TI_DM_addButton)) {
					int btn = TI_DM_addButton(parent, u_lbl, 0, 0, 0, DLG_BUTTON_FLAGS, DLG_BUTTON_FLAGS2, 0, (int)on_custom_button_click);
					if (nl_hassyscall(TI_DM_groupControlWithLabel))
						TI_DM_groupControlWithLabel(parent, btn, 0);
					it->ti_handle = btn;
					dlg->last_ti_handle = btn;
				}
				free(u_lbl);
				break;
			}
			case ITEM_IMAGE: {
				int target = container_stack[container_sp];
				int pnl = (target != root) ? target : TI_DM_newPanel(root, 0);
				if (target == root) {
					TI_DM_setPanelLayout(pnl, DLG_LAYOUT_FLOW);
				}
				int w = it->img_w > 0 ? it->img_w : (int)*(const uint32_t *)it->img_data;
				int h = it->img_h > 0 ? it->img_h : (int)*((const uint32_t *)it->img_data + 1);
				char spaces[64];
				int space_count = (w / 6) + 4;
				if (space_count > 60)
					space_count = 60;
				memset(spaces, ' ', space_count);
				spaces[space_count] = '\0';
				uint16_t *u_blank = alloc_utf16(spaces);
				int lbl = TI_DM_addLabel(pnl, u_blank, 0, 0, 0, DLG_LABEL_STYLE, DLG_LABEL_WRAP);
				free(u_blank);
				dm_draw_image(lbl, it->img_data, w, h);
				if (nl_hassyscall(TI_DM_groupControlWithLabel))
					TI_DM_groupControlWithLabel(pnl, lbl, 0);
				it->ti_handle = lbl;
				dlg->last_ti_handle = lbl;
				break;
			}
			case ITEM_METER: {
				int parent = get_widget_parent(dlg, container_stack[container_sp], root);
				if (it->label && strlen(it->label) > 0) {
					uint16_t *u_lbl = alloc_utf16(it->label);
					TI_DM_addLabel(parent, u_lbl, 0, 0, 0, DLG_LABEL_STYLE, DLG_LABEL_WRAP);
					free(u_lbl);
				}
				int val = it->bound_val ? *it->bound_val : it->min_val;
				if (val < 0)
					val = 0;
				if (val > 100)
					val = 100;
				if (nl_hassyscall(TI_DM_addMeter)) {
					int meter = TI_DM_addMeter(parent, DLG_METER_STYLE, DLG_METER_FLAGS, val);
					it->ti_handle = meter;
					dlg->last_ti_handle = meter;
				}
				break;
			}
		}
	}

	/* Action button bar */
	int initial_focus = 0;
	int escape_btn = 0;
	if (dlg->button_style != NDLG_BTN_NONE) {
		TI_DM_addSeparatorLine(root);
		int bar = TI_DM_newPanel(root, 0);
		TI_DM_setPanelLayout(bar, DLG_LAYOUT_BUTTON_BAR);

		if (dlg->button_style == NDLG_BTN_SAVE_CANCEL) {
			int b_save = TI_DM_addButton(bar, NULL, DLG_GLYPH_SAVE, DLG_RES_SYST, 0, DLG_BUTTON_FLAGS, DLG_BUTTON_FLAGS2, 0, (int)on_action_save);
			int b_canc = TI_DM_addButton(bar, NULL, DLG_GLYPH_CANCEL, DLG_RES_SYST, 0, DLG_BUTTON_FLAGS, DLG_BUTTON_FLAGS2, 0, (int)on_action_cancel);
			TI_DM_groupControlWithLabel(bar, b_save, b_canc);
			initial_focus = b_save;
			escape_btn = b_canc;
		} else if (dlg->button_style == NDLG_BTN_OK_CANCEL) {
			uint16_t *u_ok = alloc_utf16("OK");
			int b_ok = TI_DM_addButton(bar, u_ok, 0, 0, 0, DLG_BUTTON_FLAGS, DLG_BUTTON_FLAGS2, 0, (int)on_action_save);
			free(u_ok);
			uint16_t *u_canc = alloc_utf16("Cancel");
			int b_canc = TI_DM_addButton(bar, u_canc, 0, 0, 0, DLG_BUTTON_FLAGS, DLG_BUTTON_FLAGS2, 0, (int)on_action_cancel);
			free(u_canc);
			TI_DM_groupControlWithLabel(bar, b_ok, b_canc);
			initial_focus = b_ok;
			escape_btn = b_canc;
		} else if (dlg->button_style == NDLG_BTN_OK) {
			uint16_t *u_ok = alloc_utf16("OK");
			int b_ok = TI_DM_addButton(bar, u_ok, 0, 0, 0, DLG_BUTTON_FLAGS, DLG_BUTTON_FLAGS2, 0, (int)on_action_save);
			free(u_ok);
			TI_DM_groupControlWithLabel(bar, b_ok, 0);
			initial_focus = b_ok;
			escape_btn = b_ok;
		} else if (dlg->button_style == NDLG_BTN_CLOSE) {
			uint16_t *u_close = alloc_utf16("Close");
			int b_close = TI_DM_addButton(bar, u_close, 0, 0, 0, DLG_BUTTON_FLAGS, DLG_BUTTON_FLAGS2, 0, (int)on_action_cancel);
			free(u_close);
			TI_DM_groupControlWithLabel(bar, b_close, 0);
			initial_focus = b_close;
			escape_btn = b_close;
		}

		if (escape_btn && nl_hassyscall(TI_DM_setEscapeButton))
			TI_DM_setEscapeButton(ti_dlg, escape_btn);

		if (initial_focus && nl_hassyscall(TI_DM_setInitialFocusComponent))
			TI_DM_setInitialFocusComponent(ti_dlg, initial_focus);
	}

	/* Modal execution */
	TI_DM_setVisible(ti_dlg, 1);

	/* Free temporary combobox allocations */
	if (combo_u16_ptrs) {
		for (int i = 0; i < combo_count; i++) {
			int *arr = combo_u16_ptrs[i];
			if (arr) {
				int k = 0;
				while (arr[k] != 0) {
					free((void *)arr[k]);
					k++;
				}
				free(arr);
			}
		}
		free(combo_u16_ptrs);
	}

	/* Destroy native dialog and free canvases */
	TI_DM_deleteDialog(ti_dlg);
	dm_free_canvases();

	int result = ctx.modal_result;
	active_context = ctx.prev;
	return result;
}

void ndlg_destroy(ndialog *dlg) {
	if (!dlg)
		return;

	dialog_item_t *curr = dlg->items_head;
	while (curr) {
		dialog_item_t *next = curr->next;
		if (curr->label)
			free(curr->label);
		if (curr->options) {
			for (int i = 0; i < curr->option_count; i++) {
				if (curr->options[i])
					free(curr->options[i]);
			}
			free(curr->options);
		}
		if (curr->ti_sub_handles)
			free(curr->ti_sub_handles);

		free(curr);
		curr = next;
	}

	if (dlg->title)
		free(dlg->title);

	free(dlg);
}
