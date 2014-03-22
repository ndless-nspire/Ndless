#include "emu.h"
#include <string.h>

volatile int keypad_type = -1;
volatile u16 key_map[16];
volatile u16 touchpad_x;
volatile u16 touchpad_y;
volatile u8 touchpad_down;

/* 900E0000: Keypad controller */

struct keypad_controller_state kpc;

void keypad_int_check() {
	int_set(INT_KEYPAD, (kpc.int_enable & kpc.int_active)
	                  | (kpc.gpio_int_enable & kpc.gpio_int_active));
}
u32 keypad_read(u32 addr) {
	switch (addr & 0x7F) {
		case 0x00:
			cycle_count_delta += 1000; // avoid slowdown with polling loops
			return kpc.control;
		case 0x04: return kpc.size;
		case 0x08: return kpc.int_active;
		case 0x0C: return kpc.int_enable;
		case 0x10: case 0x14: case 0x18: case 0x1C:
		case 0x20: case 0x24: case 0x28: case 0x2C:
			return *(u32 *)((u8 *)kpc.data + ((addr - 0x10) & 31));
		case 0x30: return 0; // GPIO direction?
		case 0x34: return 0; // GPIO output?
		case 0x38: return 0; // GPIO input?
		case 0x3C: return 0;
		case 0x40: return kpc.gpio_int_enable;
		case 0x44: return kpc.gpio_int_active;
		case 0x48: return 0;
	}
	return bad_read_word(addr);
}
void keypad_write(u32 addr, u32 value) {
	switch (addr & 0x7F) {
		case 0x00:
			kpc.control = value;
			if (kpc.control & 2) {
				if (!(kpc.control >> 2 & 0x3FFF))
					error("keypad time between rows = 0");
				event_set(SCHED_KEYPAD, (kpc.control >> 16) + (kpc.control >> 2 & 0x3FFF));
			} else {
				event_clear(SCHED_KEYPAD);
			}
			return;
		case 0x04: kpc.size = value; return;
		case 0x08: kpc.int_active &= ~value; keypad_int_check(); return;
		case 0x0C: kpc.int_enable = value & 7; keypad_int_check(); return;

		case 0x30: return;
		case 0x34: return;
		case 0x3C: return;
		case 0x40: kpc.gpio_int_enable = value; keypad_int_check(); return;
		case 0x44: kpc.gpio_int_active &= ~value; keypad_int_check(); return;
		case 0x48: return;
	}
	bad_write_word(addr, value);
}
// Scan next row of keypad, if scanning is enabled
static void keypad_scan_event(int index) {
	if (kpc.current_row >= 16)
		error("too many keypad rows");

	u16 row = ~key_map[kpc.current_row];
	row &= ~(0x80000 >> kpc.current_row); // Emulate weird diagonal glitch
	row |= -1 << (kpc.size >> 8 & 0xFF);  // Unused columns read as 1
	if (emulate_cx)
		row = ~row;

	if (kpc.data[kpc.current_row] != row) {
		kpc.data[kpc.current_row] = row;
		kpc.int_active |= 2;
	}

	kpc.current_row++;
	if (kpc.current_row < (kpc.size & 0xFF)) {
		event_repeat(index, kpc.control >> 2 & 0x3FFF);
	} else {
		kpc.current_row = 0;
		kpc.int_active |= 1;
		if (kpc.control & 1) {
			event_repeat(index, (kpc.control >> 16) + (kpc.control >> 2 & 0x3FFF));
		} else {
			// If in single scan mode, go to idle mode
			kpc.control &= ~3;
		}
	}
	keypad_int_check();
}
void keypad_reset() {
	memset(&kpc, 0, sizeof kpc);
	sched_items[SCHED_KEYPAD].clock = CLOCK_APB;
	sched_items[SCHED_KEYPAD].second = -1;
	sched_items[SCHED_KEYPAD].proc = keypad_scan_event;
}

u8 touchpad_page = 0x04;

void touchpad_write(u8 addr, u8 value) {
	//printf("touchpad write: %02x %02x\n", addr, value);
	if (addr == 0xFF)
		touchpad_page = value;
}
u8 touchpad_read(u8 addr) {
	//printf("touchpad read:  %02x\n", addr);
	if (addr == 0xFF)
		return touchpad_page;

	if (touchpad_page == 0x10) {
		switch (addr) {
			case 0x04: return TOUCHPAD_X_MAX >> 8;
			case 0x05: return TOUCHPAD_X_MAX & 0xFF;
			case 0x06: return TOUCHPAD_Y_MAX >> 8;
			case 0x07: return TOUCHPAD_Y_MAX & 0xFF;
		}
	} else if (touchpad_page == 0x04) {
		switch (addr) {
			case 0x00: return touchpad_down; // contact
			case 0x01: return touchpad_down ? 100 : 0; // proximity
			case 0x02: return touchpad_x >> 8;
			case 0x03: return touchpad_x & 0xFF;
			case 0x04: return touchpad_y >> 8;
			case 0x05: return touchpad_y & 0xFF;
			case 0x06: return 0; // x velocity
			case 0x07: return 0; // y velocity
			case 0x08: return 0; // ?
			case 0x09: return 0; // ?
			case 0x0A: return touchpad_down;
			case 0x0B: return 0x4F; // status
			case 0xE4: return 1; // firmware version
			case 0xE5: return 6; // firmware version
			case 0xE6: return 0; // firmware version
			case 0xE7: return 0; // firmware version
		}
	}
	return 0;
}

u8 tp_prev_clock;
u8 tp_prev_data;
u8 tp_state;
u8 tp_byte;
u8 tp_bitcount;
u8 tp_port;
void touchpad_gpio_reset() {
	tp_prev_clock = 1;
	tp_prev_data = 1;
	tp_state = 0;
	tp_byte = 0;
	tp_bitcount = 0;
	tp_port = 0;
}
void touchpad_gpio_change() {
	u8 value = gpio.input.b[0] & (gpio.output.b[0] | gpio.direction.b[0]) & 0xA;
	u8 clock = value >> 1 & 1;
	u8 data  = value >> 3 & 1;

	if (tp_prev_clock == 1 && clock == 1) {
		if (data < tp_prev_data) {
			//printf("I2C start\n");
			tp_bitcount = 0;
			tp_byte = 0xFF;
			tp_state = 2;
		}
		if (data > tp_prev_data) {
			//printf("I2C stop\n");
			tp_state = 0;
		}
	}

	if (clock != tp_prev_clock) {
		if (tp_state == 0) {
			// idle, do nothing
		} else if (tp_bitcount < 8) {
			if (!clock) {
				gpio.input.b[0] &= ~8;
				gpio.input.b[0] |= tp_byte >> 4 & 8;
			} else {
				// bit transferred, shift the register
				tp_byte = tp_byte << 1 | data;
				tp_bitcount++;
			}
		} else switch (tp_state | clock) {
			case 2: // C->T address
				if ((tp_byte >> 1) != 0x20) {
					// Wrong address
					tp_state = 0;
					break;
				}
				gpio.input.b[0] &= ~8;
				break;
			case 3: // C->T address
				if (!(tp_byte & 1)) {
					tp_bitcount = 0;
					tp_byte = 0xFF;
					tp_state = 4;
					break;
				}
			read_again:
				tp_bitcount = 0;
				tp_byte = touchpad_read(tp_port);
				if (tp_port != 0xFF)
					tp_port++;
				tp_state = 8;
				break;
			case 4: // C->T port
				tp_port = tp_byte;
				gpio.input.b[0] &= ~8;
				break;
			case 5: // C->T port
			case 7: // C->T value
				tp_bitcount = 0;
				tp_byte = 0xFF;
				tp_state = 6;
				break;
			case 6: // C->T value
				touchpad_write(tp_port, tp_byte);
				if (tp_port != 0xFF)
					tp_port++;
				gpio.input.b[0] &= ~8;
				break;
			case 8: // T->C value
				gpio.input.b[0] |= 8;
				break;
			case 9: // T->C value
				if (!data)
					goto read_again;
				tp_state = 0;
				break;
		}
	}

	tp_prev_clock = clock;
	tp_prev_data  = data;
}

/* 90050000 */
struct {
	int state;
	int reading;
	u8 port;
} touchpad_cx;
void touchpad_cx_reset(void) {
	touchpad_cx.state = 0;
}
u32 touchpad_cx_read(u32 addr) {
	switch (addr & 0xFFFF) {
		case 0x0010:
			if (!touchpad_cx.reading)
				break;
			touchpad_cx.reading--;
			return touchpad_read(touchpad_cx.port++);
		case 0x0070:
			return touchpad_cx.reading ? 12 : 4;
		default:
			return 0;
	}
	return bad_read_word(addr);
}
void touchpad_cx_write(u32 addr, u32 value) {
	switch (addr & 0xFFFF) {
		case 0x0010:
			if (touchpad_cx.state == 0) {
				touchpad_cx.port = value;
				touchpad_cx.state = 1;
			} else {
				if (value & 0x100) {
					touchpad_cx.reading++;
				} else {
					touchpad_write(touchpad_cx.port++, value);
				}
			}
			return;
		case 0x0038:
			touchpad_cx.state = 0;
			touchpad_cx.reading = 0;
			return;
	}
	//bad_write_word(addr, value);
}

#if 0
void *keypad_save_state(size_t *size) {
	(void)size;
	return NULL;
}

void keypad_reload_state(void *state) {
	(void)state;
}
#endif
