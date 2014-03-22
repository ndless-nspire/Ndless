#include "tools.h"

#define CONTRAST_MIN	0x60
#define CONTRAST_MAX	0xC0

unsigned char* SCREEN_BASE_ADDR;

unsigned int getContrast();
void initScr();
void drwBufStr(unsigned char* buf, int x, int y, char* str, int ret, int trsp);
void putBufChar(unsigned char* buf, int x, int y, char ch, int trsp);
void setBufPixel(unsigned char* buf, int x, int y, unsigned int color);
void dispBufIMG(unsigned char* buf, int xoff, int yoff, char* img, int width, int height, float inc);
void clrBuf();