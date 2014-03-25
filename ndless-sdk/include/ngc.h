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

#ifndef _NGC_H_
#define _NGC_H_

#include <os.h>
#include <libndls.h>

typedef enum {
    GC_CRO_RESET = 0,
    GC_CRO_SET = 1,
    GC_CRO_INTERSECT = 2,
    GC_CRO_NULL = 3
} gui_gc_ClipRectOp;

typedef enum {
    GC_A_OFF = 255,
    GC_A_HALF = 128,
} gui_gc_Alpha;

typedef enum {
    GC_PM_SMOOTH = 0,
    GC_PM_DOTTED = 1,
    GC_PM_DASHED = 2,
} gui_gc_PenMode;

typedef enum {
    GC_PS_THIN = 0,
    GC_PS_MEDIUM = 1,
    GC_PS_THICK = 2,
} gui_gc_PenSize;

typedef enum {
    GC_SM_NORMAL = 1,
    GC_SM_SHRINK = 2,
    GC_SM_OVERLAP = 3, // bug ?

    GC_SM_BASELINE = 1 << 4,
    GC_SM_BOTTOM = 2 << 4,
    GC_SM_MIDDLE = 3 << 4,
    GC_SM_TOP = 4 << 4,

    GC_SM_RIGHT = 1 << 8,
    GC_SM_DOWN = 2 << 8,
    GC_SM_LEFT = 3 << 8,
} gui_gc_StringMode;
/*
** ex: GC_SM_MIDDLE | GC_SM_SHRINK
** Notice: Mode 0 is equivalent to GC_SM_NORMAL | GC_SM_TOP
** Notice: Rotations (right/down/left) set by default mode 0
*/

typedef struct
{
    short width;
    short height;
    char * pixels;
} gui_gc_Sprite;

typedef struct
{
    unsigned width;
    unsigned height;
    unsigned empty; /* 0 */
    unsigned buff_size; /* depth * width */
    short depth; /* 2 */
    short enc; /* 1 */
} gui_gc_Image_header;

typedef enum {
    /*                sib--size--  */
    Regular9  =     0b00000001001, SerifRegular9  =     0b10000001001,
    Regular10 =     0b00000001010, SerifRegular10 =     0b10000001010,
    Regular11 =     0b00000001011, SerifRegular11 =     0b10000001011,
    Regular12 =     0b00000001100, SerifRegular12 =     0b10000001100,
    Bold9  =        0b00100001001, SerifBold9  =        0b10100001001,
    Bold10 =        0b00100001010, SerifBold10 =        0b10100001010,
    Bold11 =        0b00100001011, SerifBold11 =        0b10100001011,
    Bold12 =        0b00100001100, SerifBold12 =        0b10100001100,
    Italic9  =      0b01000001001, SerifItalic9  =      0b11000001001,
    Italic10 =      0b01000001010, SerifItalic10 =      0b11000001010,
    Italic11 =      0b01000001011, SerifItalic11 =      0b11000001011,
    Italic12 =      0b01000001100, SerifItalic12 =      0b11000001100,
    BoldItalic9  =  0b01100001001, SerifBoldItalic9  =  0b11100001001,
    BoldItalic10 =  0b01100001010, SerifBoldItalic10 =  0b11100001010,
    BoldItalic11 =  0b01100001011, SerifBoldItalic11 =  0b11100001011,
    BoldItalic12 =  0b01100001100, SerifBoldItalic12 =  0b11100001100,
    SerifBold24  =  0b10100011000, SerifRegular7     =  0b10000000111,
} gui_gc_Font;


typedef void ** Gc;

/* from gui_gc_getGC */
/* CAUTION: cache this value */
_SYSCALL_OSVAR(Gc *, gui_gc_global_GC_ptr)
#define gui_gc_global_GC_ptr gui_gc_global_GC_ptr()

/*********************************/
/*     Init/Dispose functions    */
/*********************************/

_SYSCALL1(void, gui_gc_free, Gc)
_SYSCALL3(Gc, gui_gc_copy, Gc, int /* w */, int /* h */)
_SYSCALL1(int, gui_gc_begin, Gc)
_SYSCALL1(void, gui_gc_finish, Gc)

/*********************************/
/* Set/Get Attributes functions  */
/*********************************/

_SYSCALL(void, gui_gc_clipRect, Gc gc, int x, int y, int w, int h, gui_gc_ClipRectOp op) _SYSCALL_ARGS(void, gui_gc_clipRect, gc, x, y, w, h, op)
_SYSCALL4(void, gui_gc_setColorRGB, Gc, int /* r */, int /* g */, int /* b */)
_SYSCALL2(void, gui_gc_setColor, Gc, int /* 0xRRGGBB */)
_SYSCALL2(void, gui_gc_setAlpha, Gc, gui_gc_Alpha)
_SYSCALL2(void, gui_gc_setFont, Gc, gui_gc_Font)
_SYSCALL1(gui_gc_Font, gui_gc_getFont, Gc)
_SYSCALL3(void, gui_gc_setPen, Gc, gui_gc_PenSize, gui_gc_PenMode)

/* Position and size (x, y, w, h) of the current GC related to a given offset from the screen (xs, ys, ws, hs) */
/* CAUTION: Doesn't affect Strings nor Arcs */
_SYSCALL(void, gui_gc_setRegion, Gc gc, int xs, int ys, int ws, int hs, int x, int y, int w, int h) _SYSCALL_ARGS(void, gui_gc_setRegion, gc, xs, ys, ws, hs, x, y, w, h)

/*********************************/
/*         Draw functions        */
/*********************************/

/* Notice: start and end angles have to be multiplied by 10 */
_SYSCALL(void, gui_gc_drawArc, Gc gc, int x, int y, int w, int h, int start, int end) _SYSCALL_ARGS(void, gui_gc_drawArc, gc, x, y, w, h, start, end)

_SYSCALL(void, gui_gc_drawIcon, Gc gc, e_resourceID res, int icon, int x, int y) _SYSCALL_ARGS(void, gui_gc_drawIcon, gc, res, icon, x, y)
_SYSCALL4(void, gui_gc_drawSprite, Gc, gui_gc_Sprite *, int /* x */, int /* y */)
_SYSCALL(void, gui_gc_drawLine, Gc gc, int x1, int y1, int x2, int y2) _SYSCALL_ARGS(void, gui_gc_drawLine, gc, x1, y1, x2, y2)
_SYSCALL(void, gui_gc_drawRect, Gc gc, int x, int y, int w, int h) _SYSCALL_ARGS(void, gui_gc_drawRect, gc, x, y, w, h)
_SYSCALL(void, gui_gc_drawString, Gc gc, char *utf16, int x, int y, gui_gc_StringMode mode) _SYSCALL_ARGS(void, gui_gc_drawString, gc, utf16, x, y, mode)
_SYSCALL3(void, gui_gc_drawPoly, Gc, unsigned * /* points */, unsigned /* count */)

/* Notice: start and end angles have to be multiplied by 10 */
_SYSCALL(void, gui_gc_fillArc, Gc gc, int x, int y, int w, int h, int start, int end) _SYSCALL_ARGS(void, gui_gc_fillArc, gc, x, y, w, h, start, end)

_SYSCALL3(void, gui_gc_fillPoly, Gc, unsigned * /* points */, unsigned /* count */)
_SYSCALL(void, gui_gc_fillRect, Gc gc, int x, int y, int w, int h) _SYSCALL_ARGS(void, gui_gc_fillRect, gc, x, y, w, h)

/* CAUTION: do not go over 239 of height. It may freeze somehow the OS after exit */
/* CAUTION: works if you're lucky on your color choice ! */
_SYSCALL(void, gui_gc_fillGradient, Gc gc, int x, int y, int w, int h, int start_color, int end_color, int vertical) _SYSCALL_ARGS(void, gui_gc_fillGradient, gc, x, y, w, h, start_color, end_color, vertical)

_SYSCALL4(void, gui_gc_drawImage, Gc, char * /* TI_Image */, int /* x */, int /* y */)

/*********************************/
/*        Metric functions       */
/*********************************/

_SYSCALL(int, gui_gc_getStringWidth, Gc gc, gui_gc_Font font, char *utf16, int start, int length) _SYSCALL_ARGS(int, gui_gc_getStringWidth, gc, font, utf16, start, length)
_SYSCALL3(int, gui_gc_getCharWidth, Gc, gui_gc_Font, short /* utf16 char */)
_SYSCALL(int, gui_gc_getStringSmallHeight, Gc gc, gui_gc_Font font, char *utf16, int start, int length) _SYSCALL_ARGS(int, gui_gc_getStringSmallHeight, gc, font, utf16, start, length)
_SYSCALL3(int, gui_gc_getCharHeight, Gc, gui_gc_Font, short /* utf16 char */)
_SYSCALL(int, gui_gc_getStringHeight, Gc gc, gui_gc_Font font, char *utf16, int start, int length) _SYSCALL_ARGS(int, gui_gc_getStringHeight, gc, font, utf16, start, length)
_SYSCALL2(int, gui_gc_getFontHeight, Gc, gui_gc_Font)
_SYSCALL(int, gui_gc_getIconSize, Gc gc, e_resourceID res, unsigned icon, unsigned *w, unsigned *h) _SYSCALL_ARGS(int, gui_gc_getIconSize, gc, res, icon, w, h)

/*********************************/
/*         Blit functions        */
/*********************************/

_SYSCALL(void, gui_gc_blit_gc, Gc source, int xs, int ys, int ws, int hs, Gc dest, int xd, int yd, int wd, int hd) _SYSCALL_ARGS(void, gui_gc_blit_gc, source, xs, ys, ws, hs, dest, xd, yd, wd, hd)

/* CAUTION: w and h SHOULD be exactly of gc's w and gc's h (i.e. 320x240 in general). If not, nothing is drawn */
/* CAUTION: buffer has to be the same size of SCREEN_BYTES_SIZE (i.e. platform dependant) */
_SYSCALL(void, gui_gc_blit_buffer, Gc gc, char * buffer, int x, int y, int w, int h) _SYSCALL_ARGS(void, gui_gc_blit_buffer, gc, buffer, x, y, w, h)

void gui_gc_blit_to_screen(Gc gc);
void gui_gc_blit_to_screen_region(Gc gc, unsigned x, unsigned y, unsigned w, unsigned h);

#endif /* !_NGC_H_ */
