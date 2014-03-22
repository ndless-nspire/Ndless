#include <string.h>
#include "emu.h"

/* DC000000: Interrupt controller */
struct interrupt_state intr;

static void get_current_int(int is_fiq, int *current) {
	u32 masked_status = intr.status & intr.mask[is_fiq];
	int pri_limit = intr.priority_limit[is_fiq];
	int i;
	for (i = 0; i < 32; i++) {
		if (masked_status & (1 << i) && intr.priority[i] < pri_limit) {
			*current = i;
			pri_limit = intr.priority[i];
		}
	}
}

static void update() {
	u32 prev_raw_status = intr.raw_status;
	intr.raw_status = intr.active ^ ~intr.noninverted;

	intr.sticky_status |= (intr.raw_status & ~prev_raw_status);
	intr.status = (intr.raw_status    & ~intr.sticky)
	            | (intr.sticky_status &  intr.sticky);

	int is_fiq;
	for (is_fiq = 0; is_fiq < 2; is_fiq++) {
		int i = -1;
		get_current_int(is_fiq, &i);
		if (i >= 0) {
			arm.interrupts |= 0x80 >> is_fiq;
			cpu_int_check();
		}
	}
}

u32 int_read_word(u32 addr) {
	int group = addr >> 8 & 3;
	if (group < 2) {
		int is_fiq = group;
		int current = 0;
		switch (addr & 0xFF) {
			case 0x00:
				return intr.status & intr.mask[is_fiq];
			case 0x04:
				return intr.status;
			case 0x08:
			case 0x0C:
				return intr.mask[is_fiq];
			case 0x20:
				get_current_int(is_fiq, &current);
				return current;
			case 0x24:
				get_current_int(is_fiq, &current);
				intr.prev_pri_limit[is_fiq] = intr.priority_limit[is_fiq];
				intr.priority_limit[is_fiq] = intr.priority[current];
				return current;
			case 0x28:
				current = -1;
				get_current_int(is_fiq, &current);
				if (current < 0) {
					arm.interrupts &= ~(0x80 >> is_fiq);
					cpu_int_check();
				}
				return intr.prev_pri_limit[is_fiq];
			case 0x2C:
				return intr.priority_limit[is_fiq];
		}
	} else if (group == 2) {
		switch (addr & 0xFF) {
			case 0x00: return intr.noninverted;
			case 0x04: return intr.sticky;
			case 0x08: return 0;
		}
	} else {
		if (!(addr & 0x80))
			return intr.priority[addr >> 2 & 0x1F];
	}
	return bad_read_word(addr);
}
void int_write_word(u32 addr, u32 value) {
	int group = addr >> 8 & 3;
	if (group < 2) {
		int is_fiq = group;
		switch (addr & 0xFF) {
			case 0x04: intr.sticky_status &= ~value; update(); return;
			case 0x08: intr.mask[is_fiq] |= value; update(); return;
			case 0x0C: intr.mask[is_fiq] &= ~value; update(); return;
			case 0x2C: intr.priority_limit[is_fiq] = value & 0x0F; update(); return;
		}
	} else if (group == 2) {
		switch (addr & 0xFF) {
			case 0x00: intr.noninverted = value; update(); return;
			case 0x04: intr.sticky = value; update(); return;
			case 0x08: return;
		}
	} else {
		if (!(addr & 0x80)) {
			intr.priority[addr >> 2 & 0x1F] = value & 7;
			return;
		}
	}
	return bad_write_word(addr, value);
}

static void update_cx() {
	if (intr.active & intr.mask[0] & ~intr.mask[1])
		arm.interrupts |= 0x80;
	else
		arm.interrupts &= ~0x80;
	if (intr.active & intr.mask[0] & intr.mask[1])
		arm.interrupts |= 0x40;
	else
		arm.interrupts &= ~0x40;
	cpu_int_check();
}

u32 int_cx_read_word(u32 addr) {
	switch (addr & 0x3FFFFFF) {
		case 0x000: return intr.active & intr.mask[0] & ~intr.mask[1];
		case 0x004: return intr.active & intr.mask[0] & intr.mask[1];
		case 0x008: return intr.active;
		case 0x00C: return intr.mask[1];
		case 0x010: return intr.mask[0];
		case 0xFE0: return 0x90;
		case 0xFE4: return 0x11;
		case 0xFE8: return 0x04;
		case 0xFEC: return 0x00;
	}
	return bad_read_word(addr);
}
void int_cx_write_word(u32 addr, u32 value) {
	switch (addr & 0x3FFFFFF) {
		case 0x004: return;
		case 0x00C: intr.mask[1] = value; update_cx(); return;
		case 0x010: intr.mask[0] |= value; update_cx(); return;
		case 0x014: intr.mask[0] &= ~value; update_cx(); return;
		case 0x10C: return;
		case 0x21C: return;
	}
	return bad_write_word(addr, value);
}

void int_set(u32 int_num, bool on) {
	if (on) intr.active |= 1 << int_num;
	else    intr.active &= ~(1 << int_num);
	if (!emulate_cx)
		update();
	else
		update_cx();
}

void int_reset() {
	memset(&intr, 0, sizeof intr);
	intr.noninverted = -1;
	intr.priority_limit[0] = 8;
	intr.priority_limit[1] = 8;
}

#if 0
void *int_save_state(size_t *size) {
	(void)size;
	return NULL;
}

void int_reload_state(void *state) {
	(void)state;
}
#endif
