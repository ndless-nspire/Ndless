#include <os.h>
#include "screen.h"
#include "console.h"
#include "tools.h"
#include "charmap.h"

int col=0;
int line=0;

void dispBuf( unsigned char* buf, char* message, int ret,int trsp )
{ int l = strlen(message);
  int i, stop=0;
  for (i = 0; i < l && !stop; i++) {
    if (message[i] == 0x0A) {
      if ( ret )
      { col = 0;
        line ++;
      }
      else
      { putBufChar(buf, col*CHAR_WIDTH, line*CHAR_HEIGHT, ' ', trsp);
        col++;
      }
    } else {
      putBufChar(buf, col*CHAR_WIDTH, line*CHAR_HEIGHT, message[i], trsp);
      col ++;
    }
    if (col >= MAX_COL)
    { if ( !ret ) stop=1;
      else
      { col = 0;
        line ++;
      }
    }
    if(line>=MAX_LGN) { line=0; clrScr(); }
  }
}

void disp(char* msg, int ret, int trsp)
{	dispBuf(SCREEN_BASE_ADDR,msg,ret,trsp);
}

void displnBuf( unsigned char* buf, char* message, int ret,int trsp )
{	dispBuf(buf, message, ret,trsp);
	col=0;
	line++;
	if(line>=MAX_LGN) { line=0; clrScr(); }
}

void displn(char* msg, int ret,int trsp)
{	displnBuf(SCREEN_BASE_ADDR,msg,ret,trsp);
}

void pause( char* message, int ret, int trsp, int invite)
{	if(message)
		if(*message)
			displn(message, ret,trsp);
	if(invite)	displn("Press [esc] to continue...", 0,trsp);
	while(!isKeyPressed(KEY_NSPIRE_ESC)) {}
}

void resetConsole()
{	col=0;
	line=0;
}