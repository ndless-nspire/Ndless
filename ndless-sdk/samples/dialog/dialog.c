#include <os.h>
#include <libndls.h>
#include <ndialog.h>
#include <stdio.h>
#include <string.h>
#include "icon.h"

typedef struct {
	char text[32];
	int checkbox_val;
	int combo_val;
	int spin_val;
	int radio_val;
	int meter_val;
} app_state_t;

typedef struct {
	ndialog_t *dlg;
	int *val;
} meter_ctx_t;

static void on_step_meter(void *user_data) {
	meter_ctx_t *ctx = (meter_ctx_t *)user_data;
	if (!ctx || !ctx->dlg || !ctx->val)
		return;

	*ctx->val = (*ctx->val + 25) % 125;
	if (*ctx->val > 100)
		*ctx->val = 0;

	ndlg_set_meter_value(ctx->dlg, ctx->val, *ctx->val);
}

static void on_button_clicked(void *user_data __attribute__((unused))) {
	show_msgbox("Message", "button clicked!");
}

/* Text entry and checkbox */
static int show_page_1(app_state_t *state) {
	ndialog_t *dlg = ndlg_create("Page 1");
	if (!dlg)
		return -1;

	ndlg_add_text_entry(dlg, "text", state->text, sizeof(state->text));
	ndlg_add_separator(dlg);
	ndlg_add_checkbox(dlg, "checkbox", &state->checkbox_val);

	ndlg_set_button_bar(dlg, NDLG_BTN_OK_CANCEL);
	int res = ndlg_show(dlg);
	ndlg_destroy(dlg);
	return res;
}

/* Combobox and spinbox */
static int show_page_2(app_state_t *state) {
	ndialog_t *dlg = ndlg_create("Page 2");
	if (!dlg)
		return -1;

	const char *combo_options[] = {
		"option 1",
		"option 2",
		"option 3",
		NULL
	};

	ndlg_add_combobox(dlg, "combobox", combo_options, &state->combo_val);
	ndlg_add_separator(dlg);
	ndlg_add_spinbox(dlg, "spinbox", 1, 10, 1, &state->spin_val);

	ndlg_set_button_bar(dlg, NDLG_BTN_OK_CANCEL);
	int res = ndlg_show(dlg);
	ndlg_destroy(dlg);
	return res;
}

/* Image */
static int show_page_3(void) {
	ndialog_t *dlg = ndlg_create("Page 3");
	if (!dlg)
		return -1;

	ndlg_add_image(dlg, (const char *)ndless_icon_data, 0, 0);
	ndlg_add_separator(dlg);
	ndlg_add_label(dlg, "Ndless is the best!");

	ndlg_set_button_bar(dlg, NDLG_BTN_OK_CANCEL);
	int res = ndlg_show(dlg);
	ndlg_destroy(dlg);
	return res;
}

/* Radio buttons */
static int show_page_4(app_state_t *state) {
	ndialog_t *dlg = ndlg_create("Page 4");
	if (!dlg)
		return -1;

	const char *radio_options[] = {
		"option 1",
		"option 2",
		"option 3"
	};

	ndlg_add_label(dlg, "radio group");
	ndlg_add_radio_group(dlg, radio_options, 3, &state->radio_val);
	ndlg_add_separator(dlg);
	ndlg_add_button(dlg, "show message", on_button_clicked, NULL);

	ndlg_set_button_bar(dlg, NDLG_BTN_OK_CANCEL);
	int res = ndlg_show(dlg);
	ndlg_destroy(dlg);
	return res;
}

/* Step, meter */
static int show_page_5(app_state_t *state) {
	ndialog_t *dlg = ndlg_create("Page 5");
	if (!dlg)
		return -1;

	ndlg_add_meter(dlg, "meter", state->meter_val, &state->meter_val);
	meter_ctx_t ctx = { .dlg = dlg, .val = &state->meter_val };
	ndlg_add_button(dlg, "step meter (+25%)", on_step_meter, &ctx);

	ndlg_set_button_bar(dlg, NDLG_BTN_SAVE_CANCEL);
	int res = ndlg_show(dlg);
	ndlg_destroy(dlg);
	return res;
}

/* Summary */
static void show_page_6(const app_state_t *state) {
	ndialog_t *dlg = ndlg_create("Summary");
	if (!dlg)
		return;

	char line1[64], line2[64], line3[64];
	snprintf(line1, sizeof(line1), "text: %s | checkbox: %d", state->text, state->checkbox_val);
	snprintf(line2, sizeof(line2), "combobox: %d | spinbox: %d", state->combo_val, state->spin_val);
	snprintf(line3, sizeof(line3), "radio: %d | meter: %d%%", state->radio_val, state->meter_val);

	ndlg_add_label(dlg, "results");
	ndlg_add_separator(dlg);
	ndlg_add_label(dlg, line1);
	ndlg_add_label(dlg, line2);
	ndlg_add_label(dlg, line3);

	ndlg_set_button_bar(dlg, NDLG_BTN_OK);
	ndlg_show(dlg);
	ndlg_destroy(dlg);
}

int main(void) {
	app_state_t state = {
		.text = "hello",
		.checkbox_val = 1,
		.combo_val = 0,
		.spin_val = 5,
		.radio_val = 1,
		.meter_val = 50
	};

	if (show_page_1(&state) <= 0)
		return 0;

	if (show_page_2(&state) <= 0)
		return 0;

	if (show_page_3() <= 0)
		return 0;

	if (show_page_4(&state) <= 0)
		return 0;

	if (show_page_5(&state) <= 0)
		return 0;

	show_page_6(&state);
	return 0;
}
