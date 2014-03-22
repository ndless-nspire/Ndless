#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "emu.h"

/* The APB (Advanced Peripheral Bus) hosts peripherals that do not require
 * high bandwidth. The bridge to the APB is accessed via addresses 90xxxxxx. */

/* 90000000 */
struct gpio_state gpio;

void gpio_reset() {
	memset(&gpio, 0, sizeof gpio);
	gpio.direction.w = 0xFFFFFFFF;
	gpio.output.w    = 0x00000000;

	gpio.input.w     = 0x0005010E;
}
u32 gpio_read(u32 addr) {
	int port = addr >> 6 & 3;
	switch (addr & 0x3F) {
		case 0x04: return 0;
		case 0x10: return gpio.direction.b[port];
		case 0x14: return gpio.output.b[port];
		case 0x18: return gpio.input.b[port];
		case 0x1C: return gpio.invert.b[port];
		case 0x20: return gpio.sticky.b[port];
		case 0x24: return gpio.unknown_24.b[port];
 	}
	return bad_read_word(addr);
}
void gpio_write(u32 addr, u32 value) {
	int port = addr >> 6 & 3;
	u32 change;
	switch (addr & 0x3F) {
		case 0x04: return;
		case 0x08: return;
		case 0x0C: return;
		case 0x10:
			change = (gpio.direction.b[port] ^ value) << (8*port);
			gpio.direction.b[port] = value;
			if (change & 0xA)
				touchpad_gpio_change();
			return;
		case 0x14:
			change = (gpio.output.b[port] ^ value) << (8*port);
			gpio.output.b[port] = value;
			if (change & 0xA)
				touchpad_gpio_change();
			return;
		case 0x1C: gpio.invert.b[port] = value; return;
		case 0x20: gpio.sticky.b[port] = value; return;
		case 0x24: gpio.unknown_24.b[port] = value; return;
	}
	bad_write_word(addr, value);
}

/* 90010000, 900C0000, 900D0000 */
struct timerpair timerpairs[3];
#define ADDR_TO_TP(addr) (&timerpairs[((addr) >> 16) % 5])

u32 timer_read(u32 addr) {
	struct timerpair *tp = ADDR_TO_TP(addr);
	cycle_count_delta = 0; // Avoid slowdown by fast-forwarding through polling loops
	switch (addr & 0x003F) {
		case 0x00: return tp->timers[0].value;
		case 0x04: return tp->timers[0].divider;
		case 0x08: return tp->timers[0].control;
		case 0x0C: return tp->timers[1].value;
		case 0x10: return tp->timers[1].divider;
		case 0x14: return tp->timers[1].control;
		case 0x18: case 0x1C: case 0x20: case 0x24: case 0x28: case 0x2C:
			return tp->completion_value[((addr & 0x3F) - 0x18) >> 2];
	}
	return bad_read_word(addr);
}
void timer_write(u32 addr, u32 value) {
	struct timerpair *tp = ADDR_TO_TP(addr);
	switch (addr & 0x003F) {
		case 0x00: tp->timers[0].start_value = tp->timers[0].value = value; return;
		case 0x04: tp->timers[0].divider = value; return;
		case 0x08: tp->timers[0].control = value & 0x1F; return;
		case 0x0C: tp->timers[1].start_value = tp->timers[1].value = value; return;
		case 0x10: tp->timers[1].divider = value; return;
		case 0x14: tp->timers[1].control = value & 0x1F; return;
		case 0x18: case 0x1C: case 0x20: case 0x24: case 0x28: case 0x2C:
			tp->completion_value[((addr & 0x3F) - 0x18) >> 2] = value; return;
		case 0x30: return;
	}
	bad_write_word(addr, value);
}
static void timer_int_check(struct timerpair *tp) {
	int_set(INT_TIMER0 + (tp - timerpairs), tp->int_status & tp->int_mask);
}
void timer_advance(struct timerpair *tp, int ticks) {
	struct timer *t;
	for (t = &tp->timers[0]; t != &tp->timers[2]; t++) {
		int newticks;
		if (t->control & 0x10)
			continue;
		for (newticks = t->ticks + ticks; newticks > t->divider; newticks -= (t->divider + 1)) {
			int compl = t->control & 7;
			t->ticks = 0;

			if (compl == 0 && t->value == 0)
				/* nothing */;
			else if (compl != 0 && compl != 7 && t->value == tp->completion_value[compl - 1])
				t->value = t->start_value;
			else
				t->value += (t->control & 8) ? +1 : -1;

			if (t == &tp->timers[0]) {
				for (compl = 0; compl < 6; compl++) {
					if (t->value == tp->completion_value[compl]) {
						tp->int_status |= 1 << compl;
						timer_int_check(tp);
					}
				}
			}
		}
		t->ticks = newticks;
	}
}
static void timer_event(int index) {
	// TODO: should use seperate schedule item for each timer,
	//       only fired on significant events
	event_repeat(index, 1);
	timer_advance(&timerpairs[0], 703);
	timer_advance(&timerpairs[1], 1);
	timer_advance(&timerpairs[2], 1);
}
void timer_reset() {
	memset(timerpairs, 0, sizeof timerpairs);
	int i;
	for (i = 0; i < 3; i++) {
		timerpairs[i].timers[0].control = 0x10;
		timerpairs[i].timers[1].control = 0x10;
	}
	sched_items[SCHED_TIMERS].clock = CLOCK_32K;
	sched_items[SCHED_TIMERS].proc = timer_event;
}

/* 90020000 */
struct {
	u8 rx_char;
	u8 interrupts;
	u8 DLL;
	u8 DLM;
	u8 IER;
	u8 LCR;
} serial;

static inline void serial_int_check() {
	int_set(INT_SERIAL, serial.interrupts & serial.IER);
}

void serial_byte_in(u8 byte) {
	serial.rx_char = byte;
	serial.interrupts |= 1;
	serial_int_check();
}

u32 serial_read(u32 addr) {
	switch (addr & 0x3F) {
		case 0x00:
			if (serial.LCR & 0x80)
				return serial.DLL; /* Divisor Latch LSB */
			if (!(serial.interrupts & 1))
				error("Attempted to read empty RBR");
			serial.interrupts &= ~1;
			serial_int_check();
			return serial.rx_char;
		case 0x04:
			if (serial.LCR & 0x80)
				return serial.DLM; /* Divisor Latch MSB */
			return serial.IER; /* Interrupt Enable Register */
		case 0x08: /* Interrupt Identification Register */
			if (serial.interrupts & serial.IER & 1) {
				return 4;
			} else if (serial.interrupts & serial.IER & 2) {
				serial.interrupts &= ~2;
				serial_int_check();
				return 2;
			} else {
				return 1;
			}
		case 0x0C: /* Line Control Register */
			return serial.LCR;
		case 0x14: /* Line Status Register */
			return 0x60 | (serial.interrupts & 1);
	}
	return bad_read_word(addr);
}
void serial_write(u32 addr, u32 value) {
	switch (addr & 0x3F) {
		case 0x00:
			if (serial.LCR & 0x80) {
				serial.DLL = value;
			} else {
				putchar(value);
				serial.interrupts |= 2;
				serial_int_check();
			}
			return;
		case 0x04:
			if (serial.LCR & 0x80) {
				serial.DLM = value;
			} else {
				serial.IER = value & 0x0F;
				serial_int_check();
			}
			return;
		case 0x0C: /* Line Control Register */
			serial.LCR = value;
			return;
		case 0x08: /* FIFO Control Register */
		case 0x10: /* Modem Control Register */
		case 0x20: /* unknown, used by DIAGS */
			return;
	}
	bad_write_word(addr, value);
}

u32 serial_cx_read(u32 addr) {
	switch (addr & 0xFFFF) {
		case 0x018: return 0x90;
		case 0xFE0: return 0x11;
		case 0xFE4: return 0x10;
		case 0xFE8: return 0x34;
		case 0xFEC: return 0x00;
	}
	return bad_read_word(addr);
}
void serial_cx_write(u32 addr, u32 value) {
	switch (addr & 0xFFFF) {
		case 0x000:
			putchar(value);
			return;
		case 0x004:
		case 0x024:
		case 0x028:
		case 0x02C:
		case 0x030:
		case 0x034:
		case 0x038:
		case 0x044:
			return;
	}
	bad_write_word(addr, value);
}

/* 90030000 and 90040000 */
u32 unknown_cx_read(u32 addr) {
	return 0;
}
void unknown_cx_write(u32 addr, u32 value) {
}

/* 90060000 */
struct {
	u32 load;
	u32 value;
	u8 control;
	u8 interrupt;
	u8 locked;
} watchdog;
static void watchdog_reload() {
	if (watchdog.control & 1) {
		if (watchdog.load == 0)
			error("Watchdog period set to 0");
		event_set(SCHED_WATCHDOG, watchdog.load);
	}
}
static void watchdog_event(int index) {
	if (watchdog.control >> 1 & watchdog.interrupt) {
		warn("Resetting due to watchdog timeout");
		cpu_events |= EVENT_RESET;
	} else {
		watchdog.interrupt = 1;
		int_set(INT_WATCHDOG, 1);
		event_repeat(SCHED_WATCHDOG, watchdog.load);
	}
}
void watchdog_reset() {
	memset(&watchdog, 0, sizeof watchdog);
	watchdog.load = 0xFFFFFFFF;
	watchdog.value = 0xFFFFFFFF;
	sched_items[SCHED_WATCHDOG].clock = CLOCK_APB;
	sched_items[SCHED_WATCHDOG].second = -1;
	sched_items[SCHED_WATCHDOG].proc = watchdog_event;
}
u32 watchdog_read(u32 addr) {
	switch (addr & 0xFFF) {
		case 0x000: return watchdog.load;
		case 0x004:
			if (watchdog.control & 1)
				return event_ticks_remaining(SCHED_WATCHDOG);
			return watchdog.value;
		case 0x008: return watchdog.control;
		case 0x010: return watchdog.interrupt;
		case 0x014: return watchdog.control & watchdog.interrupt;
		case 0xC00: return watchdog.locked;
		default:
			return bad_read_word(addr);
	}
}
void watchdog_write(u32 addr, u32 value) {
	switch (addr & 0xFFF) {
		case 0x000:
			if (!watchdog.locked) {
				watchdog.load = value;
				watchdog_reload();
			}
			return;
		case 0x008:
			if (!watchdog.locked) {
				u8 prev = watchdog.control;
				watchdog.control = value & 3;
				if (~prev & value & 1) {
					watchdog_reload();
				} else if (prev & ~value & 1) {
					watchdog.value = event_ticks_remaining(SCHED_WATCHDOG);
					event_clear(SCHED_WATCHDOG);
				}
				int_set(INT_WATCHDOG, watchdog.control & watchdog.interrupt);
			}
			return;
		case 0x00C:
			if (!watchdog.locked) {
				watchdog.interrupt = 0;
				watchdog_reload();
				int_set(INT_WATCHDOG, 0);
			}
			return;
		case 0xC00:
			watchdog.locked = (value != 0x1ACCE551);
			return;
	}
	bad_write_word(addr, value);
}

/* 90080000 */
void unknown_9008_write(u32 addr, u32 value) {
	switch (addr & 0xFFFF) {
		case 0x8: return;
		case 0xC: return;
		case 0x10: return;
		case 0x14: return;
		case 0x18: return;
		case 0x1C: return;
	}
	bad_write_word(addr, value);
}

/* 90090000 */
static time_t rtc_time_diff;
u32 rtc_read(u32 addr) {
	switch (addr & 0xFFFF) {
		case 0x00: return time(NULL) - rtc_time_diff;
		case 0x14: return 0;
	}
	return bad_read_word(addr);
}
void rtc_write(u32 addr, u32 value) {
	switch (addr & 0xFFFF) {
		case 0x04: return;
		case 0x08: rtc_time_diff = time(NULL) - value; return;
		case 0x0C: return;
		case 0x10: return;
	}
	bad_write_word(addr, value);
}
u32 rtc_cx_read(u32 addr) {
	switch (addr & 0xFFFF) {
		case 0x000: return time(NULL);
		case 0xFE0: return 0x31;
		case 0xFE4: return 0x10;
		case 0xFE8: return 0x04;
		case 0xFEC: return 0x00;
	}
	return bad_read_word(addr);
}
void rtc_cx_write(u32 addr, u32 value) {
	switch (addr & 0xFFFF) {
		case 0x004: return;
		case 0x00C: return;
		case 0x010: return;
		case 0x01C: return;
	}
	bad_write_word(addr, value);
}

/* 900A0000 */
u32 misc_read(u32 addr) {
	struct timerpair *tp = &timerpairs[(addr - 0x10) >> 3 & 3];
	static const struct { u32 hi, lo; } idreg[4] = {
		{ 0x00000000, 0x00000000 },
		{ 0x04000001, 0x00010105 },
		{ 0x88000001, 0x00010107 },
		{ 0x8C000000, 0x00000002 },
	};
	switch (addr & 0x0FFF) {
		case 0x00: return emulate_cx ? 0x101 : 0x01000010;
		case 0x04: return 0;
		case 0x0C: return 0;
		case 0x10: case 0x18: case 0x20:
			if (emulate_cx) break;
			return tp->int_status;
		case 0x14: case 0x1C: case 0x24:
			if (emulate_cx) break;
			return tp->int_mask;
		/* Registers 28 and 2C give a 64-bit number (28 is low, 2C is high),
		 * which comprises 56 data bits and 8 parity checking bits:
		 *    Bit 0 is a parity check of all data bits
		 *    Bits 1, 2, 4, 8, 16, and 32 are parity checks of the data bits whose
		 *       positions, expressed in binary, have that respective bit set.
		 *    Bit 63 is a parity check of bits 1, 2, 4, 8, 16, and 32.
		 * With this system, any single-bit error can be detected and corrected.
		 * (But why would that happen?! I have no idea.)
		 *
		 * Anyway, bits 58-62 are the "ASIC user flags", a byte which must
		 * match the 80E0 field in an OS image. 01 = CAS, 00 = non-CAS. */
		case 0x28: return idreg[asic_user_flags].lo;
		case 0x2C: return idreg[asic_user_flags].hi;
	}
	return bad_read_word(addr);
}
void misc_write(u32 addr, u32 value) {
	struct timerpair *tp = &timerpairs[(addr - 0x10) >> 3 & 3];
	switch (addr & 0x0FFF) {
		case 0x04: return;
		case 0x08: cpu_events |= EVENT_RESET; return;
		case 0x10: case 0x18: case 0x20:
			if (emulate_cx) break;
			tp->int_status &= ~value;
			timer_int_check(tp);
			return;
		case 0x14: case 0x1C: case 0x24:
			if (emulate_cx) break;
			tp->int_mask = value & 0x3F;
			timer_int_check(tp);
			return;
		case 0xF04: return;
	}
	bad_write_word(addr, value);
}

/* 900B0000 */
struct pmu_state pmu;
void pmu_reset(void) {
	memset(&pmu, 0, sizeof pmu);
	pmu.clocks = pmu.clocks_load = emulate_cx ? 0x0F1002 : 0x141002;
}
u32 pmu_read(u32 addr) {
	switch (addr & 0x003F) {
		case 0x00: return pmu.clocks_load;
		case 0x04: return pmu.wake_mask;
		case 0x08: return 0x2000;
		case 0x0C: return 0;
		case 0x14: return 0;
		case 0x18: return pmu.disable;
		case 0x20: return pmu.disable2;
		case 0x24: return pmu.clocks;
		/* Bit 4 clear when ON key pressed */
		case 0x28: return 0x114 & ~(key_map[0] >> 5 & 0x10);
	}
	return bad_read_word(addr);
}
void pmu_write(u32 addr, u32 value) {
	switch (addr & 0x003F) {
		case 0x00: pmu.clocks_load = value; return;
		case 0x04: pmu.wake_mask = value & 0x1FFFFFF; return;
		case 0x08: return;
		case 0x0C:
			if (value & 4) {
				u32 clocks = pmu.clocks_load;
				u32 base;
				u32 cpudiv = (clocks & 0xFE) ? (clocks & 0xFE) : 2;
				u32 ahbdiv = (clocks >> 12 & 7) + 1;
				if (!emulate_cx) {
					if (clocks & 0x100)
						base = 27000000;
					else
						base = 300000000 - 6000000 * (clocks >> 16 & 0x1F);
				} else {
					if (clocks & 0x100) {
						base = 48000000;
						cpudiv = 1 << (clocks >> 30);
						ahbdiv = 2;
					} else {
						base = 6000000 * (clocks >> 15 & 0x3F);
						if (base == 0) error("invalid clock speed");
					}
				}
				u32 new_rates[3];
				new_rates[CLOCK_CPU] = base / cpudiv;
				new_rates[CLOCK_AHB] = new_rates[CLOCK_CPU] / ahbdiv;
				new_rates[CLOCK_APB] = new_rates[CLOCK_AHB] / 2;
				sched_set_clocks(3, new_rates);
				//warn("Changed clock speeds: %u %u %u", new_rates[0], new_rates[1], new_rates[2]);
				pmu.clocks = clocks;
				int_set(INT_POWER, 1); // CX boot1 expects an interrupt
			}
			return;
		case 0x14: int_set(INT_POWER, 0); return;
		case 0x18: pmu.disable = value; return;
		case 0x20: pmu.disable2 = value; return;
	}
	bad_write_word(addr, value);
}

/* 90010000, 900C0000(?), 900D0000 */
struct cx_timer {
	u32 load;
	u32 value;
	u8 prescale;
	u8 control;
	u8 interrupt;
	u8 reload;
} timer_cx[3][2];

void timer_cx_int_check(int which) {
	int_set(INT_TIMER0+which, (timer_cx[which][0].interrupt & timer_cx[which][0].control >> 5)
	                        | (timer_cx[which][1].interrupt & timer_cx[which][1].control >> 5));
}
u32 timer_cx_read(u32 addr) {
	int which = (addr >> 16) % 5;
	struct cx_timer *t = &timer_cx[which][addr >> 5 & 1];
	switch (addr & 0xFFFF) {
		case 0x0000: case 0x0020: return t->load;
		case 0x0004: case 0x0024: return t->value;
		case 0x0008: case 0x0028: return t->control;
		case 0x0010: case 0x0030: return t->interrupt;
		case 0x0014: case 0x0034: return t->interrupt & t->control >> 5;
		case 0x0018: case 0x0038: return t->load;
		case 0x001C: case 0x003C: return 0; //?
	}
	return bad_read_word(addr);
}
void timer_cx_write(u32 addr, u32 value) {
	int which = (addr >> 16) % 5;
	struct cx_timer *t = &timer_cx[which][addr >> 5 & 1];
	switch (addr & 0xFFFF) {
		case 0x0000: case 0x0020: t->reload = 1; /* fallthrough */
		case 0x0018: case 0x0038: t->load = value; return;
		case 0x0004: case 0x0024: return;
		case 0x0008: case 0x0028: t->control = value; timer_cx_int_check(which); return;
		case 0x000C: case 0x002C: t->interrupt = 0; timer_cx_int_check(which); return;

		case 0x0080: return; // ???
	}
	bad_write_word(addr, value);
}
void timer_cx_advance(int which) {
	int i;
	for (i = 0; i < 2; i++) {
		struct cx_timer *t = &timer_cx[which][i];
		t->prescale++;
		if (!(t->control & 0x80))
			continue;
		u32 oldvalue = (t->control & 2) ? t->value : t->value & 0xFFFF;
		u32 value = oldvalue;
		if (t->reload) {
			t->reload = 0;
			value = t->load;
		} else if (!(t->prescale & ((1 << (t->control & 0xC)) - 1))) {
			if (value == 0) {
				if (!(t->control & 1)) {
					value--;
					if (t->control & 0x40)
						value = t->load;
				}
			} else {
				value--;
			}
		}
		t->value = (t->control & 2) ? value : (t->value & 0xFFFF0000) | (value & 0xFFFF);
		if (oldvalue != 0 && value == 0) {
			t->interrupt = 1;
			timer_cx_int_check(which);
		}
	}
}
static void timer_cx_event(int index) {
	// TODO: should use seperate schedule item for each timer,
	//       only fired on significant events
	event_repeat(index, 1);
	// fast timer not implemented here...
	timer_cx_advance(1);
	timer_cx_advance(2);
}
void timer_cx_reset() {
	memset(timer_cx, 0, sizeof(timer_cx));
	int which, i;
	for (which = 0; which < 3; which++) {
		for (i = 0; i < 2; i++) {
			timer_cx[which][i].value = 0xFFFFFFFF;
			timer_cx[which][i].control = 0x20;
		}
	}
	sched_items[SCHED_TIMERS].clock = CLOCK_32K;
	sched_items[SCHED_TIMERS].proc = timer_cx_event;
}

/* 900F0000 */
u8 lcd_contrast;
u32 hdq1w_read(u32 addr) {
	switch (addr & 0xFFFF) {
		case 0x08: return 0;
		case 0x0C: return 0;
		case 0x10: return 0;
		case 0x14: return 0;
		case 0x20: return lcd_contrast;
	}
	return bad_read_word(addr);
}
void hdq1w_write(u32 addr, u32 value) {
	switch (addr & 0xFFFF) {
		case 0x04: return;
		case 0x0C: return;
		case 0x14: return;
		case 0x20: lcd_contrast = value; return;
	}
	bad_write_word(addr, value);
}

/* 90110000 */
u32 unknown_9011_read(u32 addr) {
	switch (addr & 0xFFFF) {
		case 0x000: return 0;
		case 0xB00: return 0x1643;
		case 0xB04: return 0;
		case 0xB08: return 0xFFFFF800;
		case 0xB0C: return 0;
		case 0xB10: return 0xFFFFF800;
	}
	return bad_read_word(addr);
}
void unknown_9011_write(u32 addr, u32 value) {
	switch (addr & 0xFFFF) {
		case 0xB00: return;
		case 0xB04: return;
		case 0xB08: return;
		case 0xB0C: return;
		case 0xB10: return;
	}
	bad_write_word(addr, value);
}

/* The AMBA specification does not mention anything about transfer sizes in APB,
 * so probably all reads/writes are effectively 32 bit. */

struct apb_map_entry apb_map[0x12];
const struct apb_map_entry apb_map_normal[] = {
	{ gpio_read,         gpio_write         },
	{ timer_read,        timer_write        },
	{ serial_read,       serial_write       },
	{ bad_read_word,     bad_write_word     },
	{ bad_read_word,     bad_write_word     },
	{ bad_read_word,     bad_write_word     },
	{ watchdog_read,     watchdog_write     },
	{ bad_read_word,     bad_write_word     },
	{ bad_read_word,     unknown_9008_write },
	{ rtc_read,          rtc_write          },
	{ misc_read,         misc_write         },
	{ pmu_read,          pmu_write          },
	{ timer_read,        timer_write        },
	{ timer_read,        timer_write        },
	{ keypad_read,       keypad_write       },
	{ hdq1w_read,        hdq1w_write        },
	{ ti84_io_link_read, ti84_io_link_write },
	{ unknown_9011_read, unknown_9011_write },
};
const struct apb_map_entry apb_map_cx[] = {
	{ gpio_read,         gpio_write         },
	{ timer_cx_read,     timer_cx_write     },
	{ serial_cx_read,    serial_cx_write    },
	{ unknown_cx_read,   unknown_cx_write   },
	{ unknown_cx_read,   unknown_cx_write   },
	{ touchpad_cx_read,  touchpad_cx_write  },
	{ watchdog_read,     watchdog_write     },
	{ bad_read_word,     bad_write_word     },
	{ bad_read_word,     bad_write_word     },
	{ rtc_cx_read,       rtc_cx_write       },
	{ misc_read,         misc_write         },
	{ pmu_read,          pmu_write          },
	{ timer_cx_read,     timer_cx_write     },
	{ timer_cx_read,     timer_cx_write     },
	{ keypad_read,       keypad_write       },
	{ hdq1w_read,        hdq1w_write        },
	{ bad_read_word,     bad_write_word     },
	{ unknown_9011_read, unknown_9011_write },
};

u8 apb_read_byte(u32 addr) {
	if (addr >= 0x90120000) return bad_read_byte(addr);
	return apb_map[addr >> 16 & 31].read(addr & ~3) >> ((addr & 3) << 3);
}
u16 apb_read_half(u32 addr) {
	if (addr >= 0x90120000) return bad_read_half(addr);
	return apb_map[addr >> 16 & 31].read(addr & ~2) >> ((addr & 2) << 3);
}
u32 apb_read_word(u32 addr) {
	if (addr >= 0x90120000) return bad_read_word(addr);
	return apb_map[addr >> 16 & 31].read(addr);
}
void apb_write_byte(u32 addr, u8 value) {
	if (addr >= 0x90120000) { bad_write_byte(addr, value); return; }
	apb_map[addr >> 16 & 31].write(addr & ~3, value * 0x01010101);
}
void apb_write_half(u32 addr, u16 value) {
	if (addr >= 0x90120000) { bad_write_half(addr, value); return; }
	apb_map[addr >> 16 & 31].write(addr & ~2, value * 0x00010001);
}
void apb_write_word(u32 addr, u32 value) {
	if (addr >= 0x90120000) { bad_write_word(addr, value); return; }
	apb_map[addr >> 16 & 31].write(addr, value);
}

#if 0
void *apb_save_state(size_t *size) {
	(void)size;
	return NULL;
}

void apb_reload_state(void *state) {
	(void)state;
}
#endif
