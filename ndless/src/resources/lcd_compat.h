#ifndef LCD_COMPAT_H
#define LCD_COMPAT_H

#include <stdbool.h>

// Set by lcd_compat_load_hwrev. Called in install.c
extern bool is_hww;

void lcd_compat_load_hwrev(void);

bool lcd_compat_enable(void);
void lcd_compat_disable(void);

#endif /* LCD_COMPAT_H */
