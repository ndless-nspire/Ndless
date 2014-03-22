#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "emu.h"

static u16 lcd_framebuffer[2];
static u32 lcd_control;

void casplus_lcd_draw_frame(u8 buffer[240][160]) {
	u32 base = lcd_framebuffer[1] << 16 | lcd_framebuffer[0];
	u8 *palette = phys_mem_ptr(base, 0x9620);
	if (!palette) {
		memset(buffer, 0, 160 * 240);
		return;
	}
	u8 *in = palette + 0x20;
	int row, x;
	for (row = 239; row >= 0; row--) {
		u8 *out = buffer[row];
		if (lcd_control & 0x400000) { // bit set in U-Boot, guessing it reverses pixel order
			for (x = 0; x < 320; x += 2) {
				int color1 = palette[(*in >> 4) << 1] & 15;
				int color2 = palette[(*in & 15) << 1] & 15;
				*out++ = color1 << 4 | color2;
				in++;
			}
		} else {
			for (x = 0; x < 320; x += 2) {
				int color1 = palette[(*in & 15) << 1] & 15;
				int color2 = palette[(*in >> 4) << 1] & 15;
				*out++ = color1 << 4 | color2;
				in++;
			}
		}
	}
}

/* 0A000000: NAND flash */

u16 casplus_nand_read_half(u32 addr) {
	switch (addr & 0x01FFFFFF) {
		case 0: return nand_read_data_byte();
	}
	return bad_read_half(addr);
}
u8 casplus_nand_read_byte(u32 addr) {
	return casplus_nand_read_half(addr);
}
void casplus_nand_write_half(u32 addr, u16 value) {
	switch (addr & 0x01FFFFFF) {
		case 0: nand_write_data_byte(value); return;
		case 2: nand_write_command_byte(value); return;
		case 4: nand_write_address_byte(value); return;
	}
	bad_write_half(addr, value);
}
void casplus_nand_write_byte(u32 addr, u8 value) {
	casplus_nand_write_half(addr, value);
}

/* FFFEC5xx, FFFEC6xx, FFFEC7xx: Timers */

struct omap_timer {
	u32 control;
	u32 load;
	u32 value;
	// top 12 bits stored explicitly,
	// low 20 bits implicit in time remaining to next sched. event
	// This is an arbitrary division to prevent integer overflows
} omap_timer[3];

u32 omap_timer_read_word(int which, u32 addr) {
	struct omap_timer *t = &omap_timer[which];
	switch (addr & 0xFF) {
		case 0x00:
			return t->control;
		case 0x08:
			sched_process_pending_events();
			if (t->control & 1) { // timer running
				int scale = 1 + (t->control >> 2 & 7);
				return t->value + (event_ticks_remaining(SCHED_CASPLUS_TIMER1 + which) >> scale);
			}
			return t->value;
	}
	return bad_read_word(addr);
}

void omap_timer_write_word(int which, u32 addr, u32 value) {
	struct omap_timer *t = &omap_timer[which];
	switch (addr & 0xFF) {
		case 0x00:
			sched_process_pending_events();
			if ((t->control ^ value) & 1) {
				int scale = 1 + (value >> 2 & 7);
				if (value & 1) { // starting timer
					t->value = t->load & 0xfff00000;
					u32 ticks = ((t->load & 0xfffff) + 1) << scale;
					event_set(SCHED_CASPLUS_TIMER1 + which, ticks);
				} else { // stopping timer
					t->value += event_ticks_remaining(SCHED_CASPLUS_TIMER1 + which) >> scale;
					event_clear(SCHED_CASPLUS_TIMER1 + which);
				}
			}
			t->control = value & 0x3F;
			return;
		case 0x04:
			t->load = value;
			return;
	}
	bad_write_word(addr, value);
}

void omap_timer_event(int index) {
	int which = index - SCHED_CASPLUS_TIMER1;
	struct omap_timer *t = &omap_timer[which];

	int scale = 1 + (t->control >> 2 & 7);
	if (t->value) {
		t->value -= 0x100000;
		event_repeat(index, 0x100000 << scale);
	} else {
		if (which == 1)
			casplus_int_set(30, true);

		if (t->control & 2) { // Auto-reload mode
			t->value = t->load & 0xfff00000;
			u32 ticks = ((t->load & 0xfffff) + 1) << scale;
			event_repeat(index, ticks);
		} else { // One-shot mode
			t->control &= ~1;
			t->value = 0;
		}
	}
}

/* FFFBB4xx, FFFBBCxx, FFFBE4xx, FFFBECxx: GPIO */

u16 omap_keypad_row_mask;

struct omap_gpio {
	u16 dataout;
	u16 direction;
} omap_gpio[4];

u16 omap_read_keypad() {
	u16 columns = 0;
	int row;
	for (row = 0; row < 8; row++)
		if (!(omap_keypad_row_mask & (1 << row)))
			columns |= key_map[row];
	// row 8 is controlled by GPIO 0x25
	if (!((omap_gpio[2].dataout | omap_gpio[2].direction) & 0x20))
		columns |= key_map[8];
	return columns;
}

u16 omap_gpio_read(int which, u32 addr) {
	switch (addr & 0xFF) {
		case 0x2C:
			// GPIO 0x0D-0x0F: keypad columns 5-7
			// GPIO 0x20-0x23: keypad columns 8-10
			// GPIO 0x26: "on" key?
			if (which == 0) return ~(omap_read_keypad() << 8 & 0xE000);
			if (which == 2) return ~((omap_read_keypad() >> 8 & 0x0007) | (key_map[0] >> 3 & 0x40));
			return -1;
		case 0x34:
			return omap_gpio[which].direction;
	}
	return 0; //bad_read_half(addr);
}
void omap_gpio_write(int which, u32 addr, u16 value) {
	struct omap_gpio *g = &omap_gpio[which];
	switch (addr & 0xFF) {
		case 0x34: g->direction = value; return;
		case 0xB0: g->dataout &= ~value; return;
		case 0xF0: g->dataout |= value; return;
	}
	//bad_write_half(addr, value);
}

/* FFFECBxx: Interrupts */

struct {
	u32 active;
	u32 mask;
	u8 priority[32];
} omap_int;

static void int_chk() {
	if (omap_int.active & ~omap_int.mask)
		arm.interrupts |= 0x80;
	else
		arm.interrupts &= ~0x80;
	cpu_int_check();
}

static u32 omap_int_read_word(u32 addr) {
	int offset = addr & 0xFF;
	if (offset >= 0x1C && offset < 0x9C) {
		return omap_int.priority[(offset - 0x1C) >> 2];
	}
	switch (offset) {
		case 0x00: return omap_int.active;
		case 0x04: return omap_int.mask;
		case 0x10: {
			int i;
			// XXX: should check priority?
			for (i = 0; i < 32; i++)
				if (omap_int.active & ~omap_int.mask & (1 << i))
					break;
			if (i == 32) error("no interrupt");
			omap_int.active &= ~(1 << i); // XXX: only if edge-sensitive
			int_chk();
			return i;
		}
	}
	return bad_read_word(addr);
}
static void omap_int_write_word(u32 addr, u32 value) {
	int offset = addr & 0xFF;
	if (offset >= 0x1C && offset < 0x9C) {
		omap_int.priority[(offset - 0x1C) >> 2] = value & 0x7F;
		return;
	}
	switch (offset) {
		case 0x00: omap_int.active &= value; int_chk(); return;
		case 0x04: omap_int.mask = value; int_chk(); return;
		case 0x18: return;
	}
	bad_write_word(addr, value);
}

void casplus_int_set(u32 int_num, bool on) {
	if (on) omap_int.active |= 1 << int_num;
	else    omap_int.active &= ~(1 << int_num);
	int_chk();
}

u32 omap_32k_synch_timer;

u8 omap_read_byte(u32 addr) {
	if (addr >= 0xFFFB9800 && addr <= 0xFFFB983F)
		return serial_read(addr);
	return bad_read_byte(addr);
}
u16 omap_read_half(u32 addr) {
	if (addr >= 0xFFFBB400 && addr <= 0xFFFBB4FF) return omap_gpio_read(2, addr);
	if (addr >= 0xFFFBBC00 && addr <= 0xFFFBBCFF) return omap_gpio_read(3, addr);
	if (addr >= 0xFFFBE400 && addr <= 0xFFFBE4FF) return omap_gpio_read(0, addr);
	if (addr >= 0xFFFBEC00 && addr <= 0xFFFBECFF) return omap_gpio_read(1, addr);
	switch (addr) {
		case 0xFFFB3808: return 4;
		case 0xFFFB5010: return ~(omap_read_keypad() & 0xFF);
		case 0xFFFB5014: return omap_keypad_row_mask;
		case 0xFFFB5020: return 0xFFFE + ((omap_read_keypad() & 0xFF) == 0);
		case 0xFFFBC410: return ++omap_32k_synch_timer;
		case 0xFFFBC412: return ++omap_32k_synch_timer >> 16;
		case 0xFFFECF00: return -1;
	}
	return 0; //bad_read_half(addr);
}
u32 omap_read_word(u32 addr) {
	if (addr >= 0xFFFBB400 && addr <= 0xFFFBB4FF) return omap_gpio_read(2, addr);
	if (addr >= 0xFFFBBC00 && addr <= 0xFFFBBCFF) return omap_gpio_read(3, addr);
	if (addr >= 0xFFFBE400 && addr <= 0xFFFBE4FF) return omap_gpio_read(0, addr);
	if (addr >= 0xFFFBEC00 && addr <= 0xFFFBECFF) return omap_gpio_read(1, addr);
	if (addr >= 0xFFFEC500 && addr <= 0xFFFEC7FF)
		return omap_timer_read_word((addr >> 8 & 3) - 1, addr);
	if (addr >= 0xFFFECB00 && addr <= 0xFFFECBFF)
		return omap_int_read_word(addr);

	switch (addr) {
		case 0xFFFB0404: return 4;
		case 0xFFFB0C14: return 1; // SPI status
		case 0xFFFB0C18: return 1; // SPI interrupt status
		case 0xFFFBC410: return ++omap_32k_synch_timer;
		case 0xFFFEC000: return lcd_control;
		case 0xFFFEC010: return 1; // LcdStatus
		case 0xFFFECC0C: return 0x12 | nand_writable; // EMIFS_CONFIG
		case 0xFFFECF00: return -1;
	}
	return 0; //bad_read_word(addr);
}

void omap_write_byte(u32 addr, u8 byte) {
	if (addr >= 0xFFFB9800 && addr <= 0xFFFB983F)
		return serial_write(addr, byte);
	bad_write_byte(addr, byte);
}
void omap_write_half(u32 addr, u16 value) {
	if (addr >= 0xFFFBB400 && addr <= 0xFFFBB4FF) return omap_gpio_write(2, addr, value);
	if (addr >= 0xFFFBBC00 && addr <= 0xFFFBBCFF) return omap_gpio_write(3, addr, value);
	if (addr >= 0xFFFBE400 && addr <= 0xFFFBE4FF) return omap_gpio_write(0, addr, value);
	if (addr >= 0xFFFBEC00 && addr <= 0xFFFBECFF) return omap_gpio_write(1, addr, value);
	switch (addr) {
		case 0xFFFB5014: omap_keypad_row_mask = 0xFF00 | value; return;
		case 0xFFFECE00: {
			// bit 12 controls which clock timers use
			u32 new_rates[2] = { 78000000, (value & 0x1000) ? 78000000 : 12000000 };
			sched_set_clocks(2, new_rates);
			return;
		}
		case 0xFFFEDB02: lcd_framebuffer[0] = value; return;
		case 0xFFFEDB04: lcd_framebuffer[1] = value; return;
	}
	//bad_write_half(addr, value);
}
void omap_write_word(u32 addr, u32 value) {
	if (addr >= 0xFFFBB400 && addr <= 0xFFFBB4FF) return omap_gpio_write(2, addr, value);
	if (addr >= 0xFFFBBC00 && addr <= 0xFFFBBCFF) return omap_gpio_write(3, addr, value);
	if (addr >= 0xFFFBE400 && addr <= 0xFFFBE4FF) return omap_gpio_write(0, addr, value);
	if (addr >= 0xFFFBEC00 && addr <= 0xFFFBECFF) return omap_gpio_write(1, addr, value);

	if (addr >= 0xFFFEC500 && addr <= 0xFFFEC7FF)
		return omap_timer_write_word((addr >> 8 & 3) - 1, addr, value);
	if (addr >= 0xFFFECB00 && addr <= 0xFFFECBFF)
		return omap_int_write_word(addr, value);
	switch (addr) {
		case 0xFFFEC000: lcd_control = value; return;
		case 0xFFFECC0C: nand_writable = value & 1; return; // EMIFS_CONFIG
		case 0xFFFECE10: cpu_events |= EVENT_RESET; return;
	}
	//bad_write_word(addr, value);
}

void casplus_reset() {
	memset(lcd_framebuffer, 0, sizeof lcd_framebuffer);
	lcd_control = 0;

	int i;
	for (i = 0; i < 3; i++) {
		omap_timer[i].control = 0;
		omap_timer[i].load = 0xffffffff; // hack for U-Boot
		sched_items[SCHED_CASPLUS_TIMER1+i].clock = CLOCK_AHB;
		sched_items[SCHED_CASPLUS_TIMER1+i].second = -1;
		sched_items[SCHED_CASPLUS_TIMER1+i].proc = omap_timer_event;
	}

	omap_keypad_row_mask = 0xFFFF;

	for (i = 0; i < 4; i++) {
		omap_gpio[i].dataout = 0;
		omap_gpio[i].direction = 0xFFFF;
	}

	memset(&omap_int, 0, sizeof omap_int);
	omap_int.mask = -1;

	omap_32k_synch_timer = 0;

	clock_rates[CLOCK_CPU] = 78000000;
	clock_rates[CLOCK_AHB] = 78000000;
}
