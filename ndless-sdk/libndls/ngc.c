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
 * The Initial Developer of the Original Code is Levak
 * Portions created by the Initial Developer are Copyright (C) 2013
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s): lkj
 ****************************************************************************/

#include <ngc.h>

void gui_gc_blit_to_screen(Gc gc)
{
    char * off_screen = (((((char *****)gc)[9])[0])[0x8])[0];
    memcpy(SCREEN_BASE_ADDRESS, off_screen, SCREEN_BYTES_SIZE);
}

void gui_gc_blit_to_screen_region(Gc gc, unsigned x, unsigned y, unsigned w, unsigned h)
{
    unsigned W = SCREEN_WIDTH;
    char ** off_buff = ((((char *****)gc)[9])[0])[0x8];
    char * buff = SCREEN_BASE_ADDRESS;

    h += y;
    (h > SCREEN_HEIGHT) && (h = SCREEN_HEIGHT);
    (x > SCREEN_WIDTH) && (x = SCREEN_WIDTH);
    (x + w > SCREEN_WIDTH) && (w = SCREEN_WIDTH - x);

    switch (lcd_isincolor())
    {
        case 1:
            x <<= 1;
            w <<= 1;
            W <<= 1;
            break;
        default:
            x >>= 1;
            w >>= 1;
            W >>= 1;
    }

    for (; y < h; ++y)
        memcpy(buff + (y*W + x), off_buff[y] + x, w);
}
