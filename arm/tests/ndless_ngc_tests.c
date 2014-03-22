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
 * Contributor(s): 
 ****************************************************************************/

#include <os.h>
#include <ngc.h>
#include "ndless_tests.h"

int main(void)
{
    Gc gc = *gui_gc_global_GC_ptr;

    assertNotNull("gui_gc_global_GC_ptr", gc);

    assertRuns("gui_gc_setRegion", gui_gc_setRegion(gc, 0, 0, 320, 240, 0, 0, 320, 240));
    assertRuns("gui_gc_begin", gui_gc_begin(gc));

    assertRuns("gui_gc_setColor", gui_gc_setColor(gc, 0xffffff));
    assertRuns("gui_gc_fillRect", gui_gc_fillRect(gc, 0, 0, 320, 240));

    assertRuns("gui_gc_clipRect", gui_gc_clipRect(gc, 15, 15, 10, 10, GC_CRO_SET));
    assertRuns("gui_gc_setColorRGB", gui_gc_setColorRGB(gc, 255, 0, 0));
    assertRuns("gui_gc_fillRect", gui_gc_fillRect(gc, 0, 0, 320, 240));
    assertRuns("gui_gc_clipRect", gui_gc_clipRect(gc, 0, 0, 0, 0, GC_CRO_RESET));
    assertRuns("gui_gc_setColor", gui_gc_setColor(gc, 0));
    assertRuns("gui_gc_drawString", gui_gc_drawString(gc, "c\0l\0i\0p\0R\0e\0c\0t\0 \0+\0 \0f\0i\0l\0l\0R\0e\0c\0t\0\0", 30, 10, GC_SM_TOP));

    assertRuns("gui_gc_setAlpha", gui_gc_setAlpha(gc, GC_A_HALF));
    assertRuns("gui_gc_setColor", gui_gc_setColor(gc, 0xff0000));
    assertRuns("gui_gc_fillRect", gui_gc_fillRect(gc, 15, 35, 10, 10));
    assertRuns("gui_gc_fillRect", gui_gc_fillRect(gc, 18, 40, 10, 10));
    assertRuns("gui_gc_setColor", gui_gc_setColor(gc, 0));
    assertRuns("gui_gc_drawString", gui_gc_drawString(gc, "s\0e\0t\0A\0l\0p\0h\0a\0 \0+\0 \0f\0i\0l\0l\0R\0e\0c\0t\0\0", 30, 30, GC_SM_TOP));
    assertRuns("gui_gc_setAlpha", gui_gc_setAlpha(gc, GC_A_OFF));

    assertRuns("gui_gc_setFont", gui_gc_setFont(gc, SerifBoldItalic12));
    assertIntEquals("gui_gc_getFont", gui_gc_getFont(gc), SerifBoldItalic12);
    assertRuns("gui_gc_drawString", gui_gc_drawString(gc, "F\0o\0o\0\0", 2, 50, GC_SM_TOP));
    assertRuns("gui_gc_setFont", gui_gc_setFont(gc, Regular11));
    assertRuns("gui_gc_drawString", gui_gc_drawString(gc, "s\0e\0t\0F\0o\0n\0t\0\0", 30, 50, GC_SM_TOP));

    assertRuns("gui_gc_setPen", gui_gc_setPen(gc, GC_PS_MEDIUM, GC_PM_DOTTED));
    assertRuns("gui_gc_drawLine", gui_gc_drawLine(gc, 10, 75, 30, 90));
    assertRuns("gui_gc_setPen", gui_gc_setPen(gc, GC_PS_THIN, GC_PM_SMOOTH));
    assertRuns("gui_gc_drawString", gui_gc_drawString(gc, "s\0e\0t\0P\0e\0n\0 \0+\0 \0d\0r\0a\0w\0L\0i\0n\0e\0\0", 30, 70, GC_SM_TOP));

    assertRuns("gui_gc_setColor", gui_gc_setColor(gc, 0xff0000));
    assertRuns("gui_gc_drawArc", gui_gc_drawArc(gc, 15, 95, 10, 10, 0, 3600));
    assertRuns("gui_gc_setColor", gui_gc_setColor(gc, 0));
    assertRuns("gui_gc_drawString", gui_gc_drawString(gc, "d\0r\0a\0w\0A\0r\0c\0\0", 30, 90, GC_SM_TOP));

    assertRuns("gui_gc_setColor", gui_gc_setColor(gc, 0xff0000));
    assertRuns("gui_gc_fillArc", gui_gc_fillArc(gc, 15, 115, 10, 10, 0, 3600));
    assertRuns("gui_gc_setColor", gui_gc_setColor(gc, 0));
    assertRuns("gui_gc_drawString", gui_gc_drawString(gc, "f\0i\0l\0l\0A\0r\0c\0\0", 30, 110, GC_SM_TOP));

    assertRuns("gui_gc_setColor", gui_gc_setColor(gc, 0xff0000));
    assertRuns("gui_gc_drawRect", gui_gc_drawRect(gc, 15, 135, 10, 10));
    assertRuns("gui_gc_setColor", gui_gc_setColor(gc, 0));
    assertRuns("gui_gc_drawString", gui_gc_drawString(gc, "d\0r\0a\0w\0R\0e\0c\0t\0\0", 30, 130, GC_SM_TOP));

    assertRuns("gui_gc_drawIcon", gui_gc_drawIcon(gc, RES_SYST, 0, 10, 155));
    assertRuns("gui_gc_drawString", gui_gc_drawString(gc, "d\0r\0a\0w\0I\0c\0o\0n\0\0", 30, 150, GC_SM_TOP));


    unsigned points[] = {1, 0, 2, 1, 3, 0, 4, 2, 0, 2, 1, 0};
    unsigned i;
    for (i = 0; i < 12; i += 2)
    {
        points[i] = points[i] * 4 + 10;
        points[i+1] = points[i+1] * 4 + 180;
    }

    assertRuns("gui_gc_setColor", gui_gc_setColor(gc, 0xff0000));
    assertRuns("gui_gc_drawPoly", gui_gc_drawPoly(gc, points, 6));
    assertRuns("gui_gc_setColor", gui_gc_setColor(gc, 0));
    assertRuns("gui_gc_drawString", gui_gc_drawString(gc, "d\0r\0a\0w\0P\0o\0l\0y\0\0", 30, 170, GC_SM_TOP));

    for (i = 1; i < 12; i += 2)
        points[i] += 20;

    assertRuns("gui_gc_setColor", gui_gc_setColor(gc, 0xff0000));
    assertRuns("gui_gc_fillPoly", gui_gc_fillPoly(gc, points, 6));
    assertRuns("gui_gc_setColor", gui_gc_setColor(gc, 0));
    assertRuns("gui_gc_drawString", gui_gc_drawString(gc, "f\0i\0l\0l\0P\0o\0l\0y\0\0", 30, 190, GC_SM_TOP));

    assertRuns("gui_gc_fillGradient", gui_gc_fillGradient(gc, 5, 215, 20, 13, 0x990000, 0xffffff, 1));
    assertRuns("gui_gc_setColor", gui_gc_setColor(gc, 0));
    assertRuns("gui_gc_drawString", gui_gc_drawString(gc, "f\0i\0l\0l\0G\0r\0a\0d\0i\0e\0n\0t\0\0", 30, 210, GC_SM_TOP));

    gui_gc_Image_header hdr = {.width = 15, .height = 15,
                               .empty = 0, .depth = 2, .enc = 1};
    hdr.buff_size = hdr.depth * hdr.width;
    unsigned size = hdr.buff_size * hdr.height;
    char * buff = calloc(size + sizeof (gui_gc_Image_header), 1);
    memcpy(buff, &hdr, sizeof (gui_gc_Image_header));
    memset(buff + sizeof (gui_gc_Image_header), 69, size);
    assertRuns("gui_gc_drawImage", gui_gc_drawImage(gc, buff, 110, 215));
    free(buff);
    assertRuns("gui_gc_setColor", gui_gc_setColor(gc, 0));
    assertRuns("gui_gc_drawString", gui_gc_drawString(gc, "d\0r\0a\0w\0I\0m\0a\0g\0e\0\0", 130, 210, GC_SM_TOP));


    char str[] = "H\0e\0l\0l\0o\0\0";
    unsigned l = sizeof (str) / 2 - 1;

    gui_gc_Font f = gui_gc_getFont(gc);
    assertIntEquals("gui_gc_getStringWidth", gui_gc_getStringWidth(gc, f, str, 0, l), 33);
    assertIntEquals("gui_gc_getCharWidth", gui_gc_getCharWidth(gc, f, str[0]), 11);
    assertIntEquals("gui_gc_getStringSmallHeight", gui_gc_getStringSmallHeight(gc, f, str, 0, l), 16);
    assertIntEquals("gui_gc_getCharHeight", gui_gc_getCharHeight(gc, f, str[0]), 16);
    assertIntEquals("gui_gc_getStringHeight", gui_gc_getStringHeight(gc, f, str, 0, l), 21);
    assertIntEquals("gui_gc_getFontHeight", gui_gc_getFontHeight(gc, f), 21);

    gui_gc_drawString(gc, "M\0e\0t\0r\0i\0c\0s\0:\0\0", 180, 10, GC_SM_TOP);
    gui_gc_drawString(gc, str, 240, 12, GC_SM_TOP);
    unsigned sw = gui_gc_getStringWidth(gc, f, str, 0, l);
    unsigned sh = gui_gc_getCharHeight(gc, f, str[0]);
    gui_gc_drawRect(gc, 240, 12, sw, sh);

    unsigned w, h;
    assertRuns("gui_gc_getIconSize", gui_gc_getIconSize(gc, RES_SYST, 0, &w, &h));
    assertIntEquals("gui_gc_getIconSize", w, 16);
    assertIntEquals("gui_gc_getIconSize", h, 16);

    Gc copy;
    assertNotNull("gui_gc_copy", (copy = gui_gc_copy(gc, 128, 96)));
    assertRuns("gui_gc_blit_gc", gui_gc_blit_gc(gc, 0, 0, 320, 240, copy, 0, 0, 128, 96));
    gui_gc_drawString(gc, "b\0l\0i\0t\0_\0g\0c\0:\0\0", 180, 80, GC_SM_TOP);
    assertRuns("gui_gc_blit_gc", gui_gc_blit_gc(copy, 0, 0, 128, 96, gc, 150, 100, 128, 96));
    assertRuns("gui_gc_free", gui_gc_free(copy));


    copy = gui_gc_copy(gc, 15, 15);
    size = 15 * 15 * 2;
    if (!lcd_isincolor()) size <<= 2;
    buff = calloc(size, 1);
    memset(buff, 0x44, size);
    assertRuns("gui_gc_blit_buffer", gui_gc_blit_buffer(copy, buff, 0, 0, 15, 15)); /* actually draws nothing because it needs to be 320x240 */
    gui_gc_blit_gc(copy, 0, 0, 15, 15, gc, 215, 215, 15, 15);
    gui_gc_drawString(gc, "b\0l\0i\0t\0_\0b\0u\0f\0f\0e\0r\0\0", 235, 210, GC_SM_TOP);
    free(buff);
    gui_gc_free(copy);

    assertRuns("gui_gc_finish", gui_gc_finish(gc));

    assertRuns("gui_gc_blit_to_screen", gui_gc_blit_to_screen(gc));
    assertRuns("gui_gc_blit_to_screen_region", gui_gc_blit_to_screen_region(gc, 0, 0, 10, 10));

	if (!errcount) {
		puts("Successful!");
	}
	else
		printf("%u test(s) failed.\n", errcount);

    wait_key_pressed();
    return 0;
}
