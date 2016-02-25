/****************************************************************************
 * The contents of this file are subject to the Mozilla Public
 * License Version 1.1 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 *
 * The Original Code is Ndless code.
 *
 * The Initial Developer of the Original Code is Fabian Vogt.
 * Portions created by the Initial Developer are Copyright (C) 2016
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s): 
 ****************************************************************************/

#include <libndls.h>

#include <syscall.h>
#include <syscall-list.h>

typedef void (*lcd_blit_func)(void *buffer);

// We only provide non-HW-W here, as ndless without nl_lcd_blit won't run on HW-W anyway
static void lcd_blit_320x240_320x240(void *buffer)
{
    memcpy(SCREEN_BASE_ADDRESS, buffer, 320 * 240 * sizeof(uint16_t));
}

void lcd_blit(void *buffer, scr_type_t buffer_type)
{
    static lcd_blit_func lcd_blit_cache[SCR_TYPE_COUNT] = {0};

    if (lcd_blit_cache[buffer_type])
        return lcd_blit_cache[buffer_type](buffer);

    if (nl_ndless_rev() >= 2004)
        lcd_blit_cache[buffer_type] = syscall<e_nl_lcd_blit, lcd_blit_func>(buffer_type);
    else if (buffer_type == SCR_320x240_565)
        lcd_blit_cache[buffer_type] = lcd_blit_320x240_320x240;

    if (lcd_blit_cache[buffer_type])
        return lcd_blit_cache[buffer_type](buffer);
    /* else what? */
}
