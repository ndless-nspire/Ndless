#ifndef KEYS_H
#define KEYS_H

/***********************************
 * Keys (key=(offset, 2^bit #)
 ***********************************/

typedef enum tpad_arrow 
{
	TPAD_ARROW_NONE,
	TPAD_ARROW_UP, TPAD_ARROW_UPRIGHT,
	TPAD_ARROW_RIGHT, TPAD_ARROW_RIGHTDOWN,
	TPAD_ARROW_DOWN, TPAD_ARROW_DOWNLEFT,
	TPAD_ARROW_LEFT, TPAD_ARROW_LEFTUP,
	TPAD_ARROW_CLICK
} tpad_arrow_t;

typedef struct {
  int row, col, tpad_row, tpad_col;
  tpad_arrow_t tpad_arrow;
} t_key;

/* Used when the row and column are the same for both models */
#define KEY_(row, col) {row, col, row, col, TPAD_ARROW_NONE}
#define KEYTPAD_(row, col, tpad_row, tpad_col) {row, col, tpad_row, tpad_col, TPAD_ARROW_NONE}
#define KEYTPAD_ARROW_(row, col, tpad_arrow) {row, col, row, col, tpad_arrow}

/* Used to fill up a nonexistent key on a model */
#define _KEY_DUMMY_ROW 0x1C
#define _KEY_DUMMY_COL 0x400

extern const t_key KEY_NSPIRE_RET;
extern const t_key KEY_NSPIRE_ENTER;
extern const t_key KEY_NSPIRE_SPACE;
extern const t_key KEY_NSPIRE_NEGATIVE;
extern const t_key KEY_NSPIRE_Z;
extern const t_key KEY_NSPIRE_PERIOD;
extern const t_key KEY_NSPIRE_Y;
extern const t_key KEY_NSPIRE_0;
extern const t_key KEY_NSPIRE_X;
extern const t_key KEY_NSPIRE_THETA;
extern const t_key KEY_NSPIRE_COMMA;
extern const t_key KEY_NSPIRE_PLUS;
extern const t_key KEY_NSPIRE_W;
extern const t_key KEY_NSPIRE_3;
extern const t_key KEY_NSPIRE_V;
extern const t_key KEY_NSPIRE_2;
extern const t_key KEY_NSPIRE_U;
extern const t_key KEY_NSPIRE_1;
extern const t_key KEY_NSPIRE_T;
extern const t_key KEY_NSPIRE_eEXP;
extern const t_key KEY_NSPIRE_PI;
extern const t_key KEY_NSPIRE_QUES;
extern const t_key KEY_NSPIRE_QUESEXCL;
extern const t_key KEY_NSPIRE_MINUS;
extern const t_key KEY_NSPIRE_S;
extern const t_key KEY_NSPIRE_6;
extern const t_key KEY_NSPIRE_R;
extern const t_key KEY_NSPIRE_5;
extern const t_key KEY_NSPIRE_Q;
extern const t_key KEY_NSPIRE_4;
extern const t_key KEY_NSPIRE_P;
extern const t_key KEY_NSPIRE_TENX;
extern const t_key KEY_NSPIRE_EE;
extern const t_key KEY_NSPIRE_COLON;
extern const t_key KEY_NSPIRE_MULTIPLY;
extern const t_key KEY_NSPIRE_O;
extern const t_key KEY_NSPIRE_9;
extern const t_key KEY_NSPIRE_N;
extern const t_key KEY_NSPIRE_8;
extern const t_key KEY_NSPIRE_M;
extern const t_key KEY_NSPIRE_7;
extern const t_key KEY_NSPIRE_L;
extern const t_key KEY_NSPIRE_SQU;
extern const t_key KEY_NSPIRE_II;
extern const t_key KEY_NSPIRE_QUOTE;
extern const t_key KEY_NSPIRE_DIVIDE;
extern const t_key KEY_NSPIRE_K;
extern const t_key KEY_NSPIRE_TAN;
extern const t_key KEY_NSPIRE_J;
extern const t_key KEY_NSPIRE_COS;
extern const t_key KEY_NSPIRE_I;
extern const t_key KEY_NSPIRE_SIN;
extern const t_key KEY_NSPIRE_H;
extern const t_key KEY_NSPIRE_EXP;
extern const t_key KEY_NSPIRE_GTHAN;
extern const t_key KEY_NSPIRE_APOSTROPHE;
extern const t_key KEY_NSPIRE_CAT;
extern const t_key KEY_NSPIRE_FRAC;
extern const t_key KEY_NSPIRE_G;
extern const t_key KEY_NSPIRE_RP;
extern const t_key KEY_NSPIRE_F;
extern const t_key KEY_NSPIRE_LP;
extern const t_key KEY_NSPIRE_E;
extern const t_key KEY_NSPIRE_VAR;
extern const t_key KEY_NSPIRE_D;
extern const t_key KEY_NSPIRE_DEL;
extern const t_key KEY_NSPIRE_LTHAN;
extern const t_key KEY_NSPIRE_FLAG;
extern const t_key KEY_NSPIRE_CLICK;
extern const t_key KEY_NSPIRE_C;
extern const t_key KEY_NSPIRE_HOME;
extern const t_key KEY_NSPIRE_B;
extern const t_key KEY_NSPIRE_MENU;
extern const t_key KEY_NSPIRE_A;
extern const t_key KEY_NSPIRE_ESC;
extern const t_key KEY_NSPIRE_BAR;
extern const t_key KEY_NSPIRE_TAB;
extern const t_key KEY_NSPIRE_EQU;
extern const t_key KEY_NSPIRE_UP;
extern const t_key KEY_NSPIRE_UPRIGHT;
extern const t_key KEY_NSPIRE_RIGHT;
extern const t_key KEY_NSPIRE_RIGHTDOWN;
extern const t_key KEY_NSPIRE_DOWN;
extern const t_key KEY_NSPIRE_DOWNLEFT;
extern const t_key KEY_NSPIRE_LEFT;
extern const t_key KEY_NSPIRE_LEFTUP;
extern const t_key KEY_NSPIRE_SHIFT;
extern const t_key KEY_NSPIRE_CTRL;
extern const t_key KEY_NSPIRE_DOC;
extern const t_key KEY_NSPIRE_TRIG;
extern const t_key KEY_NSPIRE_SCRATCHPAD;

/* TI-84+ Keypad Mappings */
extern const t_key KEY_84_DOWN;
extern const t_key KEY_84_LEFT;
extern const t_key KEY_84_RIGHT;
extern const t_key KEY_84_ENTER;
extern const t_key KEY_84_PLUS;
extern const t_key KEY_84_MINUS;
extern const t_key KEY_84_MULTIPLY;
extern const t_key KEY_84_DIVIDE;
extern const t_key KEY_84_EXP;
extern const t_key KEY_84_CLEAR;
extern const t_key KEY_84_NEGATIVE;
extern const t_key KEY_84_3;
extern const t_key KEY_84_6;
extern const t_key KEY_84_9;
extern const t_key KEY_84_RP;
extern const t_key KEY_84_TAN;
extern const t_key KEY_84_VARS;
extern const t_key KEY_84_PERIOD;
extern const t_key KEY_84_2;
extern const t_key KEY_84_5;
extern const t_key KEY_84_8;
extern const t_key KEY_84_LP;
extern const t_key KEY_84_COS;
extern const t_key KEY_84_PRGM;
extern const t_key KEY_84_STAT;
extern const t_key KEY_84_0;
extern const t_key KEY_84_1;
extern const t_key KEY_84_4;
extern const t_key KEY_84_7;
extern const t_key KEY_84_COMMA;
extern const t_key KEY_84_SIN;
extern const t_key KEY_84_APPS;
extern const t_key KEY_84_X;
extern const t_key KEY_84_STO;
extern const t_key KEY_84_LN;
extern const t_key KEY_84_LOG;
extern const t_key KEY_84_SQU;
extern const t_key KEY_84_INV;
extern const t_key KEY_84_MATH;
extern const t_key KEY_84_ALPHA;
extern const t_key KEY_84_GRAPH;
extern const t_key KEY_84_TRACE;
extern const t_key KEY_84_ZOOM;
extern const t_key KEY_84_WIND;
extern const t_key KEY_84_YEQU;
extern const t_key KEY_84_2ND;
extern const t_key KEY_84_MODE;
extern const t_key KEY_84_DEL;


#endif // !KEYS_H
