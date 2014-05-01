/****************************************************************************
 * Ndless - Common definitions
 ****************************************************************************/

/* This file is in the public domain.
 * See http://creativecommons.org/licenses/publicdomain/deed.fr */

#ifndef _COMMON_H_
#define _COMMON_H_

#define KEY_MAP                 ADDR_(0x900E0000)

#define OS_BASE_ADDRESS         ADDR_(0x10000000)

/***********************************
 * Keys (key=(offset, 2^bit #)
 ***********************************/
/* Used to fill up a nonexistent key on a model */
#define _KEY_DUMMY_ROW 0x1C
#define _KEY_DUMMY_COL 0x400

#define KEY_NSPIRE_RET          KEY_(0x10, 0x001)
#define KEY_NSPIRE_ENTER        KEY_(0x10, 0x002)
#define KEY_NSPIRE_SPACE        KEYTPAD_(0x10, 0x004, 0x10, 0x10)
#define KEY_NSPIRE_NEGATIVE     KEY_(0x10, 0x008)
#define KEY_NSPIRE_Z            KEYTPAD_(0x10, 0x010, 0x10, 0x20)
#define KEY_NSPIRE_PERIOD       KEYTPAD_(0x10, 0x20, 0x1A, 0x010)
#define KEY_NSPIRE_Y            KEY_(0x10, 0x040)
#define KEY_NSPIRE_0            KEY_(0x10, 0x080)
#define KEY_NSPIRE_X            KEYTPAD_(0x10, 0x100, 0x12, 0x001)
#define KEY_NSPIRE_THETA        KEYTPAD_(0x10, 0x400, _KEY_DUMMY_ROW, _KEY_DUMMY_COL)
#define KEY_NSPIRE_COMMA        KEYTPAD_(0x12, 0x001, 0x1E, 0x400)
#define KEY_NSPIRE_PLUS         KEYTPAD_(0x12, 0x002, 0x1C, 0x004)
#define KEY_NSPIRE_W            KEYTPAD_(0x12, 0x004, 0x12, 0x002)
#define KEY_NSPIRE_3            KEY_(0x12, 0x008)
#define KEY_NSPIRE_V            KEYTPAD_(0x12, 0x010, 0x12, 0x004)
#define KEY_NSPIRE_2            KEYTPAD_(0x12, 0x020, 0x1C, 0x010)
#define KEY_NSPIRE_U            KEYTPAD_(0x12, 0x040, 0x12, 0x010)
#define KEY_NSPIRE_1            KEY_(0x12, 0x080)
#define KEY_NSPIRE_T            KEYTPAD_(0x12, 0x100, 0x12, 0x020)
#define KEY_NSPIRE_eEXP         KEYTPAD_(0x12, 0x200, 0x16, 0x200)
#define KEY_NSPIRE_PI           KEYTPAD_(0x12, 0x400, 0x12, 0x100)
#define KEY_NSPIRE_QUES         KEYTPAD_(0x14, 0x001, _KEY_DUMMY_ROW, _KEY_DUMMY_COL)
#define KEY_NSPIRE_QUESEXCL     KEYTPAD_(_KEY_DUMMY_ROW, _KEY_DUMMY_COL, 0x10, 0x100)
#define KEY_NSPIRE_MINUS        KEYTPAD_(0x14, 0x002, 0x1A, 0x004)
#define KEY_NSPIRE_S            KEYTPAD_(0x14, 0x004, 0x12, 0x040)
#define KEY_NSPIRE_6            KEY_(0x14, 0x008)
#define KEY_NSPIRE_R            KEYTPAD_(0x14, 0x010, 0x14, 0x001)
#define KEY_NSPIRE_5            KEYTPAD_(0x14, 0x020, 0x1A, 0x040)
#define KEY_NSPIRE_Q            KEYTPAD_(0x14, 0x040, 0x14, 0x002)
#define KEY_NSPIRE_4            KEY_(0x14, 0x080)
#define KEY_NSPIRE_P            KEYTPAD_(0x14, 0x100, 0x14, 0x004)
#define KEY_NSPIRE_TENX         KEYTPAD_(0x14, 0x200, 0x12, 0x400)
#define KEY_NSPIRE_EE           KEYTPAD_(0x14, 0x400, 0x14, 0x100)
#define KEY_NSPIRE_COLON        KEYTPAD_(0x16, 0x001, _KEY_DUMMY_ROW, _KEY_DUMMY_COL)
#define KEY_NSPIRE_MULTIPLY     KEYTPAD_(0x16, 0x002, 0x18, 0x100)
#define KEY_NSPIRE_O            KEYTPAD_(0x16, 0x004, 0x14, 0x010)
#define KEY_NSPIRE_9            KEY_(0x16, 0x008)
#define KEY_NSPIRE_N            KEYTPAD_(0x16, 0x010, 0x14, 0x020)
#define KEY_NSPIRE_8            KEYTPAD_(0x16, 0x020, 0x1C, 0x040)
#define KEY_NSPIRE_M            KEYTPAD_(0x16, 0x040, 0x14, 0x040)
#define KEY_NSPIRE_7            KEY_(0x16, 0x080)
#define KEY_NSPIRE_L            KEYTPAD_(0x16, 0x100, 0x16, 0x001)
#define KEY_NSPIRE_SQU          KEYTPAD_(0x16, 0x200, 0x14, 0x200)
#define KEY_NSPIRE_II           KEYTPAD_(0x16, 0x400, _KEY_DUMMY_ROW, _KEY_DUMMY_COL)
#define KEY_NSPIRE_QUOTE        KEYTPAD_(0x18, 0x001, _KEY_DUMMY_ROW, _KEY_DUMMY_COL)
#define KEY_NSPIRE_DIVIDE       KEYTPAD_(0x18, 0x002, 0x16, 0x100)
#define KEY_NSPIRE_K            KEYTPAD_(0x18, 0x004, 0x16, 0x002)
#define KEY_NSPIRE_TAN          KEY_(0x18, 0x008)
#define KEY_NSPIRE_J            KEYTPAD_(0x18, 0x010, 0x16, 0x004)
#define KEY_NSPIRE_COS          KEYTPAD_(0x18, 0x020, _KEY_DUMMY_ROW, _KEY_DUMMY_COL)
#define KEY_NSPIRE_I            KEYTPAD_(0x18, 0x040, 0x16, 0x010)
#define KEY_NSPIRE_SIN          KEYTPAD_(0x18, 0x080, _KEY_DUMMY_ROW, _KEY_DUMMY_COL)
#define KEY_NSPIRE_H            KEYTPAD_(0x18, 0x100, 0x16, 0x020)
#define KEY_NSPIRE_EXP          KEYTPAD_(0x18, 0x200, 0x18, 0x200)
#define KEY_NSPIRE_GTHAN        KEYTPAD_(0x18, 0x400, _KEY_DUMMY_ROW, _KEY_DUMMY_COL)
#define KEY_NSPIRE_APOSTROPHE   KEY_(0x1A, 0x001)
#define KEY_NSPIRE_CAT          KEYTPAD_(0x1A, 0x002, 0x1A, 0x080)
#define KEY_NSPIRE_FRAC         KEYTPAD_(_KEY_DUMMY_ROW, _KEY_DUMMY_COL, 0x1A, 0x100)
#define KEY_NSPIRE_G            KEYTPAD_(0x1A, 0x004, 0x16, 0x040)
#define KEY_NSPIRE_RP           KEYTPAD_(0x1A, 0x008, 0x1A, 0x008)
#define KEY_NSPIRE_F            KEYTPAD_(0x1A, 0x010, 0x18, 0x001)
#define KEY_NSPIRE_LP           KEYTPAD_(0x1A, 0x020, 0x1A, 0x020)
#define KEY_NSPIRE_E            KEYTPAD_(0x1A, 0x040, 0x18, 0x002)
#define KEY_NSPIRE_VAR          KEYTPAD_(0x1A, 0x080, 0x1A, 0x002)
#define KEY_NSPIRE_D            KEYTPAD_(0x1A, 0x100, 0x18, 0x004)
#define KEY_NSPIRE_DEL          KEYTPAD_(0x1E, 0x100, 0x1A, 0x200)
#define KEY_NSPIRE_LTHAN        KEYTPAD_(0x1A, 0x400, _KEY_DUMMY_ROW, _KEY_DUMMY_COL)
#define KEY_NSPIRE_FLAG         KEY_(0x1C, 0x001)
#define KEY_NSPIRE_CLICK        KEYTPAD_ARROW_(0x1C, 0x002, TPAD_ARROW_CLICK)
#define KEY_NSPIRE_C            KEYTPAD_(0x1C, 0x004, 0x18, 0x010)
#define KEY_NSPIRE_HOME         KEYTPAD_(0x1C, 0x008, _KEY_DUMMY_ROW, _KEY_DUMMY_COL)
#define KEY_NSPIRE_B            KEYTPAD_(0x1C, 0x010, 0x18, 0x020)
#define KEY_NSPIRE_MENU         KEY_(0x1C, 0x020)
#define KEY_NSPIRE_A            KEYTPAD_(0x1C, 0x040, 0x18, 0x040)
#define KEY_NSPIRE_ESC          KEY_(0x1C, 0x080)
#define KEY_NSPIRE_BAR          KEY_(0x1C, 0x100)
#define KEY_NSPIRE_TAB          KEY_(0x1C, 0x200)
#define KEY_NSPIRE_EQU          KEYTPAD_(0x1E, 0x400, 0x18, 0x080)
#define KEY_NSPIRE_UP           KEYTPAD_ARROW_(0x1E, 0x001, TPAD_ARROW_UP)
#define KEY_NSPIRE_UPRIGHT      KEYTPAD_ARROW_(0x1E, 0x002, TPAD_ARROW_UPRIGHT)
#define KEY_NSPIRE_RIGHT        KEYTPAD_ARROW_(0x1E, 0x004, TPAD_ARROW_RIGHT)
#define KEY_NSPIRE_RIGHTDOWN    KEYTPAD_ARROW_(0x1E, 0x008, TPAD_ARROW_RIGHTDOWN)
#define KEY_NSPIRE_DOWN         KEYTPAD_ARROW_(0x1E, 0x010, TPAD_ARROW_DOWN)
#define KEY_NSPIRE_DOWNLEFT     KEYTPAD_ARROW_(0x1E, 0x020, TPAD_ARROW_DOWNLEFT)
#define KEY_NSPIRE_LEFT         KEYTPAD_ARROW_(0x1E, 0x040, TPAD_ARROW_LEFT)
#define KEY_NSPIRE_LEFTUP       KEYTPAD_ARROW_(0x1E, 0x080, TPAD_ARROW_LEFTUP)
#define KEY_NSPIRE_SHIFT        KEYTPAD_(0x1A, 0x200, 0x1E, 0x100)
// KEY_NSPIRE_CAPS is deprecated
#define KEY_NSPIRE_CAPS KEY_NSPIRE_SHIFT
#define KEY_NSPIRE_CTRL         KEY_(0x1E, 0x200)
#define KEY_NSPIRE_DOC          KEYTPAD_(_KEY_DUMMY_ROW, _KEY_DUMMY_COL, 0x1C, 0x008)
#define KEY_NSPIRE_TRIG         KEYTPAD_(_KEY_DUMMY_ROW, _KEY_DUMMY_COL, 0x12, 0x200)
#define KEY_NSPIRE_SCRATCHPAD   KEYTPAD_(_KEY_DUMMY_ROW, _KEY_DUMMY_COL, 0x1A, 0x400)

/* TI-84+ Keypad Mappings */
#define KEY_84_DOWN            KEY_(0x10, 0x001)
#define KEY_84_LEFT            KEY_(0x10, 0x002)
#define KEY_84_RIGHT           KEY_(0x10, 0x004)
#define KEY_84_UP              KEY_(0x10, 0x008)
#define KEY_84_ENTER           KEY_(0x12, 0x001)
#define KEY_84_PLUS            KEY_(0x12, 0x002)
#define KEY_84_MINUS           KEY_(0x12, 0x004)
#define KEY_84_MULTIPLY        KEY_(0x12, 0x008)
#define KEY_84_DIVIDE          KEY_(0x12, 0x010)
#define KEY_84_EXP             KEY_(0x12, 0x020)
#define KEY_84_CLEAR           KEY_(0x12, 0x040)
#define KEY_84_NEGATIVE        KEY_(0x14, 0x001)
#define KEY_84_3               KEY_(0x14, 0x002)
#define KEY_84_6               KEY_(0x14, 0x004)
#define KEY_84_9               KEY_(0x14, 0x008)
#define KEY_84_RP              KEY_(0x14, 0x010)
#define KEY_84_TAN             KEY_(0x14, 0x020)
#define KEY_84_VARS            KEY_(0x14, 0x040)
#define KEY_84_PERIOD          KEY_(0x16, 0x001)
#define KEY_84_2               KEY_(0x16, 0x002)
#define KEY_84_5               KEY_(0x16, 0x004)
#define KEY_84_8               KEY_(0x16, 0x008)
#define KEY_84_LP              KEY_(0x16, 0x010)
#define KEY_84_COS             KEY_(0x16, 0x020)
#define KEY_84_PRGM            KEY_(0x16, 0x040)
#define KEY_84_STAT            KEY_(0x16, 0x080)
#define KEY_84_0               KEY_(0x18, 0x001)
#define KEY_84_1               KEY_(0x18, 0x002)
#define KEY_84_4               KEY_(0x18, 0x004)
#define KEY_84_7               KEY_(0x18, 0x008)
#define KEY_84_COMMA           KEY_(0x18, 0x010)
#define KEY_84_SIN             KEY_(0x18, 0x020)
#define KEY_84_APPS            KEY_(0x18, 0x040)
#define KEY_84_X               KEY_(0x18, 0x080)
#define KEY_84_STO             KEY_(0x1A, 0x002)
#define KEY_84_LN              KEY_(0x1A, 0x004)
#define KEY_84_LOG             KEY_(0x1A, 0x008)
#define KEY_84_SQU             KEY_(0x1A, 0x010)
#define KEY_84_INV             KEY_(0x1A, 0x020)
#define KEY_84_MATH            KEY_(0x1A, 0x040)
#define KEY_84_ALPHA           KEY_(0x1A, 0x080)
#define KEY_84_GRAPH           KEY_(0x1C, 0x001)
#define KEY_84_TRACE           KEY_(0x1C, 0x002)
#define KEY_84_ZOOM            KEY_(0x1C, 0x004)
#define KEY_84_WIND            KEY_(0x1C, 0x008)
#define KEY_84_YEQU            KEY_(0x1C, 0x010)
#define KEY_84_2ND             KEY_(0x1C, 0x020)
#define KEY_84_MODE            KEY_(0x1C, 0x040)
#define KEY_84_DEL             KEY_(0x1C, 0x080)

/** GNU AS */
#ifdef GNU_AS
  #define SHARP(s)          #
  #define ADDR_(addr)       addr
  
	.macro to_thumb reg
	add \reg, pc, #1
	bx \reg
	.thumb
	.endm

	.macro to_arm reg
	adr \reg, to_arm\@
	bx \reg
	.arm
to_arm\@:
	.endm

  .macro got_get var, reg1, reg2
	ldr \reg1, got_var_\var
	ldr \reg2, got_var_\var+4
got_get_\var: 
	add \reg1, pc
	ldr \reg1, [\reg1, \reg2]
	.endm

	.macro got_var var
	.align 2
got_var_\var:
	.long _GLOBAL_OFFSET_TABLE_-(got_get_\var+4) 
	.long \var(GOT) 
	.endm

#include <libndls.h>

/** GNU C Compiler */
#else

#include <stddef.h>
#include <stdint.h>

#define _CONCAT(a,b) a##b
#define CONCAT(a,b) _CONCAT(a,b)
#define _STRINGIFY(s) #s
#define STRINGIFY(s) _STRINGIFY(s)
typedef enum BOOL {FALSE = 0, TRUE = 1} BOOL;
/* stdlib.h */
#define EXIT_FAILURE 1
#define EXIT_SUCCESS 0
/* stdio.h */
typedef struct{} FILE;
#ifndef SEEK_SET
 #define SEEK_SET 0
 #define SEEK_CUR 1
 #define SEEK_END 2
#endif
#ifndef FILENAME_MAX
#define FILENAME_MAX 256
#endif
/* Unknown, arbitrary */
#define BUFSIZ 4096
#define EOF (-1)

static inline int abs(int x) {return x >= 0 ? x : -x;}
#if !defined(max) && !defined(__cplusplus)
#define max(a,b) ({typeof(a) __a = (a); typeof(b) __b = (b); (__a > __b) ? __a : __b;})
#define min(a,b) ({typeof(a) __a = (a); typeof(b) __b = (b); (__a < __b) ? __a : __b;})
#endif

#define bswap16(x) \
({ \
	uint16_t __x = (x); \
	((uint16_t)( \
		(((uint16_t)(__x) & (uint16_t)0x00FFU) << 8) | \
		(((uint16_t)(__x) & (uint16_t)0xFF00U) >> 8) )); \
})

#define bswap32(x) \
({ \
	uint32_t __x = (x); \
	((uint32_t)( \
		(((uint32_t)(__x) & (uint32_t)0x000000FFUL) << 24) | \
		(((uint32_t)(__x) & (uint32_t)0x0000FF00UL) <<  8) | \
		(((uint32_t)(__x) & (uint32_t)0x00FF0000UL) >>  8) | \
		(((uint32_t)(__x) & (uint32_t)0xFF000000UL) >> 24) )); \
})

/* Required for C99 variable-length arrays */
void *alloca(size_t size);

/***********************************
 * Nucleus
 ***********************************/

#define NU_SUCCESS 0

#define ARDONLY 0x1     /* MS-DOS File attributes */ 
#define AHIDDEN 0x2 
#define ASYSTEM 0x4 
#define AVOLUME 0x8  
#define ADIRENT 0x10 
#define ARCHIVE 0x20 
#define ANORMAL 0x00 

typedef struct dstat {
	char unknown1[13];
  char filepath[266];        /* Null terminated: A:\... */
  unsigned char fattribute;  /* File attributes: see A* constants above. TODO BROKEN! */
  unsigned short unknown2;
  unsigned short unknown3;
  unsigned short unknown4;
  unsigned short unknown5;
  unsigned long fsize;      /* File size */
  void *unknown6, *unknown7;
  unsigned int unknown8;
  unsigned short unknown9;
} DSTAT;

#define PS_IWRITE       0000400
#define PS_IREAD        0000200
#define PO_RDONLY       0x0000
#define PO_WRONLY       0x0001
#define PO_RDWR         0x0002
#define PO_APPEND       0x0008
#define PO_CREAT        0x0100
#define PO_TRUNC        0x0200
#define PO_EXCL         0x0400
#define PO_NOSHAREANY   0x0004
#define PO_NOSHAREWRITE 0x0800

typedef int PCFD;
 
/***********************************
 * POSIX
 ***********************************/

#define S_IFMT  00170000
#define S_IFSOCK 0140000
#define S_IFLNK  0120000
#define S_IFREG  0100000
#define S_IFBLK  0060000
#define S_IFDIR  0040000
#define S_IFCHR  0020000
#define S_IFIFO  0010000
#define S_ISUID  0004000
#define S_ISGID  0002000
#define S_ISVTX  0001000

#define S_ISLNK(m)      (((m) & S_IFMT) == S_IFLNK)
#define S_ISREG(m)      (((m) & S_IFMT) == S_IFREG)
#define S_ISDIR(m)      (((m) & S_IFMT) == S_IFDIR)
#define S_ISCHR(m)      (((m) & S_IFMT) == S_IFCHR)
#define S_ISBLK(m)      (((m) & S_IFMT) == S_IFBLK)
#define S_ISFIFO(m)     (((m) & S_IFMT) == S_IFIFO)
#define S_ISSOCK(m)     (((m) & S_IFMT) == S_IFSOCK)

#define S_IRWXU 00700
#define S_IRUSR 00400
#define S_IWUSR 00200
#define S_IXUSR 00100

#define S_IRWXG 00070
#define S_IRGRP 00040
#define S_IWGRP 00020
#define S_IXGRP 00010

#define S_IRWXO 00007
#define S_IROTH 00004
#define S_IWOTH 00002
#define S_IXOTH 00001

struct stat {
	unsigned short st_dev;
	unsigned int st_ino; // 0
	unsigned int st_mode; // see S_ macros above
	unsigned short st_nlink; // 1
	unsigned short st_uid; // 0
	unsigned short st_gid; // 0
	unsigned short st_rdev; // = st_dev
	unsigned int st_size;
	unsigned int st_atime;
	unsigned int st_mtime;
	unsigned int st_ctime;
};

/* Now we can libnls.h that depends on the definitions above */
#include <libndls.h>

/* And the following definitions may depend on libndls.h */

typedef struct {
  int row, col, tpad_row, tpad_col;
  tpad_arrow_t tpad_arrow;
} t_key;

#ifndef __cplusplus
#define ADDR_(addr) (void*)addr
#else
#define ADDR_(addr) addr
#endif
/* Use when the row and column are the same for both models */
#define KEY_(row, col) (t_key){row, col, row, col, TPAD_ARROW_NONE}
#define KEYTPAD_(row, col, tpad_row, tpad_col) (t_key){row, col, tpad_row, tpad_col, TPAD_ARROW_NONE}
#define KEYTPAD_ARROW_(row, col, tpad_arrow) (t_key){row, col, row, col, tpad_arrow}
#define isKeyPressed(key) ( \
	(key).tpad_arrow != TPAD_ARROW_NONE && is_touchpad ? touchpad_arrow_pressed((key).tpad_arrow) \
	                                    : !is_classic ^ ((is_touchpad ? !((*(volatile short*)(KEY_MAP + (key).tpad_row)) & (key).tpad_col) \
	                                                   : !((*(volatile short*)(KEY_MAP + (key).row)) & (key).col) ) ) )

/***********************************
 * Hooks management
 ***********************************/

/* Hooked functions and hooks must be built in ARM and not Thumb.
 * 8 bytes are overwritten. They musn't contain relative accesses such as jumps. */
#define HOOK_INSTALL(address, hookname) do { \
	void hookname(void); \
	extern unsigned __##hookname##_end_instrs[4]; /* orig_instrs1; orig_instrs2; ldr pc, [pc, #-4]; .long return_addr */ \
	__##hookname##_end_instrs[3] = (unsigned)(address) + 8; \
	__##hookname##_end_instrs[0] = *(unsigned*)(address); \
	*(unsigned*)(address) = 0xE51FF004; /* ldr pc, [pc, #-4] */ \
	__##hookname##_end_instrs[1] = *(unsigned*)((address) + 4); \
	*(unsigned*)((address) + 4) = (unsigned)hookname; \
	__##hookname##_end_instrs[2] = 0xE51FF004; /* ldr pc, [pc, #-4] */ \
	clear_cache(); \
	} while (0)

/* Caution, hooks aren't re-entrant.
* Must always exits with either HOOK_RESTORE_RETURN, HOOK_RETURN or HOOK_RESTORE_RETURN_SKIP.
 * A non-inlined body is required because naked function cannot use local variables.
 * A naked function is required because the return is handled by the hook, and to avoid any
 * register modification before they are saved */
#define HOOK_DEFINE(hookname) \
	unsigned __##hookname##_end_instrs[4]; \
	extern unsigned __##hookname##_saved_sp; \
	void __##hookname##_body(void); \
	void __attribute__((naked)) hookname(void) { \
		__asm volatile (" b 0f; " STRINGIFY(__##hookname##_saved_sp) ": .long 0; 0:"); /* accessed with pc-relative instruction. In hookname() else moved too far by GCC. */ \
		__asm volatile(" stmfd sp!, {r0-r12,lr}"); /* used by HOOK_RESTORE_STATE() */ \
		/* save sp */ \
		__asm volatile( \
			" str r0, [sp, #-4] @ push r0 but don't change sp \n " \
			" adr r0," STRINGIFY(__##hookname##_saved_sp) "\n" \
			" str sp, [r0] \n" \
			" ldr r0, [sp, #-4] @ pop r0 but don't change sp \n" \
		); \
		 __##hookname##_body(); \
	} \
	void __##hookname##_body(void)

/* Jump out of the body */
#define HOOK_RESTORE_SP(hookname) do { \
	__asm volatile( \
		" str lr, [sp, #-4]! @ push lr \n" \
		" adr lr," STRINGIFY(__##hookname##_saved_sp) "\n" \
		" ldr lr, [lr] \n" \
		" str lr, [sp, #-4]! \n" /* push lr=saved_sp. trick to restore both saved_sp and the original lr */ \
		" ldmfd sp, {sp, lr} \n" /* lr has been used instead of r0 to avoid a GAS warning about reg order on this instr */ \
	); \
} while (0)

/* Read-write: can be used to access the values that had the registers when the hook was called: {r0-r12,lr} */
#define HOOK_SAVED_REGS(hookname) ((unsigned*) __##hookname##_saved_sp)

#define HOOK_SAVED_SP(hookname) ((void*) __##hookname##_saved_sp)

#define HOOK_RESTORE_STATE() do { \
	__asm volatile(" ldmfd sp!, {r0-r12,lr}"); \
} while (0)


/* Call HOOK_RESTORE() alone to return manually with __asm(). */
#define HOOK_RESTORE(hookname) { \
	HOOK_RESTORE_SP(hookname); \
	HOOK_RESTORE_STATE(); \
} while (0)

/* If register values needs to be changed before a hook return, call HOOK_RESTORE(),
 * set the registers then call HOOK_RETURN. Caution, only assembly without local
 * variables can between the 2 calls. */
#define HOOK_RETURN(hookname) do { \
	__asm volatile(" b " STRINGIFY(__##hookname##_end_instrs)); \
} while (0)

/* Standard hook return */
#define HOOK_RESTORE_RETURN(hookname) do { \
	HOOK_RESTORE(hookname); \
	HOOK_RETURN(hookname); \
} while (0)

/* Hook return skipping instructions.
 * The 2 instructions overwritten by the hook are always skipped, the offset is based from the third instruction.
 * Any use must come with a call to HOOK_SKIP_VAR() outside of the hook function
 * id is a unique id for the hook */
#define HOOK_RESTORE_RETURN_SKIP(hookname, offset,id) do { \
	__asm volatile( \
		" adr r0, " STRINGIFY(__##hookname##_return_skip##id) "\n" \
		"	str %0, [r0] \n" \
		:: "r"(__##hookname##_end_instrs[3] + offset) : "r0"); \
	HOOK_RESTORE(hookname); \
	__asm volatile( \
		" ldr pc, [pc, #-4] \n" \
	  STRINGIFY(__##hookname##_return_skip##id) ":" \
		" .long 0"); \
	} while (0)

#define HOOK_SKIP_VAR(hookname, offset) \
	volatile unsigned __##hookname##_end_instrs_skip##offset[2]; /* ldr pc, [pc, #-4]; .long return_addr */ \

#define HOOK_UNINSTALL(address, hookname) do { \
	extern unsigned __##hookname##_end_instrs[4]; /* orig_instrs1; orig_instrs2; ... */ \
	*(unsigned*)(address) = __##hookname##_end_instrs[0]; \
	*(unsigned*)((address) + 4) = __##hookname##_end_instrs[1]; \
	clear_cache(); \
} while (0)


#endif /* GCC C */

#endif
