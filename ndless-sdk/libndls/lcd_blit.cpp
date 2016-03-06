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
static void lcd_blit_320x240_320x240_565(void *buffer)
{
    memcpy(REAL_SCREEN_BASE_ADDRESS, buffer, 320 * 240 * sizeof(uint16_t));
}

static void lcd_blit_320x240_320x240_8(void *buffer)
{
    memcpy(REAL_SCREEN_BASE_ADDRESS, buffer, 320 * 240);
}

static void lcd_blit_320x240_320x240_4(void *buffer)
{
    memcpy(REAL_SCREEN_BASE_ADDRESS, buffer, (320 * 240) / 2);
}

void lcd_blit(void *buffer, scr_type_t buffer_type)
{
    static lcd_blit_func lcd_blit_cache[SCR_TYPE_COUNT] = {0};

    if (lcd_blit_cache[buffer_type])
        return lcd_blit_cache[buffer_type](buffer);

    if (nl_ndless_rev() >= 2004)
        lcd_blit_cache[buffer_type] = syscall<e_nl_lcd_blit, lcd_blit_func>(buffer_type);
    else if (buffer_type == SCR_320x240_565 || buffer_type == SCR_320x240_16)
        lcd_blit_cache[buffer_type] = lcd_blit_320x240_320x240_565;
    else if (buffer_type == SCR_320x240_8)
        lcd_blit_cache[buffer_type] = lcd_blit_320x240_320x240_8;
    else if (buffer_type == SCR_320x240_4)
        lcd_blit_cache[buffer_type] = lcd_blit_320x240_320x240_4;

    if (lcd_blit_cache[buffer_type])
        return lcd_blit_cache[buffer_type](buffer);
    /* else what? */
}

scr_type_t lcd_type()
{
    scr_type_t ret = SCR_TYPE_INVALID;

    if (nl_ndless_rev() >= 2004)
    {
        ret = syscall<e_nl_lcd_type, scr_type_t>();
        return ret > SCR_TYPE_COUNT ? SCR_TYPE_INVALID : ret;
    }

    // Pre Ndless 4.2 r2004 here, so only classic calcs and CX < HW-W.
    if (has_colors)
        return SCR_320x240_565;
    else
        return SCR_320x240_4;
}

static void set_lcd_mode(unsigned int mode)
{
    uint32_t control = *IO_LCD_CONTROL;
    control &= ~0b1110;
    control |= mode << 1;
    *IO_LCD_CONTROL = control;
}

bool lcd_init(scr_type_t type)
{
    if (nl_ndless_rev() >= 2004)
        return syscall<e_nl_lcd_init, bool>(type);

    // Pre Ndless 4.2 r2004 here, so only classic calcs and CX < HW-W.

    static void *old_buffer = NULL;

    // Switch to orginal buffer first to free the allocated space
    if(old_buffer && type != SCR_TYPE_INVALID)
        lcd_init(SCR_TYPE_INVALID);

    switch(type)
    {
    case SCR_TYPE_INVALID:
        if(old_buffer)
        {
            void *new_buffer = REAL_SCREEN_BASE_ADDRESS;
            REAL_SCREEN_BASE_ADDRESS = old_buffer;
            old_buffer = NULL;
            free(new_buffer);
        }
        if(has_colors)
            set_lcd_mode(6);
        else
            set_lcd_mode(2);
        return true;
    case SCR_320x240_4:
        // No need to allocate a new buffer
        set_lcd_mode(2);
        return true;
    case SCR_320x240_8:
    {
        if (!has_colors)
        {
            // Need more space
            old_buffer = REAL_SCREEN_BASE_ADDRESS;
            void *new_buffer = calloc(320*240, sizeof(uint8_t));
            if(!new_buffer)
                return old_buffer = NULL, false;
            REAL_SCREEN_BASE_ADDRESS = new_buffer;
        }

        set_lcd_mode(3);
        return true;
    }
    case SCR_320x240_16:
    case SCR_320x240_565:
    {
        if (!has_colors)
        {
            // Need more space
            old_buffer = REAL_SCREEN_BASE_ADDRESS;
            void *new_buffer = calloc(320*240, sizeof(uint16_t));
            if(!new_buffer)
                return old_buffer = NULL, false;
            REAL_SCREEN_BASE_ADDRESS = new_buffer;

            set_lcd_mode(4);
        }
        else
            set_lcd_mode(6);

        return true;
    }
    case SCR_240x320_565: // Only implemented on HW-W
    default:
        return false;
    }
}
