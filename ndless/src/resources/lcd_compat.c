#include <stdbool.h>
#include <stdint.h>

#include "lcd_compat.h"
#include "ndless.h"

// Location of the pointer used by the OS to implement 240x320 lcd support
static uint32_t lcd_mirror_ptr[NDLESS_MAX_OSID+1] = {0, 0, 0, 0, 0, 0,
                                                   0, 0, 0, 0,
                                                   0, 0, 0, 0,
                                                   0, 0, 0, 0,
                                                   0, 0,
                                                   0, 0,
                                                   0x110ED6D4, 0x111516D4
                                                   };
bool is_hww;

void lcd_compat_load_hwrev()
{
	is_hww = lcd_mirror_ptr[ut_os_version_index] != 0 && *(uint32_t*)lcd_mirror_ptr[ut_os_version_index] != 0;
}
