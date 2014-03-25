#include <os.h>
#include "screen.h"
#include "charmap.h"
#define SCREEN_CONTRAST_ADDR 0x900F0020

#define SCREEN_BASE_PTR		0xC0000010 
#define SCREEN_MODE_ADDR	0xC000001C
#define SCREEN_INT_ADDR		0xC0000020
unsigned char* SCREEN_BASE_ADDR = 0;

#define SCREEN4_SIZE	SCREEN_WIDTH*SCREEN_HEIGHT/2
#define SCREEN16_SIZE	SCREEN_WIDTH*SCREEN_HEIGHT*2

int mode_bits=4;
unsigned char* addr=0;

void initScr()
{	SCREEN_BASE_ADDR	=*(unsigned char**)SCREEN_BASE_PTR;
	addr = SCREEN_BASE_ADDR;
	if(is_cx) mode_bits=16;
}

void setBufPixel(unsigned char* buf, int x, int y, unsigned int color)
{	if(x >= 0 && x < SCREEN_WIDTH && y >= 0 && y < SCREEN_HEIGHT)
		if(mode_bits==16)
		{	if(color==31) color=0b1111111111111111;
			buf[(y*SCREEN_WIDTH+x)*2]=(color&0b1111111100000000)>>8;
			buf[(y*SCREEN_WIDTH+x)*2+1]=color&0b0000000011111111;
		}
		else
		{	if(!is_cx) color = 31-color;
			unsigned char lowcolor = color>>1;
			buf[(y*SCREEN_WIDTH+x)/2]=(x&1)? (buf[(y*SCREEN_WIDTH+x)/2]&0xF0)|lowcolor : (buf[(y*SCREEN_WIDTH+x)/2]&0x0F)|(lowcolor<<4);
		}
}

void setBufPixelRGB(unsigned char* buf, int x, int y, unsigned int r, unsigned int g, unsigned int b)
{	if(x >= 0 && x < SCREEN_WIDTH && y >= 0 && y < SCREEN_HEIGHT)
		if(mode_bits==16)
		{	unsigned int color=(r<<11)|(g<<5)|b;
			buf[(y*SCREEN_WIDTH+x)*2]=color&0b0000000011111111;
			buf[(y*SCREEN_WIDTH+x)*2+1]=(color&0b1111111100000000)>>8;
		}
		else
		{	unsigned int color = (int)((r>>1)*.3F+(g>>2)*0.59F+(b>>1)*0.11F);
//			if(!is_cx && !color) color = 31-color;
			unsigned char lowcolor = color;//>>1;
			buf[(y*SCREEN_WIDTH+x)/2]=(x&1)? (buf[(y*SCREEN_WIDTH+x)/2]&0xF0)|lowcolor : (buf[(y*SCREEN_WIDTH+x)/2]&0x0F)|(lowcolor<<4);
		}
}

void putBufChar(unsigned char* buf, int x, int y, char ch, int trsp)
{
  int i, j, pixelOn;
  for(i = 0; i < CHAR_HEIGHT; i++)  
  {
    for(j = 0; j < CHAR_WIDTH; j++) 
    {
      pixelOn = charMap_ascii[(unsigned char)ch][i] << j ;  
      pixelOn = pixelOn & 0x80 ;  
      if (pixelOn) {
        if(trsp && is_cx)
		setBufPixel(buf,x + j, y + i, 0); 
	else
		setBufPixel(buf,x + j, y + i, 31); 
      } else if(!trsp) {
        setBufPixel(buf,x + j, y + i, 0);
      } 
    }
  } 
}

void drwStr(unsigned char* buf, int x, int y, char* str, int ret, int trsp)
{	drwBufStr(SCREEN_BASE_ADDR,x,y,str,ret,trsp);
}

void drwBufStr(unsigned char* buf, int x, int y, char* str, int ret, int trsp)
{ int l = strlen(str);
  int i;
  int stop=0;
  for (i = 0; i < l && !stop; i++) {
    if (str[i] == 0x0A) {
      if(ret)
      { x = 0;
        y += CHAR_HEIGHT;
      }
      else
      { putBufChar(buf, x,y, ' ',trsp); 
        x += CHAR_WIDTH;
      }
    } else {
      putBufChar(buf, x, y, str[i],trsp);
      x += CHAR_WIDTH;
    }
    if (x >= SCREEN_WIDTH-CHAR_WIDTH)
    { if(ret)
      { x = 0;
        y += CHAR_HEIGHT;
      }
      else
        stop=1;
    }
  }
}

void dispBufImgRGB(unsigned char* buf, int xoff, int yoff, char* img, int width, int height)
{	int dwidth=width, dheight=height;
	int data_x=0, data_y=0;
	unsigned int x = 0, y = 0;
	float i, j;
	if(xoff < 0){
		dwidth = dwidth + xoff;
		data_x = (int)(-xoff);
		xoff = 0;
	}
	if(yoff < 0){
		dheight = dheight + yoff;
		data_y = (int)(-yoff);	
		yoff = 0;
	}
	int r,g,b;
	for(i=0, x=0; (int)i < dwidth && x < SCREEN_WIDTH; i+= 1, x++)
		for(j=0, y=0; (int)j < dheight && y < SCREEN_HEIGHT; j+= 1, y++)
		{	b=img[(((int)j+data_y)*width+(int)i+data_x)*3];
			g=img[(((int)j+data_y)*width+(int)i+data_x)*3+1];
			r=img[(((int)j+data_y)*width+(int)i+data_x)*3+2];
			r=r>>3;
			g=g>>2;
			b=b>>3;
			if(!is_cx)
			{	r=31-(31-r)/2;
				g=63-(63-g)/2;
				b=31-(31-b)/2;
			}
			setBufPixelRGB(buf, xoff + x, yoff + dheight-1-y, r, g, b);
		}
}

void dispImgRGB(int xoff, int yoff, char* img, int width, int height)
{	dispBufImgRGB(addr,xoff,yoff,img,width,height);
}

void dispBufIMG(unsigned char* buf, int xoff, int yoff, char* img, int width, int height, float inc)
{	int dwidth=width, dheight=height;
	int data_x=0, data_y=0;
	unsigned int x = 0, y = 0;
	float i, j;
	if(xoff < 0){
		dwidth = dwidth + xoff;
		data_x = (int)(-xoff*inc);
		xoff = 0;
	}
	if(yoff < 0){
		dheight = dheight + yoff;
		data_y = (int)(-yoff*inc);	
		yoff = 0;
	}
	for(i=0, x=0; (int)i < dwidth && x < SCREEN_WIDTH; i+= inc, x++)
		for(j=0, y=0; (int)j < dheight && y < SCREEN_HEIGHT; j+= inc, y++)
			setBufPixel(buf, xoff + x, yoff + y, 31-img[((int)j+data_y)*width+(int)i+data_x]);
}

void dispIMG(int xoff, int yoff, char* img, int width, int height, float inc)
{	dispBufIMG(addr,xoff,yoff,img,width,height,inc);
}

void clrBuf(unsigned char* buf)
{	int color=0xFF;
	if(is_cx) color=0;
	if(mode_bits==16)	memset(buf,color,SCREEN16_SIZE);
	else			memset(buf,color,SCREEN4_SIZE);
}

void clrScr()
{	clrBuf((unsigned char *) addr);
}

void clrBufBox(unsigned char* buf, int x,int y, int w, int h)
{	int i,j;
	if(x<0) { w=w+x; x=0; }
	if(y<0) { h=h+y; y=0; }
	if(y+h>SCREEN_HEIGHT) h=SCREEN_HEIGHT-y;
	if(x+w>SCREEN_WIDTH) w=SCREEN_WIDTH-x;
	for(j = y; j < y+h; j ++)
	{	i=x;
		if(mode_bits==4)
		{	if(i&1)
			{	setBufPixel(buf,i,j,0xF);
				i++;
			}
			memset(buf+(j*SCREEN_WIDTH+i)/2,0xFF,w/2);
			if(w%2)	setBufPixel(buf,i+w-1,j,0xF);
		}
		else
			memset(buf+(j*SCREEN_WIDTH+i)*2,0,w*2);
		
	}
}

void clrBox(int x,int y, int w, int h)
{	clrBufBox(addr,x,y,w,h);
}

void refreshScr(unsigned char* buf)
{	memcpy(addr,buf,SCREEN_WIDTH*SCREEN_HEIGHT*mode_bits/8);
}

void drwBufHoriz(unsigned char* buf, int y, int x1, int x2, int color)
{	int m = max(x1,x2);
	int i = min(x1,x2);
	while(i<=m)
	{	setBufPixel(buf,i,y,color);
		i++;
	}
}

void drwBufFullHoriz(unsigned char* buf, int y)
{	drwBufHoriz(buf, y, 0, SCREEN_WIDTH-1, 0x00);
}

void drwBufVert(unsigned char* buf, int x, int y1, int y2, int color)
{	int m = max(y1,y2);
	int i = min(y1,y2);
	while(i<=m)
	{	setBufPixel(buf, x,i,color);
		i++;
	}
}

void drwBufBox(unsigned char* buf, int x1, int y1, int x2, int y2, int color)
{	drwBufHoriz(buf, y1,x1,x2,color);
	drwBufHoriz(buf, y2,x1,x2,color);
	drwBufVert(buf, x1,y1,y2,color);
	drwBufVert(buf, x2,y1,y2,color);
}