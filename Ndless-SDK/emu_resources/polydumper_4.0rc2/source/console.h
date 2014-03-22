#define MAX_COL SCREEN_WIDTH/CHAR_WIDTH
#define MAX_LGN SCREEN_HEIGHT/CHAR_HEIGHT
#define LSEPARATOR "----------------------------------------"

void dispBuf( unsigned char* buf, char* message, int ret,int trsp );
void disp(char* msg, int ret,int trsp);
void displnBuf( unsigned char* buf, char* message, int ret,int trsp );
void displn(char* msg, int ret,int trsp);
void resetConsole();
//void pause( char* message, int ret,int trsp, int invite);
