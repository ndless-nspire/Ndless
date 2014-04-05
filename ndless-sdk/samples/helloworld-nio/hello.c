#include <os.h>
#include <nspireio2.h>

int main(void) {
	nio_console csl;
	lcd_ingray();
	clrscr();
	// 53 columns, 29 rows. 0px offset for x/y. Background color 0 (black), foreground color 15 (white)
	nio_InitConsole(&csl, 53, 29, 0, 0, 0, 15);
	nio_DrawConsole(&csl);
	nio_printf(&csl, "hello world!");
	wait_key_pressed();
	nio_CleanUp(&csl);
	return 0;
}
