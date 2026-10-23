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

#include <dialog.h>
#include <libndls.h>
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdlib.h>

#define EVENT_PAINT 0x49

typedef int (*event_handler_t)(void *, void *);

typedef struct canvas_state {
	uint32_t vtable[32];
	event_handler_t orig_event_handler;
	const char *img_data;
	struct canvas_state *next;
} canvas_state_t;

static canvas_state_t *g_canvas_list_head = NULL;

static int canvas_paint_hook(void *widget, void *event) {
	if (!event || ((uintptr_t)event & 3) != 0)
		return 0;

	uint32_t *vt_ptr = *(uint32_t **)widget;
	canvas_state_t *state = (canvas_state_t *)vt_ptr;

	unsigned char event_id = *(unsigned char *)event;

	int result = state->orig_event_handler(widget, event);
	if (event_id == EVENT_PAINT && state->img_data) {
		void *gc = *(void **)((uint32_t)event + 0xC);
		if (gc)
			gui_gc_drawImage(gc, (char *)state->img_data, 0, 0);
	}

	return result;
}

void dm_draw_image(int widget, const char *img_data, int w, int h) {
	if (!img_data)
		return;

	if (w <= 0 || h <= 0) {
		w = (int)*(const uint32_t *)img_data;
		h = (int)*((const uint32_t *)img_data + 1);
	}

	if (nl_hassyscall(UiComponent_setMinSize))
		UiComponent_setMinSize(widget, w, h);

	if (nl_hassyscall(UiComponent_setPreferredSize))
		UiComponent_setPreferredSize(widget, w, h);

	uint32_t *raw = (uint32_t *)widget;
	uint32_t *orig_vt = (uint32_t *)raw[0];

	canvas_state_t *state = (canvas_state_t *)malloc(sizeof(canvas_state_t));
	if (!state)
		return;

	memcpy(state->vtable, orig_vt, 32 * sizeof(uint32_t));
	state->orig_event_handler = (event_handler_t)orig_vt[1];
	state->img_data = img_data;
	state->vtable[1] = (uint32_t)&canvas_paint_hook;
	raw[0] = (uint32_t)state;
	state->next = g_canvas_list_head;
	g_canvas_list_head = state;
}

void dm_free_canvases(void) {
	canvas_state_t *curr = g_canvas_list_head;
	while (curr) {
		canvas_state_t *next = curr->next;
		free(curr);
		curr = next;
	}
	g_canvas_list_head = NULL;
}
