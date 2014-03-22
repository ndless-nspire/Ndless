#include <os.h>

int main(void) {
	if (!has_colors)
		return 0;
	lcd_incolor();
	volatile unsigned char *scr_base = SCREEN_BASE_ADDRESS;
	volatile unsigned char *ptr;
	unsigned scr_size = SCREEN_BYTES_SIZE;
	// See http://en.wikipedia.org/wiki/High_color -> "16-bit high color" for the encoding of the screen buffer
	for (ptr = scr_base; ptr < scr_base + scr_size / 3; ptr += 2)
		*(volatile unsigned short*)ptr = 0b1111100000000000;
	for (; ptr < scr_base + scr_size * 2 / 3; ptr += 2)
		*(volatile unsigned short*)ptr = 0b0000011111100000;
	for (; ptr < scr_base + scr_size; ptr += 2)
		*(volatile unsigned short*)ptr = 0b0000000000011111;
	wait_key_pressed();
	return 0;
}
