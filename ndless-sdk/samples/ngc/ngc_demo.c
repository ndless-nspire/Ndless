#include <os.h>
#include <libndls.h>
#include <ngc.h>

int main() {

	Gc gc = gui_gc_global_GC();

    { /* Nice window */

        gui_gc_Sprite * s = malloc(sizeof(gui_gc_Sprite));
        s->width = 32;
        s->height = 13;
        s->pixels = (char []) {
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x00,
            0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0xFF,
            0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0x00, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0x00, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00,
            0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00,
            0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00,
            0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0xFF,
            0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00,
            0x00, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0xFF,
            0xFF, 0xFF, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0xFF,
            0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x00,
        };

        gui_gc_begin(gc);
        gui_gc_setRegion(gc, 0, 0, 320, 240, 0, 0, 320, 240);
        gui_gc_clipRect(gc, 0, 0, 320, 240, GC_CRO_SET);

        gui_gc_setAlpha(gc, GC_A_HALF);
        gui_gc_setColorRGB(gc, 50, 50, 50);
        gui_gc_fillRect(gc, 0, 0, 320, 240 -23);
        gui_gc_fillRect(gc, 8, 8, 306, 224 -23);
        gui_gc_fillRect(gc, 6, 6, 310, 228 -23);
        gui_gc_fillRect(gc, 4, 4, 314, 232 -23);
        gui_gc_fillRect(gc, 2, 2, 318, 236 -23);
        gui_gc_setAlpha(gc, GC_A_OFF);
        gui_gc_fillGradient(gc, 10, 10, 300, 227 -23, 0xFFFFFF, 0xA0A0A0, 0);
        gui_gc_fillGradient(gc, 20, 60, 280, 207 -23, 0xA0A0A0, 0xFFFFFF, 0);

        gui_gc_setColorRGB(gc, 100, 100, 100);
        gui_gc_fillArc(gc, 13, 13, 8, 8, 0, 3600);
        gui_gc_fillArc(gc, 300, 13, 8, 8, 0, 3600);
        gui_gc_fillArc(gc, 13, 218 -23, 8, 8, 0, 3600);
        gui_gc_fillArc(gc, 300, 218 -23, 8, 8, 0, 3600);

        gui_gc_setColorRGB(gc, 200, 200, 200);
        gui_gc_fillArc(gc, 14, 14, 6, 6, 0, 3600);
        gui_gc_fillArc(gc, 301, 14, 6, 6, 0, 3600);
        gui_gc_fillArc(gc, 14, 219 -23, 6, 6, 0, 3600);
        gui_gc_fillArc(gc, 301, 219 -23, 6, 6, 0, 3600);

        gui_gc_setColorRGB(gc, 0, 0, 0);
        gui_gc_drawRect(gc, 10, 10, 300, 218 -23);
        gui_gc_drawRect(gc, 20, 60, 280, 148 -23);
        gui_gc_setColorRGB(gc, 20, 20, 20);
        gui_gc_drawLine(gc, 21, 61, 299, 61);
        gui_gc_setFont(gc, 24);
        gui_gc_setColorRGB(gc, 100, 100, 100);
        gui_gc_drawLine(gc, 21, 207 -23, 299, 207 -23);
        gui_gc_setColorRGB(gc, 30, 30, 30);

        gui_gc_setColorRGB(gc, 200, 0, 0);
        gui_gc_drawSprite(gc, s, 260, 47);

        gui_gc_setColorRGB(gc, 0, 0, 0);
        gui_gc_drawString(gc, "P\0r\0o\0b\0l\0e\0m\0 \0?\0\0", 20, 50, 0x0);
        gui_gc_setColorRGB(gc, 100, 100, 100);
        gui_gc_setFont(gc, SerifBoldItalic10);
        gui_gc_drawString(gc, "W\0h\0a\0t\0 \0a\0 \0q\0u\0e\0s\0t\0i\0o\0n\0 \0!\0\0", 20, 55, 0x0);
        gui_gc_clipRect(gc, 0, 0, 0, 0, GC_CRO_RESET);
        gui_gc_finish(gc);

        free(s);
    }

    gui_gc_blit_to_screen(gc);
    wait_key_pressed();

    { /* off-screen buffer */

	gui_gc_begin(gc);
        gui_gc_setFont(gc, Italic10);

        { /* Custom off-screen buffer */
            unsigned size = SCREEN_BYTES_SIZE;
            char * buff = calloc(size * sizeof (char), 1);
            memset(buff, 0x44, size);
            gui_gc_blit_buffer(gc, buff, 0, 0, 320, 240);
            free(buff);

            gui_gc_setColorRGB(gc, 255, 255, 255);
            gui_gc_drawString(gc, "O\0f\0f\0-\0s\0c\0r\0e\0e\0n\0 \0b\0u\0f\0f\0e\0r\0\0", 20, 20, 0);
        }

        { /* Normal draw using primitives */
            gui_gc_setColorRGB(gc, 0, 0, 255);
            gui_gc_fillRect(gc, 30, 30, 320 -60, 240 -60);

            gui_gc_setColorRGB(gc, 255, 255, 255);
            gui_gc_drawString(gc, "G\0C\0-\0r\0e\0c\0t\0\0", 50, 50, 0);
        }

        { /* Drawing using a TI.Image */
            gui_gc_Image_header hdr = {.width = 320 - 120, .height = 240 - 120,
                                       .empty = 0, .depth = 2, .enc = 1};
            hdr.buff_size = hdr.depth * hdr.width;
            unsigned size = hdr.buff_size * hdr.height;
            char * buff = calloc(size + sizeof (gui_gc_Image_header), 1);
            memcpy(buff, &hdr, sizeof (gui_gc_Image_header));
            memset(buff + sizeof (gui_gc_Image_header), 69, size);
            gui_gc_drawImage(gc, buff, 60, 60);

            gui_gc_setColorRGB(gc, 255, 255, 255);
            gui_gc_drawString(gc, "T\0I\0.\0I\0m\0a\0g\0e\0\0", 80, 80, 0);
            free(buff);
        }

        { /* Streching an existing GC */
            unsigned width = 320 - 180;
            unsigned height = 240 - 180;

            Gc copy = gui_gc_copy(gc, 320, 217);
            gui_gc_begin(copy);
            gui_gc_blit_gc(gc, 0, 0, 320, 240, copy, 0, 0, width, height);
            gui_gc_finish(copy);

            gui_gc_blit_gc(copy, 0, 0, width, height, gc, 90, 90, width, height);
            gui_gc_free(copy);

            gui_gc_setColorRGB(gc, 255, 255, 255);
            gui_gc_drawString(gc, "G\0C\0-\0B\0l\0i\0t\0\0", 110, 110, 0);
        }

        gui_gc_finish(gc);
    }

    gui_gc_blit_to_screen(gc);
    wait_key_pressed();

    { /* Interacting with the GC buffer */
        gui_gc_begin(gc);

        char * buf = ((char *****)gc)[9][0][8][0];
        memset(buf, 0xff, SCREEN_BYTES_SIZE);
        gui_gc_drawString(gc, "m\0e\0m\0s\0e\0t\0\0", 20, 20, 0);

        gui_gc_setColorRGB(gc, 255, 0, 0);
        gui_gc_fillRect(gc, 50, 50, 220, 140);
        gui_gc_setColorRGB(gc, 255, 255, 255);
        gui_gc_drawString(gc, "f\0i\0l\0l\0R\0e\0c\0t\0\0", 70, 70, 0);

        gui_gc_finish(gc);
    }

    gui_gc_blit_to_screen(gc);
    wait_key_pressed();

    { /* drawString flag tests */

        gui_gc_begin(gc);
        gui_gc_setColorRGB(gc, 255, 255, 255);
        gui_gc_fillRect(gc, 0, 0, 320, 240);
        gui_gc_setFont(gc, Bold9);

        unsigned x, y, r;
        char * text = "L\0o\0l\0\0";
        for (x = 1; x <= 3; ++x)
        {
            for (y = 1; y <= 4; ++y)
            {
                for (r = 0; r <= 3; ++r)
                {
                    int xoff = (x-1 + (y-1) * 3) * 26 + 15;
                    int yoff = r * 50 + 50;
                    int flag = x | (y << 4) | (r << 8);

                    gui_gc_setColorRGB(gc, 0, 0, 0);
                    gui_gc_drawLine(gc, xoff, yoff, xoff + 26, yoff);
                    gui_gc_drawLine(gc, xoff, yoff - 10, xoff, yoff + 10);
                    gui_gc_setColorRGB(gc, 255, 0, 0);
                    gui_gc_drawString(gc, text, xoff, yoff, flag);
                }
            }
        }
        gui_gc_finish(gc);

    }

    gui_gc_blit_to_screen(gc);
    wait_key_pressed();

    { /* Animation */

        typedef struct {
            unsigned short x;
            unsigned short y;
            signed   short dx;
            signed   short dy;
        } ball;

        unsigned short w = 10, h = 10;
        unsigned nball = 50;
        ball balls[nball];
        unsigned i;
        unsigned bg, fg;

        if (lcd_isincolor())
            bg = 0x0000ff, fg = 0xff0000;
        else
            bg = 0xffffff, fg = 0x000000;

        for (i = 0; i < nball; ++i)
            balls[i] = (ball) {.x = rand() % 320, .y = rand() % 240,
                        .dx = rand() % 10 - 5, .dy = rand() % 10 - 5};

        gui_gc_begin(gc);

        gui_gc_setColor(gc, bg);
        gui_gc_fillRect(gc, 0, 0, 320, 240);
        gui_gc_blit_to_screen(gc);

        wait_no_key_pressed();
        while (!any_key_pressed())
        {
            gui_gc_setColor(gc, bg);
            gui_gc_fillRect(gc, 0, 0, 320, 240);

            gui_gc_setColor(gc, fg);
            for (i = 0; i < nball; ++i)
            {
                unsigned short x = balls[i].x;
                unsigned short y = balls[i].y;
                signed short dx = balls[i].dx;
                signed short dy = balls[i].dy;

                if ((x + dx > 320 - w && dx > 0) || (x + dx < w && dx < 0))
                    dx = -dx;
                if ((y + dy > 240 - h && dy > 0) || (y + dy < h && dy < 0))
                    dy = -dy;

                balls[i].x = x += dx;
                balls[i].y = y += dy;
                balls[i].dx = dx;
                balls[i].dy = dy;

                gui_gc_fillArc(gc, x, y, w, h, 0, 3600);
            }

            gui_gc_blit_to_screen(gc);
            msleep(50);
        }
        gui_gc_finish(gc);

    }

    { /* 3D engine */

        typedef signed short coord;
        typedef signed int  lcoord;
        typedef struct {
            coord x;
            coord y;
            coord z;
        } point3D;

        typedef struct {
            unsigned int x;
            unsigned int y;
        } point2D;

        typedef unsigned short pid;
        typedef struct {
            pid p1;
            pid p2;
            pid p3;
            pid p4;
        } face;

        /* Cube */
        point3D points[] = {
            {.x=1, .y=1, .z=1}, {.x=1, .y=-1, .z=1}, {.x=-1, .y=-1, .z=1},
            {.x=-1, .y=1, .z=1}, {.x=1, .y=1, .z=-1}, {.x=1, .y=-1, .z=-1},
            {.x=-1, .y=-1, .z=-1}, {.x=-1, .y=1, .z=-1},
        };
        unsigned short npoints = sizeof (points) / sizeof (point3D);

        face faces[] = {
            {.p1=0, .p2=1, .p3=2, .p4=3}, {.p1=0, .p2=4, .p3=5, .p4=1},
            {.p1=4, .p2=7, .p3=6, .p4=5}, {.p1=3, .p2=7, .p3=6, .p4=2},
            {.p1=0, .p2=3, .p3=7, .p4=4}, {.p1=1, .p2=5, .p3=6, .p4=2},
        };
        unsigned short nfaces = sizeof (faces) / sizeof (face);

        static coord sin_mult = 10000;
        static coord sin_tbl[] = {
            0,174,348,523,697,871,1045,1218,1391,1564,1736,1908,2079,2249,
            2419,2588,2756,2923,3090,3255,3420,3583,3746,3907,4067,4226,
            4383,4539,4694,4848,5000,5150,5299,5446,5591,5735,5877,6018,
            6156,6293,6427,6560,6691,6819,6946,7071,7193,7313,7431,7547,
            7660,7771,7880,7986,8090,8191,8290,8386,8480,8571,8660,8746,
            8829,8910,8987,9063,9135,9205,9271,9335,9396,9455,9510,9563,
            9612,9659,9702,9743,9781,9816,9848,9876,9902,9925,9945,9961,
            9975,9986,9993,9998,10000
        };

        coord sin(unsigned a)
        {
            switch (a / 90)
            {
                case 0:  return sin_tbl[a];
                case 1:  return sin_tbl[180 - a];
                case 2:  return - sin_tbl[a - 180];
                default: return - sin_tbl[360 - a];
            }
        }

        coord cos(unsigned a)
        {
            switch (a / 90)
            {
                case 0:  return sin_tbl[90 - a];
                case 1:  return - sin_tbl[a - 90];
                case 2:  return - sin_tbl[270 - a];
                default: return sin_tbl[a - 270];
            }
        }

        coord xmin = -160;
        coord ymax = 120;
        coord zoff = 10;
        coord scale = 30;

        coord xrot = 0;
        coord yrot = 0;
        coord zrot = 0;

        gui_gc_begin(gc);

        /* Clear screen */
        gui_gc_setColorRGB(gc, 255, 255, 255);
        gui_gc_fillRect(gc, 0, 0, 320, 240);
        gui_gc_blit_to_screen(gc);

        unsigned last_rtc = 0;
        unsigned fps = 0;
        String fps_str = string_new();
        char * fps_format = "F\0P\0S\0:\0%\0d\0\0";

        wait_no_key_pressed();
        while (1)
        {
            /* Precompute rotation matrix */
            lcoord cx = cos(xrot), cy = cos(yrot), cz = cos(zrot);
            lcoord sx = sin(xrot), sy = sin(yrot), sz = sin(zrot);
            lcoord m[] = {
                (cy*cz - (sx*sy / sin_mult * sz)) / sin_mult,
                -cx*sz / sin_mult,
                (sy*cz + (sx*cy / sin_mult * sz)) / sin_mult,

                (cy*sz + (sx*sy / sin_mult * cz)) / sin_mult,
                cx*cz / sin_mult,
                (sy*sz - (sx*cy / sin_mult * cz)) / sin_mult,

                -cx*sy / sin_mult,
                sx,
                cx*cy / sin_mult,
            };

            unsigned i;
            point2D proj[npoints];
            for (i = 0; i < npoints; ++i)
            {
                lcoord xs = points[i].x;
                lcoord ys = points[i].y;
                lcoord zs = points[i].z;

                /* Rotate */
                lcoord x = xs*m[0] + ys*m[1] + zs*m[2];
                lcoord y = xs*m[3] + ys*m[4] + zs*m[5];
                lcoord z = xs*m[6] + ys*m[7] + zs*m[8];

                /* Project */
                lcoord zco = (z - zoff * sin_mult);
                proj[i].x = (scale * zoff * x) / zco - xmin;
                proj[i].y = ymax - (scale * zoff * y) / zco;
            }

            xrot = (xrot + 4) % 360;
            yrot = (xrot + 2) % 360;

            /* Draw */
            gui_gc_setColorRGB(gc, 255, 255, 255);
            gui_gc_fillRect(gc, 0, 0, 320, 240);

            gui_gc_setColorRGB(gc, 255, 0, 0);
            for (i = 0; i < nfaces; ++i)
            {
                point2D p[] = {
                    proj[faces[i].p1],
                    proj[faces[i].p2],
                    proj[faces[i].p3],
                    proj[faces[i].p4]
                };
                gui_gc_fillPoly(gc, (unsigned *)p, 4);
            }

            gui_gc_setColorRGB(gc, 0, 0, 0);
            for (i = 0; i < nfaces; ++i)
            {
                point2D p[] = {
                    proj[faces[i].p1],
                    proj[faces[i].p2],
                    proj[faces[i].p3],
                    proj[faces[i].p4]
                };
                gui_gc_drawLine(gc, p[0].x, p[0].y, p[3].x, p[3].y);
                gui_gc_drawLine(gc, p[0].x, p[0].y, p[1].x, p[1].y);
                gui_gc_drawLine(gc, p[2].x, p[2].y, p[1].x, p[1].y);
                gui_gc_drawLine(gc, p[2].x, p[2].y, p[3].x, p[3].y);
            }

            /* FPS */
            ++fps;
            unsigned rtc = *((unsigned*)0x90090000);
            if (last_rtc != rtc)
            {
                string_sprintf_utf16(fps_str, fps_format, fps);
                gui_gc_drawString(gc, fps_str->str, 0, 0, GC_SM_TOP);
                gui_gc_blit_to_screen_region(gc, 0, 0, 60, 20);
                last_rtc = rtc;
                fps = 0;
                if (any_key_pressed())
                    break;
            }

            /* Blit & sleep */
            gui_gc_blit_to_screen_region(gc, 90, 50, 140, 140);
            msleep(10);
        }

        gui_gc_finish(gc);
        string_free(fps_str);

    }

    return 0;
}
