/* freetype_demo.c                                                 */
/*                                                                 */
/* This small program shows how to print a rotated string with the */
/* FreeType 2 library.                                             */
/* Modified from example1.c from the FreeType tutorial.            */


#include <stdio.h>
#include <string.h>
#include <math.h>

#include <ft2build.h>
#include FT_FREETYPE_H
#include "gen_font_droid.h"


/* libndls.h stuff temporary copied here during the transition to newlib */
#define SCREEN_WIDTH            320
#define SCREEN_HEIGHT           240
void clrscr(void);
typedef enum BOOL {FALSE = 0, TRUE = 1} BOOL;
BOOL lcd_isincolor(void);
unsigned _scrsize(void);
void wait_key_pressed(void);
unsigned hwtype(void);
#define SCREEN_BASE_ADDRESS (void*)(*(volatile unsigned*)0xC0000010)
#define SCREEN_BYTES_SIZE       ((int)({_scrsize();}))

/* origin is the upper left corner */
volatile unsigned char *screen;

void
set_pixel( FT_Int         x,
           FT_Int         y,
	   unsigned char  r,
	   unsigned char  g,
	   unsigned char  b)
{
  if (x < 0 || y < 0 || x >= SCREEN_WIDTH || y >= SCREEN_HEIGHT)
    return;
  int pos = y * SCREEN_WIDTH + x;
  if (lcd_isincolor() && pos * 2 + 1 < SCREEN_BYTES_SIZE)
    ((volatile unsigned short*)screen)[pos] = ((r >> 3) << 11) | ((g >> 2) << 5) | (b >> 3);
  else if (pos % 2 == 0 && pos < 2 * SCREEN_BYTES_SIZE)
    screen[pos / 2] = (screen[pos / 2] & 0x0F) | ((((r + g + b) / 3) >> 4) << 4);
  else if (pos < 2 * SCREEN_BYTES_SIZE)
    screen[pos / 2] = (screen[pos / 2] & 0xF0) | (((r + g + b) / 3) >> 4);
}


void
draw_bitmap( FT_Bitmap*  bitmap,
             FT_Int      x,
             FT_Int      y)
{
  FT_Int  i, j, p, q, c;
  FT_Int  x_max = x + bitmap->width;
  FT_Int  y_max = y + bitmap->rows;

  for ( i = x, p = 0; i < x_max; i++, p++ )
  {
    for ( j = y, q = 0; j < y_max; j++, q++ )
    {
      if ( i < 0      || j < 0       ||
           i >= SCREEN_WIDTH || j >= SCREEN_HEIGHT )
        continue;

      c = bitmap->buffer[q * bitmap->width + p];

      if ( c > 0 )
           set_pixel(i, j, 255 - c, 255 - c, 255 - c);
    }
  }
}


int
main( int     argc,
      char**  argv )
{
  FT_Library    library;
  FT_Face       face;

  FT_GlyphSlot  slot;
  FT_Matrix     matrix;                 /* transformation matrix */
  FT_Vector     pen;                    /* untransformed origin  */
  FT_Error      error;

  double        angle;
  int           target_height;
  int           n, num_chars;


  char *text    = "Droid Sans";
  num_chars     = strlen( text );
  angle         = ( 25.0 / 360 ) * M_PI * 2;         /* use 25 degrees     */
  target_height = SCREEN_HEIGHT;
  screen = SCREEN_BASE_ADDRESS;                      /* address of the screen buffer */

  clrscr();                                          /* clear the screen   */

  error = FT_Init_FreeType( &library );              /* initialize library */
  /* error handling omitted */

  error = FT_New_Memory_Face( library, droid_DroidSans_ttf, droid_DroidSans_ttf_len, 0, &face ); /* create face object */
  /* error handling omitted */

  /* use 25pt at 100dpi */
  error = FT_Set_Char_Size( face, 25 * 64, 0,
                            100, 0 );                /* set character size */
  /* error handling omitted */

  slot = face->glyph;

  /* set up matrix */
  matrix.xx = (FT_Fixed)( cos( angle ) * 0x10000L );
  matrix.xy = (FT_Fixed)(-sin( angle ) * 0x10000L );
  matrix.yx = (FT_Fixed)( sin( angle ) * 0x10000L );
  matrix.yy = (FT_Fixed)( cos( angle ) * 0x10000L );

  /* the pen position in 26.6 cartesian space coordinates; */
  /* start at (150,100) relative to the upper left corner  */
  pen.x = 150 * 64;
  pen.y = ( target_height - 100 ) * 64;

  for ( n = 0; n < num_chars; n++ )
  {
    /* set transformation */
    FT_Set_Transform( face, &matrix, &pen );

    /* load glyph image into the slot (erase previous one) */
    error = FT_Load_Char( face, text[n], FT_LOAD_RENDER );
    if ( error )
      continue;                 /* ignore errors */

    /* now, draw to our target surface (convert position) */
    draw_bitmap( &slot->bitmap,
                 slot->bitmap_left,
                 target_height - slot->bitmap_top );

    /* increment pen position */
    pen.x += slot->advance.x;
    pen.y += slot->advance.y;
  }

  FT_Done_Face    ( face );
  FT_Done_FreeType( library );

  wait_key_pressed();           /* don't exit until a key is pressed */

  return 0;
}

/* EOF */
