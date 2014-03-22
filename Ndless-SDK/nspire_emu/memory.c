#include <stdio.h>
#include <stdlib.h>
#include "emu.h"
#include "os-win32.h"

u8   (*read_byte_map[64])(u32 addr);
u16  (*read_half_map[64])(u32 addr);
u32  (*read_word_map[64])(u32 addr);
void (*write_byte_map[64])(u32 addr, u8 value);
void (*write_half_map[64])(u32 addr, u16 value);
void (*write_word_map[64])(u32 addr, u32 value);

/* For invalid/unknown physical addresses */
u8 bad_read_byte(u32 addr)               { warn("Bad read_byte: %08x", addr); return 0; }
u16 bad_read_half(u32 addr)              { warn("Bad read_half: %08x", addr); return 0; }
u32 bad_read_word(u32 addr)              { warn("Bad read_word: %08x", addr); return 0; }
void bad_write_byte(u32 addr, u8 value)  { warn("Bad write_byte: %08x %02x", addr, value); }
void bad_write_half(u32 addr, u16 value) { warn("Bad write_half: %08x %04x", addr, value); }
void bad_write_word(u32 addr, u32 value) { warn("Bad write_word: %08x %08x", addr, value); }

u8 *mem_and_flags;
struct mem_area_desc mem_areas[4];

void *phys_mem_ptr(u32 addr, u32 size) {
	unsigned int i;
	for (i = 0; i < sizeof(mem_areas)/sizeof(*mem_areas); i++) {
		u32 offset = addr - mem_areas[i].base;
		if (offset < mem_areas[i].size && size <= mem_areas[i].size - offset)
			return mem_areas[i].ptr + offset;
	}
	return NULL;
}

u32 phys_mem_addr(void *ptr) {
	int i;
	for (i = 0; i < 3; i++) {
		u32 offset = (u8 *)ptr - mem_areas[i].ptr;
		if (offset < mem_areas[i].size)
			return mem_areas[i].base + offset;
	}
	return -1; // should never happen
}


#define DO_READ_ACTION (RF_READ_BREAKPOINT)
void read_action(void *ptr) {
	u32 addr = phys_mem_addr(ptr);
	if (!gdb_connected)
		printf("Hit read breakpoint at %08x. Entering debugger.\n", addr);
	debugger(DBG_READ_BREAKPOINT, addr);
}

#define DO_WRITE_ACTION (RF_WRITE_BREAKPOINT | RF_CODE_TRANSLATED | RF_CODE_NO_TRANSLATE)
void write_action(void *ptr) {
	u32 addr = phys_mem_addr(ptr);
	u32 *flags = &RAM_FLAGS((size_t)ptr & ~3);
	if (*flags & RF_WRITE_BREAKPOINT) {
		if (!gdb_connected)
			printf("Hit write breakpoint at %08x. Entering debugger.\n", addr);
		debugger(DBG_WRITE_BREAKPOINT, addr);
	}
	if (*flags & RF_CODE_TRANSLATED) {
		logprintf(LOG_CPU, "Wrote to translated code at %08x. Deleting translations.\n", addr);
		invalidate_translation(*flags >> RFS_TRANSLATION_INDEX);
	} else {
		*flags &= ~RF_CODE_NO_TRANSLATE;
	}
}

/* 00000000, 10000000, A4000000: ROM and RAM */
u8 memory_read_byte(u32 addr) {
	u8 *ptr = phys_mem_ptr(addr, 1);
	if (!ptr) return bad_read_byte(addr);
	if (RAM_FLAGS((size_t)ptr & ~3) & DO_READ_ACTION) read_action(ptr);
	return *ptr;
}
u16 memory_read_half(u32 addr) {
	u16 *ptr = phys_mem_ptr(addr, 2);
	if (!ptr) return bad_read_half(addr);
	if (RAM_FLAGS((size_t)ptr & ~3) & DO_READ_ACTION) read_action(ptr);
	return *ptr;
}
u32 memory_read_word(u32 addr) {
	u32 *ptr = phys_mem_ptr(addr, 4);
	if (!ptr) return bad_read_word(addr);
	if (RAM_FLAGS(ptr) & DO_READ_ACTION) read_action(ptr);
	return *ptr;
}
void memory_write_byte(u32 addr, u8 value) {
	u8 *ptr = phys_mem_ptr(addr, 1);
	if (!ptr) { bad_write_byte(addr, value); return; }
	u32 flags = RAM_FLAGS((size_t)ptr & ~3);
	if (flags & RF_READ_ONLY) { bad_write_byte(addr, value); return; }
	if (flags & DO_WRITE_ACTION) write_action(ptr);
	*ptr = value;
}
void memory_write_half(u32 addr, u16 value) {
	u16 *ptr = phys_mem_ptr(addr, 2);
	if (!ptr) { bad_write_half(addr, value); return; }
	u32 flags = RAM_FLAGS((size_t)ptr & ~3);
	if (flags & RF_READ_ONLY) { bad_write_half(addr, value); return; }
	if (flags & DO_WRITE_ACTION) write_action(ptr);
	*ptr = value;
}
void memory_write_word(u32 addr, u32 value) {
	u32 *ptr = phys_mem_ptr(addr, 4);
	if (!ptr) { bad_write_word(addr, value); return; }
	u32 flags = RAM_FLAGS(ptr);
	if (flags & RF_READ_ONLY) { bad_write_word(addr, value); return; }
	if (flags & DO_WRITE_ACTION) write_action(ptr);
	*ptr = value;
}

/* The APB (Advanced Peripheral Bus) hosts peripherals that do not require
 * high bandwidth. The bridge to the APB is accessed via addresses 90xxxxxx. */
/* The AMBA specification does not mention anything about transfer sizes in APB,
 * so probably all reads/writes are effectively 32 bit. */
struct apb_map_entry {
	u32 (*read)(u32 addr);
	void (*write)(u32 addr, u32 value);
} apb_map[0x12];
void apb_set_map(int entry, u32 (*read)(u32 addr), void (*write)(u32 addr, u32 value)) {
	apb_map[entry].read = read;
	apb_map[entry].write = write;
}
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

u32 __attribute__((fastcall)) mmio_read_byte(u32 addr) {
	return read_byte_map[addr >> 26](addr);
}
u32 __attribute__((fastcall)) mmio_read_half(u32 addr) {
	return read_half_map[addr >> 26](addr);
}
u32 __attribute__((fastcall)) mmio_read_word(u32 addr) {
	return read_word_map[addr >> 26](addr);
}
void __attribute__((fastcall)) mmio_write_byte(u32 addr, u32 value) {
	write_byte_map[addr >> 26](addr, value);
}
void __attribute__((fastcall)) mmio_write_half(u32 addr, u32 value) {
	write_half_map[addr >> 26](addr, value);
}
void __attribute__((fastcall)) mmio_write_word(u32 addr, u32 value) {
	write_word_map[addr >> 26](addr, value);
}

void memory_initialize(u32 sdram_size) {
	mem_areas[0].size = 0x80000;
	mem_areas[1].base = 0x10000000;
	mem_areas[1].size = sdram_size;
	if (emulate_casplus) {
		mem_areas[2].base = 0x20000000;
		mem_areas[2].size = 0x40000;
	} else {
		mem_areas[2].base = 0xA4000000;
		mem_areas[2].size = 0x20000;
	}

	u32 total_mem = 0;
	int i;

	mem_and_flags = os_reserve(MEM_MAXSIZE * 2);
	for (i = 0; i != sizeof(mem_areas)/sizeof(*mem_areas); i++) {
		if (mem_areas[i].size) {
			mem_areas[i].ptr = &mem_and_flags[total_mem];
			total_mem += mem_areas[i].size;
		}
	}
	if (!mem_and_flags || total_mem > MEM_MAXSIZE ||
	    !os_commit(&mem_and_flags[0], total_mem) ||
	    !os_commit(&mem_and_flags[MEM_MAXSIZE], total_mem))
	{
		printf("Couldn't allocate memory\n");
		exit(1);
	}

	if (product == 0x0D0) {
		// Lab cradle OS reads calibration data from F007xxxx,
		// probably a mirror of ROM at 0007xxxx
		mem_areas[3].base = 0xF0000000;
		mem_areas[3].size = mem_areas[0].size;
		mem_areas[3].ptr = mem_areas[0].ptr;
	}

	for (i = 0; i < 64; i++) {
		/* will fallback to bad_* on non-memory addresses */
		read_byte_map[i] = memory_read_byte;
		read_half_map[i] = memory_read_half;
		read_word_map[i] = memory_read_word;
		write_byte_map[i] = memory_write_byte;
		write_half_map[i] = memory_write_half;
		write_word_map[i] = memory_write_word;
	}

	if (emulate_casplus) {
		read_byte_map[0x08 >> 2] = casplus_nand_read_byte;
		read_half_map[0x08 >> 2] = casplus_nand_read_half;
		write_byte_map[0x08 >> 2] = casplus_nand_write_byte;
		write_half_map[0x08 >> 2] = casplus_nand_write_half;

		read_byte_map[0xFF >> 2] = omap_read_byte;
		read_half_map[0xFF >> 2] = omap_read_half;
		read_word_map[0xFF >> 2] = omap_read_word;
		write_byte_map[0xFF >> 2] = omap_write_byte;
		write_half_map[0xFF >> 2] = omap_write_half;
		write_word_map[0xFF >> 2] = omap_write_word;

		add_reset_proc(casplus_reset);
		return;
	}

	read_byte_map[0x90 >> 2] = apb_read_byte;
	read_half_map[0x90 >> 2] = apb_read_half;
	read_word_map[0x90 >> 2] = apb_read_word;
	write_byte_map[0x90 >> 2] = apb_write_byte;
	write_half_map[0x90 >> 2] = apb_write_half;
	write_word_map[0x90 >> 2] = apb_write_word;
	for (i = 0; i < 0x12; i++) {
		apb_map[i].read = bad_read_word;
		apb_map[i].write = bad_write_word;
	}

	apb_set_map(0x00, gpio_read, gpio_write);
	add_reset_proc(gpio_reset);
	apb_set_map(0x06, watchdog_read, watchdog_write);
	add_reset_proc(watchdog_reset);
	apb_set_map(0x0A, misc_read, misc_write);
	apb_set_map(0x0B, pmu_read, pmu_write);
	add_reset_proc(pmu_reset);
	apb_set_map(0x0E, keypad_read, keypad_write);
	add_reset_proc(keypad_reset);
	apb_set_map(0x0F, hdq1w_read, hdq1w_write);
	add_reset_proc(hdq1w_reset);
	apb_set_map(0x11, unknown_9011_read, unknown_9011_write);

	read_byte_map[0xAC >> 2] = sdio_read_byte;
	read_half_map[0xAC >> 2] = sdio_read_half;
	read_word_map[0xAC >> 2] = sdio_read_word;
	write_byte_map[0xAC >> 2] = sdio_write_byte;
	write_half_map[0xAC >> 2] = sdio_write_half;
	write_word_map[0xAC >> 2] = sdio_write_word;

	read_byte_map[0xB0 >> 2] = usb_read_byte;
	read_half_map[0xB0 >> 2] = usb_read_half;
	read_word_map[0xB0 >> 2] = usb_read_word;
	write_word_map[0xB0 >> 2] = usb_write_word;
	add_reset_proc(usb_reset);
	add_reset_proc(usblink_reset);

	read_word_map[0xC0 >> 2] = lcd_read_word;
	write_word_map[0xC0 >> 2] = lcd_write_word;
	add_reset_proc(lcd_reset);

	read_word_map[0xC4 >> 2] = adc_read_word;
	write_word_map[0xC4 >> 2] = adc_write_word;
	add_reset_proc(adc_reset);

	des_initialize();
	read_word_map[0xC8 >> 2] = des_read_word;
	write_word_map[0xC8 >> 2] = des_write_word;
	add_reset_proc(des_reset);

	read_word_map[0xCC >> 2] = sha256_read_word;
	write_word_map[0xCC >> 2] = sha256_write_word;
	add_reset_proc(sha256_reset);

	if (!emulate_cx) {
		read_byte_map[0x08 >> 2] = nand_phx_raw_read_byte;
		write_byte_map[0x08 >> 2] = nand_phx_raw_write_byte;

		write_word_map[0x8F >> 2] = sdramctl_write_word;

		apb_set_map(0x01, timer_read, timer_write);
		apb_set_map(0x0C, timer_read, timer_write);
		apb_set_map(0x0D, timer_read, timer_write);
		add_reset_proc(timer_reset);
		apb_set_map(0x02, serial_read, serial_write);
		add_reset_proc(serial_reset);
		apb_set_map(0x08, bad_read_word, unknown_9008_write);
		apb_set_map(0x09, rtc_read, rtc_write);
		apb_set_map(0x10, ti84_io_link_read, ti84_io_link_write);
		add_reset_proc(ti84_io_link_reset);

		read_word_map[0xA9 >> 2] = spi_read_word;
		write_word_map[0xA9 >> 2] = spi_write_word;

		read_word_map[0xB8 >> 2] = nand_phx_read_word;
		write_word_map[0xB8 >> 2] = nand_phx_write_word;
		add_reset_proc(nand_phx_reset);

		read_word_map[0xBC >> 2] = unknown_BC_read_word;

		read_word_map[0xDC >> 2] = int_read_word;
		write_word_map[0xDC >> 2] = int_write_word;
		add_reset_proc(int_reset);
	} else {
		read_byte_map[0x80 >> 2] = nand_cx_read_byte;
		read_word_map[0x80 >> 2] = nand_cx_read_word;
		write_byte_map[0x80 >> 2] = nand_cx_write_byte;
		write_word_map[0x80 >> 2] = nand_cx_write_word;

		read_word_map[0x8F >> 2] = memctl_cx_read_word;
		write_word_map[0x8F >> 2] = memctl_cx_write_word;
		add_reset_proc(memctl_cx_reset);

		apb_set_map(0x01, timer_cx_read, timer_cx_write);
		apb_set_map(0x0C, timer_cx_read, timer_cx_write);
		apb_set_map(0x0D, timer_cx_read, timer_cx_write);
		add_reset_proc(timer_cx_reset);
		apb_set_map(0x02, serial_cx_read, serial_cx_write);
		add_reset_proc(serial_cx_reset);
		apb_set_map(0x03, unknown_cx_read, unknown_cx_write);
		apb_set_map(0x04, unknown_cx_read, unknown_cx_write);
		apb_set_map(0x05, touchpad_cx_read, touchpad_cx_write);
		add_reset_proc(touchpad_cx_reset);
		apb_set_map(0x09, rtc_cx_read, rtc_cx_write);

		read_word_map[0xB4 >> 2] = usb_read_word;

		read_word_map[0xB8 >> 2] = sramctl_read_word;
		write_word_map[0xB8 >> 2] = sramctl_write_word;

		read_word_map[0xDC >> 2] = int_cx_read_word;
		write_word_map[0xDC >> 2] = int_cx_write_word;
		add_reset_proc(int_reset);
	}
}

#if 0
void *memory_save_state(size_t *size) {
	(void)size;
	return NULL;
}

void memory_reload_state(void *state) {
	(void)state;
}
#endif
