#include <string.h>
#include "emu.h"

struct {
	u32 timing[4];
	u32 upbase; // Upper panel base 
	u32 lpbase; // Lower panel base (not used)
	u32 framebuffer; // Value of upbase latched at beginning of frame
	u32 control;
	u8 int_mask;
	u8 int_status;
	u16 palette[256];
} lcd;

/* Draw the current screen into a 4bpp upside-down bitmap. (SetDIBitsToDevice
 * supports either orientation, but some programs can't paste right-side-up bitmaps) */
void lcd_draw_frame(u8 buffer[240][160]) {
	u32 bpp = 1 << (lcd.control >> 1 & 7);
	u32 *in = phys_mem_ptr(lcd.framebuffer, (320 * 240) / 8 * bpp);
	if (!in || bpp > 32) {
		memset(buffer, 0, 160 * 240);
		return;
	}
	int row;
	for (row = 239; row >= 0; row--) {
		u32 pal_shift = lcd.control & (1 << 8) ? 11 : 1;
		int words = (320 / 32) * bpp;
		u8 *out = buffer[row];
		if (bpp < 16) {
			u32 mask = (1 << bpp) - 1;
			u32 bi = (lcd.control & (1 << 9)) ? 0 : 24;
			if (!(lcd.control & (1 << 10)))
				bi ^= (8 - bpp);
			do {
				u32 word = *in++;
				int bitpos = 32;
				do {
					int color1 = lcd.palette[word >> ((bitpos -= bpp) ^ bi) & mask] >> pal_shift & 15;
					int color2 = lcd.palette[word >> ((bitpos -= bpp) ^ bi) & mask] >> pal_shift & 15;
					*out++ = color1 << 4 | color2;
					color1 = lcd.palette[word >> ((bitpos -= bpp) ^ bi) & mask] >> pal_shift & 15;
					color2 = lcd.palette[word >> ((bitpos -= bpp) ^ bi) & mask] >> pal_shift & 15;
					*out++ = color1 << 4 | color2;
				} while (bitpos != 0);
			} while (--words != 0);
		} else if (bpp == 16) {
			u32 shift1 = pal_shift | (lcd.control & (1 << 9) ? 16 : 0);
			u32 shift2 = shift1 ^ 16;
			do {
				u32 word = *in++;
				*out++ = (word >> shift1 & 15) << 4 | (word >> shift2 & 15);
			} while (--words != 0);
		} else {
			u32 shift = lcd.control & (1 << 8) ? 20 : 4;
			do {
				int color1 = *in++ >> shift;
				int color2 = *in++ >> shift & 15;
				*out++ = color1 << 4 | color2;
			} while ((words -= 2) != 0);
		}
	}
}

/* Draw the current screen into a 16bpp upside-down bitmap. */
void lcd_cx_draw_frame(u16 buffer[240][320], u32 bitfields[3]) {
	u32 mode = lcd.control >> 1 & 7;
	u32 bpp;
	if (mode <= 5)
		bpp = 1 << mode;
	else
		bpp = 16;

	if (mode == 7) {
		// 444 format
		bitfields[0] = 0x000F;
		bitfields[1] = 0x00F0;
		bitfields[2] = 0x0F00;
	} else {
		// 565 format
		bitfields[0] = 0x001F;
		bitfields[1] = 0x07E0;
		bitfields[2] = 0xF800;
	}
	if (lcd.control & (1 << 8)) {
		// BGR format (R high, B low)
		u32 tmp = bitfields[0];
		bitfields[0] = bitfields[2];
		bitfields[2] = tmp;
	}

	u32 *in = phys_mem_ptr(lcd.framebuffer, (320 * 240) / 8 * bpp);
	if (!in) {
		memset(buffer, 0, 320 * 240 * 2);
		return;
	}
	int row;
	for (row = 239; row >= 0; row--) {
		u16 *out = buffer[row];
		u32 words = (320 / 32) * bpp;
		if (bpp < 16) {
			u32 mask = (1 << bpp) - 1;
			u32 bi = (lcd.control & (1 << 9)) ? 0 : 24;
			if (!(lcd.control & (1 << 10)))
				bi ^= (8 - bpp);
			do {
				u32 word = *in++;
				int bitpos = 32;
				do {
					u16 color = lcd.palette[word >> ((bitpos -= bpp) ^ bi) & mask];
					*out++ = color + (color & 0xFFE0) + (color >> 10 & 0x20);
				} while (bitpos != 0);
			} while (--words != 0);
		} else if (mode == 4) {
			u32 i, bi = lcd.control >> 9 & 1;
			for (i = 0; i < 320; i++) {
				u16 color = ((u16 *)in)[i ^ bi];
				out[i] = color + (color & 0xFFE0) + (color >> 10 & 0x20);
			}
			in += 160;
		} else if (mode == 5) {
			// 32bpp mode: Convert 888 to 565
			do {
				u32 word = *in++;
				*out++ = (word >> 8 & 0xF800) | (word >> 5 & 0x7E0) | (word >> 3 & 0x1F);
			} while (--words != 0);
		} else {
			if (!(lcd.control & (1 << 9))) {
				memcpy(out, in, 640);
				in += 160;
			} else {
				u32 *outw = (u32 *)out;
				do {
					u32 word = *in++;
					*outw++ = word << 16 | word >> 16;
 				} while (--words != 0);
			}
		}
	}
}

static void lcd_event(int index) {
	int pcd = 1;
	if (!(lcd.timing[2] & (1 << 26)))
		pcd = (lcd.timing[2] >> 27 << 5) + (lcd.timing[2] & 0x1F) + 2;
	int htime = (lcd.timing[0] >> 24 &  0xFF) + 1  // Back porch
	          + (lcd.timing[0] >> 16 &  0xFF) + 1  // Front porch
	          + (lcd.timing[0] >>  8 &  0xFF) + 1  // Sync pulse
	          + (lcd.timing[2] >> 16 & 0x3FF) + 1; // Active
	int vtime = (lcd.timing[1] >> 24 &  0xFF)      // Back porch
	          + (lcd.timing[1] >> 16 &  0xFF)      // Front porch
	          + (lcd.timing[1] >> 10 &  0x3F) + 1  // Sync pulse
	          + (lcd.timing[1]       & 0x3FF) + 1; // Active
	event_repeat(index, pcd * htime * vtime);
	// for now, assuming vcomp occurs at same time UPBASE is loaded
	lcd.framebuffer = lcd.upbase;
	lcd.int_status |= 0xC;
	int_set(INT_LCD, lcd.int_status & lcd.int_mask);
}

void lcd_reset() {
	// Palette is unchanged on a reset
	memset(&lcd, 0, (char *)&lcd.palette - (char *)&lcd);
	sched_items[SCHED_LCD].clock = emulate_cx ? CLOCK_12M : CLOCK_27M;
	sched_items[SCHED_LCD].second = -1;
	sched_items[SCHED_LCD].proc = lcd_event;
}

u32 lcd_read_word(u32 addr) {
	u32 offset = addr & 0xFFF;
	if (offset < 0x200) {
		switch (offset) {
			case 0x000: case 0x004: case 0x008: case 0x00C:
				return lcd.timing[offset >> 2];
			case 0x010: return lcd.upbase;
			case 0x014: return lcd.lpbase;
			case 0x018: return emulate_cx ? lcd.control : lcd.int_mask; break;
			case 0x01C: return emulate_cx ? lcd.int_mask : lcd.control; break;
			case 0x020: return lcd.int_status;
			case 0x024: return lcd.int_status & lcd.int_mask;
		}
	} else if (offset < 0x400) {
		return *(u32 *)((u8 *)lcd.palette + offset - 0x200);
	} else if (offset >= 0xFE0) {
		static const u8 id[2][8] = {
			/* ARM PrimeCell Color LCD Controller (PL110), Revision 2 */
			{ 0x10, 0x11, 0x24, 0x00, 0x0D, 0xF0, 0x05, 0xB1 },
			/* ARM PrimeCell Color LCD Controller (PL111), Revision 1 */
			{ 0x11, 0x11, 0x14, 0x00, 0x0D, 0xF0, 0x05, 0xB1 }
		};
		return id[emulate_cx][(offset - 0xFE0) >> 2];
	}
	return bad_read_word(addr);
}

void lcd_write_word(u32 addr, u32 value) {
	u32 offset = addr & 0xFFF;
	if (offset < 0x200) {
		switch (offset) {
			case 0x000: case 0x004: case 0x008: case 0x00C:
				lcd.timing[offset >> 2] = value;
				return;
			case 0x010: lcd.upbase = value; return;
			case 0x014: lcd.lpbase = value; return;
			case 0x018:
				if (emulate_cx) goto write_control;
			write_int_mask:
				lcd.int_mask = value & 0x1E;
				int_set(INT_LCD, lcd.int_status & lcd.int_mask);
				return;
			case 0x01C:
				if (emulate_cx) goto write_int_mask;
			write_control:
				if ((value ^ lcd.control) & 1) {
					if (value & 1)
						event_set(SCHED_LCD, 0);
					else
						event_clear(SCHED_LCD);
				}
				lcd.control = value;
				return;
			case 0x028:
				lcd.int_status &= ~value;
				int_set(INT_LCD, lcd.int_status & lcd.int_mask);
				return;
		}
	} else if (offset < 0x400) {
		*(u32 *)((u8 *)lcd.palette + offset - 0x200) = value;
		return;
	}
	return bad_write_word(addr, value);
}

#if 0
void *lcd_save_state(size_t *size) {
	(void)size;
	return NULL;
}

void lcd_reload_state(void *state) {
	(void)state;
}
#endif
