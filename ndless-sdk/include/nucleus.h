#ifndef NUCLEUS_H
#define NUCLEUS_H

#ifdef __cplusplus
extern "C" {
#endif
	
#include <stdint.h>
#include <string.h>
#include <limits.h>

#define BUFSIZ 1024
#define OS_BASE_ADDRESS 0x10000000

//lua.h requires BUFSIZ
#include <lauxlib.h>

typedef enum { FALSE=0, TRUE } BOOL;

typedef struct {
  char * str;
  int len;
  int chunk_size;
  int unknown_field;
} * String;

//TODO: char for 16 bits?

typedef void NU_TASK;
typedef int PCFD;

typedef struct dstat {
	char unknown1[13];
	char filepath[266];		/* Null terminated: A:\... */
	unsigned char fattribute;	/* File attributes: TODO BROKEN! */
	unsigned short unknown2;
	unsigned short unknown3;
	unsigned short unknown4;
	unsigned short unknown5;
	unsigned long fsize;		/* File size */
	void *unknown6, *unknown7;
	unsigned int unknown8;
	unsigned short unknown9;
} DSTAT;

struct s_ns_event {
 unsigned int timestamp;
 unsigned short type; // 0x8 is key down, 0x10 is key up. 0x20 may be APD
 unsigned short ascii;
 unsigned int key;
 unsigned int cursor_x;
 unsigned int cursor_y;
 unsigned int unknown;
 unsigned short modifiers; // Shift = 3, Ctrl = 4, Caps = 0x10
 unsigned char click; // Click = 8
};

//Ascii representation of the 4 chars
typedef enum {
    RES_CLNK = 0x636C6E6B,
    RES_CTLG = 0x63746C67,
    RES_DCOL = 0x64636F6C,
    RES_DLOG = 0x646C6F67,
    RES_DTST = 0x64747374,
    RES_GEOG = 0x67656F67,
    RES_MATH = 0x6D617468,
    RES_MWIZ = 0x6D77697A,
    RES_NTPD = 0x6E747064,
    RES_PGED = 0x70676564,
    RES_QCKP = 0x71636B70,
    RES_QUES = 0x71756573,
    RES_SCPD = 0x73637064,
    RES_SYST = 0x73797374,
    RES_TBLT = 0x74626C74,
} e_resourceID;

// If the syscalls are used directly and not through newlib
struct nuc_stat {
	unsigned short st_dev;
	unsigned int st_ino; // 0
	unsigned int st_mode;
	unsigned short st_nlink; // 1
	unsigned short st_uid; // 0
	unsigned short st_gid; // 0
	unsigned short st_rdev; // = st_dev
	unsigned int st_size;
	unsigned int st_atime;
	unsigned int st_mtime;
	unsigned int st_ctime;
};

typedef void NUC_FILE;
typedef void NUC_DIR;
struct nuc_dirent {
        char d_name[0];
};

//Provided by ndless
unsigned char* keypad_type();
#define keypad_type keypad_type()
int nl_ndless_rev();
int nl_hwtype();
int nl_hwsubtype();
int nl_loaded_by_3rd_party_loader();
lua_State *nl_lua_getstate();
int luaL_error();

#ifdef __cplusplus
}
#endif

#endif
