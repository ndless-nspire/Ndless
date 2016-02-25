#ifndef LCD_COMPAT_H
#define LCD_COMPAT_H

#include <stdbool.h>

// Set by lcd_compat_load_hwrev. Called in install.c
extern bool is_hww;

void lcd_compat_load_hwrev();

void lcd_compat_enable(void *savedscr);
void lcd_compat_disable(void *savedscr);

#endif /* LCD_COMPAT_H */
