/****************************************************************************
 * Ndless - main header file
 ****************************************************************************/

#ifndef _OS_H_
#define _OS_H_

#ifdef __cplusplus
extern "C" {
#endif

// So that subsequent standard #include don't conflict
#define _STDIO_H_
#define _STRING_H_

#include <common.h>

#ifdef _NDLS_LIGHT
// Use the light version of the syscalls table
#include "syscalls-light.h"
#else
#include "syscalls.h"
#endif
/* GNU AS */
#ifdef GNU_AS
// unfortunately using a GAS macro for this is not possible
#define syscall(syscall_name) swi e_##syscall_name
#define osvar(osvar_name) swi (__SYSCALLS_ISVAR|e_##osvar_name)

/* GNU C Compiler */
#else

extern int __base;

#define _SYSCALL_ENUM(syscall_name) e_##syscall_name
/* The SWI calling convention is the C calling convention for the parameters.
 * We define:
 * - Macros for syscalls with 0, 1, 2, 3 and 4 parameters
 * - A macro fo syscalls with more than 4 parameters. We force GCC to pass the 5+ parameters through
 *   the stack using a variadic function and a wrapper with typed parameters.
 * - A macro for variadic syscalls
 * Caution, lr is destroyed by our swi calling convention (and r0-r3,r12 by the C calling convention of the syscalls) */
#define _SYSCALL0(rettype, funcname) static inline rettype funcname(void) { \
	register unsigned __r0 __asm("r0"); \
	__asm volatile( \
		" swi " STRINGIFY(_SYSCALL_ENUM(funcname)) \
		:"=r" (__r0) :: "memory", "r1", "r2", "r3", "r12", "lr"); \
	return (rettype)__r0; \
}
#define _SYSCALL1(rettype, funcname, type1) static inline rettype funcname(type1 __param1) { \
	register unsigned __r0 __asm("r0") = (unsigned)__param1; \
	__asm volatile( \
		" swi " STRINGIFY(_SYSCALL_ENUM(funcname)) \
		: "=r" (__r0) : "r" (__r0) :  "memory", "r1", "r2", "r3", "r12", "lr"); \
	return (rettype)__r0; \
}
// __r1 in output operand list gives an hint to GCC that r1 is clobbered. As an __asm-specifier for __r1, r1 cannot be put in the clobber list.
// "memory" in the list of the clobbered register is required for pointer parameters used for writes by the syscall, to avoid any caching.
#define _SYSCALL2(rettype, funcname, type1, type2) static inline rettype funcname(type1 __param1, type2 __param2) { \
	register unsigned __r0 __asm("r0") = (unsigned)__param1; \
	register unsigned __r1 __asm("r1") = (unsigned)__param2; \
	__asm volatile( \
		" swi " STRINGIFY(_SYSCALL_ENUM(funcname)) \
		: "=r" (__r0), "=r" (__r1) : "r" (__r0), "r" (__r1) : "memory", "r2", "r3", "r12", "lr"); \
	return (rettype)__r0; \
}
#define _SYSCALL3(rettype, funcname, type1, type2, type3) static inline rettype funcname(type1 __param1, type2 __param2, type3 __param3) { \
	register unsigned __r0 __asm("r0") = (unsigned)__param1; \
	register unsigned __r1 __asm("r1") = (unsigned)__param2; \
	register unsigned __r2 __asm("r2") = (unsigned)__param3; \
	__asm volatile( \
		" swi " STRINGIFY(_SYSCALL_ENUM(funcname)) \
		: "=r" (__r0), "=r" (__r1), "=r" (__r2) : "r" (__r0), "r" (__r1), "r" (__r2) : "memory", "r3", "r12", "lr"); \
	return (rettype)__r0; \
}
#define _SYSCALL4(rettype, funcname, type1, type2, type3, type4) static inline rettype funcname(type1 __param1, type2 __param2,  type3 __param3,  type4 __param4) { \
	register unsigned __r0 __asm("r0") = (unsigned)__param1; \
	register unsigned __r1 __asm("r1") = (unsigned)__param2; \
	register unsigned __r2 __asm("r2") = (unsigned)__param3; \
	register unsigned __r3 __asm("r3") = (unsigned)__param4; \
	__asm volatile( \
		" swi " STRINGIFY(_SYSCALL_ENUM(funcname)) \
		: "=r" (__r0), "=r" (__r1), "=r" (__r2), "=r" (__r3) : "r" (__r0), "r" (__r1), "r" (__r2) , "r" (__r3) : "memory", "r12", "lr"); \
	return (rettype)__r0; \
}
/* used to access through the got the global variable _syscallvar_savedlr. Returns the ptr to reg1. */
#ifndef __thumb__
#define _SYSCALL_GETSAVEDLR_PTR(reg1,tmpreg) \
		" ldr " #reg1 ", 1f \n" \
		" ldr " #tmpreg ", 1f+4 \n" \
		"0:	\n" \
		" add " #reg1 ", pc, " #reg1 " \n" \
		" ldr " #reg1 ", [" #reg1 ", " #tmpreg "] \n" \
		" b 2f \n" \
		" .align 2 \n" \
		"1: \n" \
		" .long _GLOBAL_OFFSET_TABLE_ - (0b+8) \n" \
		" .long _syscallvar_savedlr(GOT) \n" \
		"2: \n"
#else
#define _SYSCALL_GETSAVEDLR_PTR(reg1,tmpreg) \
		" ldr " #reg1 ", 1f \n" \
		" ldr " #tmpreg ", 1f+4 \n" \
		"0:	\n" \
		" add " #reg1 ", pc, " #reg1 " \n" \
		" ldr " #reg1 ", [" #reg1 ", " #tmpreg "] \n" \
		" b 2f \n" \
		" .align 2 \n" \
		"1: \n" \
		" .long _GLOBAL_OFFSET_TABLE_ - (0b+4) \n" \
		" .long _syscallvar_savedlr(GOT) \n" \
		"2: \n"
#endif // ndef __thumb__
/* all parameters must be marked with  __attribute__((unused)) */
#ifdef _NDLS_LIGHT // can't use _SYSCALL_GETSAVEDLR_PTR which depends on the GOT: save lr to the stack, syscallvars with more than 4 parameters can't be used
#define _SYSCALLVAR(rettype, attributes, funcname, param1, ...) static __attribute__((unused)) rettype attributes __attribute__((naked)) funcname(param1, __VA_ARGS__) { \
	register unsigned __r0 __asm("r0"); \
	__asm volatile( \
		" push {lr} \n" \
		" swi " STRINGIFY(_SYSCALL_ENUM(funcname)) "\n" \
	  " pop {pc}" \
		: "=r" (__r0):: "memory", "r1", "r2", "r3"); \
	return (rettype)__r0; \
}
#else
#ifndef __thumb__
/* TODO: _SYSCALLVAR is also used for >= 5 parameters, but must strangely contain var args for the parameters to be passed */
#define _SYSCALLVAR(rettype, attributes, funcname, param1, ...) static __attribute__((unused)) rettype attributes __attribute__((naked)) funcname(param1, __VA_ARGS__) { \
	register unsigned __r0 __asm("r0"); \
	__asm volatile( \
		" push {r4, r5} \n" \
		_SYSCALL_GETSAVEDLR_PTR(r4, r5) \
		" str lr, [r4] \n" \
		" pop {r4, r5} \n" \
		" swi " STRINGIFY(_SYSCALL_ENUM(funcname)) "\n" \
		_SYSCALL_GETSAVEDLR_PTR(r1, r2) \
		" ldr pc, [r1] \n" \
		: "=r" (__r0):: "memory", "r1", "r2", "r3"); \
	return (rettype)__r0; \
}
#else // slightly less optimized
#define _SYSCALLVAR(rettype, attributes, funcname, param1, ...) static __attribute__((unused)) rettype attributes __attribute__((naked)) funcname(param1, __VA_ARGS__) { \
	register unsigned __r0 __asm("r0"); \
	__asm volatile( \
		" push {r4, r5} \n" \
		_SYSCALL_GETSAVEDLR_PTR(r4, r5) \
		" mov r5, lr \n" \
		" str r5, [r4] \n" \
		" pop {r4, r5} \n" \
		" swi " STRINGIFY(_SYSCALL_ENUM(funcname)) "\n" \
		_SYSCALL_GETSAVEDLR_PTR(r1, r2) \
		" ldr r1, [r1] \n" \
		" bx r1 \n" \
		: "=r" (__r0):: "memory", "r1", "r2", "r3"); \
	return (rettype)__r0; \
}
#endif // ndef __thumb__
#endif // def _NDLS_LIGHT
// We can't push it onto the stack during the syscall, so save it in a global variable
// attribute unused: avoids the warning. The symbol will be redefined by the ldscript.
static __attribute__ ((unused)) unsigned _syscallvar_savedlr;

#ifdef __cplusplus
#define VARIABLE_ARGS ...
#else
#define VARIABLE_ARGS
#endif

/* Force the use of the stack for the parameters */
#ifndef __thumb__
#define _SYSCALL_SWI(rettype, attributes, funcname, param1) static rettype attributes __attribute__((naked)) funcname##_swi(VARIABLE_ARGS) { \
	register unsigned __r0 __asm("r0"); \
	__asm volatile( \
		" push {r4, r5} \n" \
		_SYSCALL_GETSAVEDLR_PTR(r4, r5) \
		" str lr, [r4] \n" \
		" pop {r4, r5} \n" \
		" swi " STRINGIFY(_SYSCALL_ENUM(funcname)) "\n" \
		_SYSCALL_GETSAVEDLR_PTR(r1, r2) \
		" ldr pc, [r1] \n" \
		: "=r" (__r0):: "memory", "r1", "r2", "r3"); \
	return (rettype)__r0; \
}
#else // slightly less optimized
#define _SYSCALL_SWI(rettype, attributes, funcname, param1) static rettype attributes __attribute__((naked)) funcname##_swi(VARIABLE_ARGS) { \
	register unsigned __r0 __asm("r0"); \
	__asm volatile( \
		" push {r4, r5} \n" \
		_SYSCALL_GETSAVEDLR_PTR(r4, r5) \
		" mov r5, lr \n" \
		" str r5, [r4] \n" \
		" pop {r4, r5} \n" \
		" swi " STRINGIFY(_SYSCALL_ENUM(funcname)) "\n" \
		_SYSCALL_GETSAVEDLR_PTR(r1, r2) \
		" ldr r1, [r1] \n" \
		" bx r1 \n" \
		: "=r" (__r0):: "memory", "r1", "r2", "r3"); \
	return (rettype)__r0; \
}
#endif // ndef __thumb__
#define _SYSCALL(rettype, funcname, param1, ...) _SYSCALL_SWI(rettype, , funcname, param1) static inline rettype funcname(param1, __VA_ARGS__)
// Use in conjunction with _SYSCALL for 5+ parameters
#define _SYSCALL_ARGS(rettype, funcname, param1, ...) {return funcname##_swi(param1, __VA_ARGS__);}
/* Custom syscalls: these are syscalls currently not implemented by Ndless you want to define yourself.
 * The syntax is:
 * static const unsigned puts_addrs[] = {<3.1.0-address>, <3.1.0-CAS-address>, ...}; // see nl_osvalue for the order of the addresses
 * #define puts SYSCALL_CUSTOM(puts_addrs, int, const char *) */
#define SYSCALL_CUSTOM(addresses, rettype, ...) ((rettype(*)(__VA_ARGS__))nl_osvalue((int*)addresses, sizeof(addresses)/sizeof(addresses[0])))
/* Access to OS variables */
#define _SYSCALL_OSVAR(type, name) static inline type name(void) { \
	register unsigned __r0 __asm("r0"); \
	__asm volatile( \
		" swi " STRINGIFY(__SYSCALLS_ISVAR|_SYSCALL_ENUM(name)) \
		: "=r" (__r0) : "r" (__r0) :  "r1", "r2", "r3", "r12", "lr"); \
	return (type)__r0; \
}

/* OS syscalls */


/* String API */

typedef struct {
  char * str;
  int len;
  int chunck_size;
  int unknown_field;
} * String;

_SYSCALL0(String, string_new)
_SYSCALL1(void, string_free, String)
_SYSCALL1(char *, string_to_ascii, String)
_SYSCALL1(void, string_lower, String)
_SYSCALL2(char, string_charAt, String, int /* pos */)
_SYSCALL2(int, string_concat_utf16, String, const char *)
_SYSCALL2(int, string_set_ascii, String, const char *)
_SYSCALL2(int, string_set_utf16, String, const char *)
_SYSCALL3(int, string_indexOf_utf16, String, int /* start */, const char *)
_SYSCALL3(int, string_last_indexOf_utf16, String, int /* start */, const char *)
_SYSCALL2(int, string_compareTo_utf16, String, const char *)
_SYSCALL4(char *, string_substring, String /* dest */, String /* source */, int /* begin index */, int /* end index (excluded)*/)
_SYSCALL2(void, string_erase, String, int /* ending index */)
_SYSCALL2(void, string_truncate, String, int /* starting index */)
_SYSCALL3(char *, string_substring_utf16, String, const char *, int *)
_SYSCALL4(int, string_insert_replace_utf16, String, const char *, int /* start */, int /* end */)
_SYSCALL3(int, string_insert_utf16, String, const char *, int /* pos */)
_SYSCALLVAR(int, __attribute__((__format__(__printf__,2,3))), string_sprintf_utf16, __attribute__((unused))  String arg0, __attribute__((unused)) const char * arg1,  ...)

_SYSCALL1(int, read_unaligned_longword, void *)
_SYSCALL1(int, read_unaligned_word, void *)
_SYSCALL3(void, ascii2utf16, void *, const char *, int)
_SYSCALL3(void, utf162ascii, char *, void *, int)
_SYSCALL1(size_t, utf16_strlen, const char *)
_SYSCALL4(void, show_dialog_box2_, int /* undef */, const char * /* title */, const char * /* msg */, char * /* undef_buf[8] */)
_SYSCALL(int, _show_msgbox_2b, int undef, const char * title, const char *msg, char *button1, int button1_code, char *button2, int button2_code, char undef_buf[8]) _SYSCALL_ARGS(int, _show_msgbox_2b, undef, title, msg, button1, button1_code, button2, button2_code, undef_buf)
_SYSCALL(int, _show_msgbox_3b, int undef, const char * title, const char *msg, char *button1, int button1_code, char *button2, int button2_code, char *button3, int button3_code, char undef_buf[8]) _SYSCALL_ARGS(int, _show_msgbox_3b, undef, title, msg, button1, button1_code, button2, button2_code, button3, button3_code, undef_buf)

_SYSCALL(int /* 5103=OK, 5104=CANCEL */, _show_1NumericInput, int undef, const char *title, const char *subtitle, const char *input_title, int *value_ref, unsigned undef2, int min_value, int max_value) _SYSCALL_ARGS(int, _show_1NumericInput, undef, title, subtitle, input_title, value_ref, undef2, min_value, max_value)

_SYSCALL(int /* 5103=OK, 5104=CANCEL */, _show_2NumericInput, int undef, const char *title, const char *subtitle, const char *input1_title, int *value1_ref, unsigned undef2, int min_value1, int max_value1, const char *input2_title, int *value2_ref, unsigned undef3, int min_value2, int max_value2) _SYSCALL_ARGS(int, _show_2NumericInput, undef, title, subtitle, input1_title, value1_ref, undef2, min_value1, max_value1, input2_title, value2_ref, undef3, min_value2, max_value2)

_SYSCALL(int /* 1=OK, 0=CANCEL */, _show_msgUserInput, int undef, String * struct_ref /* msg str ref & default value str ref array */, const char * title, const char * input_title) _SYSCALL_ARGS(int, _show_msgUserInput, undef, struct_ref, title, input_title) // depreciated, use show_msgUserInput from libndls
 
_SYSCALL0(int *, errno_addr)
#define errno (*errno_addr())

_SYSCALL1(void, srand, unsigned int)
_SYSCALL0(int, rand)

_SYSCALL1(int, isalpha, int)
_SYSCALL1(int, isascii, int)
_SYSCALL1(int, isdigit, int)
_SYSCALL1(int, islower, int)
_SYSCALL1(int, isprint, int)
_SYSCALL1(int, isspace, int)
_SYSCALL1(int, isupper, int)
_SYSCALL1(int, isxdigit, int)
_SYSCALL1(int, tolower, int)
_SYSCALL1(int, toupper, int)
_SYSCALL1(int, atoi, const char *)
_SYSCALL1(double, atof, const char *)
_SYSCALL2(double, strtod, const char *, char **)
_SYSCALL3(long int, strtol, const char *, char **, int)
_SYSCALL3(unsigned long int, strtoul, const char *, char **, int)

_SYSCALL1(void *, malloc, size_t)
_SYSCALL1(void, free, void *)
_SYSCALL2(void *, calloc, size_t, size_t)
_SYSCALL2(void *, realloc, void *, size_t)
_SYSCALL3(void *, memset, void *, int, size_t)
_SYSCALL3(void *, memcpy, void *, const void *, size_t)
_SYSCALL3(int, memcmp, const void *, const void *, size_t)
_SYSCALL3(void *, memmove, void *, const void *, size_t)
_SYSCALL2(void, memrev, char *, size_t)
_SYSCALL2(char *, strcpy, char *, const char *)
_SYSCALL3(char *, strncpy, char *, const char *, size_t)
_SYSCALL2(int, strcmp, const char *, const char *)
#define strcoll strcmp
_SYSCALL3(int, strncmp, const char *, const char *, size_t)
_SYSCALL1(int, strlen, const char *)
_SYSCALL3(char *, strncat, char *, const char *, size_t)
_SYSCALL2(char *, strchr, const char *, int)
_SYSCALL2(char *, strrchr, const char *, int)
_SYSCALL2(char *, strpbrk, const char *, const char *)
_SYSCALL1(char *, strerror, int)
_SYSCALL2(char *, strcat, char *, const char *)
_SYSCALL2(char *, strstr, const char *, const char *)
_SYSCALL2(char *, strtok, char *, const char *)

typedef __builtin_va_list va_list;
#define va_start(ap,p)  __builtin_va_start(ap, p)
#define va_arg(ap,type) __builtin_va_arg(ap, type)
#define va_end(ap) __builtin_va_end(ap)
#define va_copy(d,s) __builtin_va_copy(d,s)

_SYSCALLVAR(int, __attribute__((__format__(__printf__,1,2))), printf, __attribute__((unused)) const char *format, ...)
_SYSCALLVAR(int, __attribute__((__format__(__printf__,2,3))), sprintf, __attribute__((unused)) char *s, __attribute__((unused)) const char *format, ...)
_SYSCALLVAR(int, __attribute__((__format__(__printf__,2,3))), fprintf, __attribute__((unused)) FILE *s, __attribute__((unused)) const char *format, ...)
_SYSCALLVAR(int, __attribute__((__format__(__scanf__,2,3))), sscanf, __attribute__((unused)) const char *s, __attribute__((unused)) const char * format, ...)
// wrapper with cast to avoid the GCC warning "error: aggregate value used where an integer was expected"
#define vfprintf(str, fmt, arg) _vfprintf(str, fmt, *(void**)&arg)
_SYSCALL3(int, _vfprintf, FILE *, const char *, void*)
// wrapper with cast to avoid the GCC warning "error: aggregate value used where an integer was expected"
#define vprintf(fmt, arg) _vprintf(fmt, *(void**)&arg)
_SYSCALL2(int, _vprintf, const char *, void*)
_SYSCALLVAR(int, __attribute__((__format__(__printf__,3,4))), snprintf, __attribute__((unused)) char *str, __attribute__((unused)) size_t size, __attribute__((unused)) const char *format, ...)
// wrapper with cast to avoid the GCC warning "error: aggregate value used where an integer was expected"
#define vsnprintf(s, n, fmt, arg) _vsnprintf(s, n, fmt, *(void**)&arg)
_SYSCALL4(int, _vsnprintf, char *, size_t, const char *, void*)
// wrapper with cast to avoid the GCC warning "error: aggregate value used where an integer was expected"
#define vsprintf(str, fmt, arg) _vsprintf(str, fmt, *(void**)&arg)
_SYSCALL3(int, _vsprintf, char*, const char*, void*)

_SYSCALL1(int, puts, const char *)
_SYSCALL2(int, fputc, int, FILE *)
#define putc fputc
#define putchar(c) fputc(c, stdout)
_SYSCALL1(int, fgetc, FILE *)
#define getc fgetc
_SYSCALL2(int, ungetc, int, FILE *)

_SYSCALL_OSVAR(FILE *, stdin)
#define stdin stdin()
_SYSCALL_OSVAR(FILE *, stdout)
#define stdout stdout()
_SYSCALL_OSVAR(FILE *, stderr)
#define stderr stderr()

_SYSCALL2(FILE *, fopen, const char *, const char *)
_SYSCALL3(FILE *, freopen, const char *, const char *, FILE *)
_SYSCALL4(size_t, fread, void *, size_t, size_t, FILE *)
_SYSCALL4(size_t, fwrite, const void *, size_t, size_t, FILE *)
_SYSCALL1(int, fflush, FILE *)
_SYSCALL1(int, fclose, FILE *)
_SYSCALL1(int, ferror, FILE *)
_SYSCALL3(int, fseek, FILE *, long int, int)
_SYSCALL1(long int, ftell, FILE *)
_SYSCALL1(int, remove, const char *)

_SYSCALL2(int, mkdir, const char *, int)
_SYSCALL2(char *, getcwd, char *, size_t)
_SYSCALL1(int, chdir, char *)
_SYSCALL1(int, rmdir, const char *)
_SYSCALL2(int, stat, const char *, struct stat *)
_SYSCALL2(int, rename, const char *, const char *)
_SYSCALL1(int, unlink, const char *)
typedef void DIR;
struct dirent {
	char d_name[0];
};
_SYSCALL1(DIR *,opendir, const char * /* name */)
_SYSCALL1(int, closedir, DIR * /* dir */)
_SYSCALL1(struct dirent *, readdir, DIR * /* dir */)

typedef void NU_TASK;
_SYSCALL1(int, TCT_Local_Control_Interrupts, int)
_SYSCALL0(NU_TASK *, TCC_Current_Task_Pointer)
_SYSCALL1(int, TCC_Terminate_Task, NU_TASK *)

_SYSCALL2(int, NU_Current_Dir, const char *, const char *)
_SYSCALL2(int, NU_Get_First, struct dstat *, const char * /* pattern */)
_SYSCALL1(int, NU_Get_Next, struct dstat *)
_SYSCALL1(void, NU_Done, struct dstat *)
_SYSCALL1(int, NU_Set_Current_Dir, const char *)
_SYSCALL3(PCFD, NU_Open, char * /* name */, unsigned /* flag */, unsigned /* mode */)
_SYSCALL1(int, NU_Close, PCFD /* fd */)
_SYSCALL2(int, NU_Truncate, PCFD /* fd */, long /* offset */)

_SYSCALL0(const char *, get_documents_dir)

/* 1: clickpad, 2: 84+, 3: touchpad prototype, 4: touchpad */
_SYSCALL_OSVAR(unsigned char *, keypad_type)
#define keypad_type keypad_type()
// For internal use by libndls. Returns 0 on failure, 1 on success.
_SYSCALL3(int, touchpad_read, unsigned char /* start */, unsigned char /* end */, void * /* buf */)
// For internal use by libndls. Returns 0 on failure, 1 on success.
_SYSCALL3(int, touchpad_write, unsigned char /* start */, unsigned char /* end */, void * /* buf */)
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
_SYSCALL1(int, get_event, struct s_ns_event*)
_SYSCALL4(void, send_key_event, struct s_ns_event* /* eventbuf */, unsigned short /* keycode_asciicode */, BOOL /* is_key_up */, BOOL /* unknown */)
// keycode_asciicode=0xFB00: single click
// keycode_asciicode=0xAC00: drag
_SYSCALL4(void, send_click_event, struct s_ns_event* /* eventbuf */, unsigned short /* keycode_asciicode */, BOOL /* is_key_up */, BOOL /* unknown */)
_SYSCALL4(void, send_pad_event, struct s_ns_event* /* eventbuf */, unsigned short /* keycode_asciicode */, BOOL /* is_key_up */, BOOL /* unknown */)

_SYSCALL0(void, refresh_homescr)
_SYSCALL1(void, refresh_docbrowser, int)

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
_SYSCALL2(char *, get_res_string, int, int)

#define Z_NO_FLUSH      0
#define Z_PARTIAL_FLUSH 1
#define Z_SYNC_FLUSH    2
#define Z_FULL_FLUSH    3
#define Z_FINISH        4
#define Z_BLOCK         5
#define Z_TREES         6
/* Allowed flush values; see deflate() and inflate() below for details */

#define Z_OK            0
#define Z_STREAM_END    1
#define Z_NEED_DICT     2
#define Z_ERRNO        (-1)
#define Z_STREAM_ERROR (-2)
#define Z_DATA_ERROR   (-3)
#define Z_MEM_ERROR    (-4)
#define Z_BUF_ERROR    (-5)
#define Z_VERSION_ERROR (-6)

#define Z_NULL  0  /* for initializing zalloc, zfree, opaque */

typedef void * (*zlib_alloc_func)(void * opaque, uint32_t items, uint32_t size);
typedef void   (*zlib_free_func) (void * opaque, void * address);

struct internal_state;

typedef struct z_stream_s {
    uint8_t  *next_in;  /* next input byte */
    uint32_t avail_in;  /* number of bytes available at next_in */
    uint32_t total_in;  /* total nb of input bytes read so far */

    uint8_t  *next_out; /* next output byte should be put there */
    uint32_t avail_out; /* remaining free space at next_out */
    uint32_t total_out; /* total nb of bytes output so far */

    char     *msg;      /* last error message, NULL if no error */
    struct internal_state *state; /* not visible by applications */

    zlib_alloc_func zalloc;  /* used to allocate the internal state */
    zlib_free_func  zfree;   /* used to free the internal state */
    void *  opaque;  /* private data object passed to zalloc and zfree */

    uint8_t  data_type;  /* best guess about the data type: binary or text */
    uint32_t adler;      /* adler32 value of the uncompressed data */
    uint32_t reserved;   /* reserved for future use */
} z_stream, *z_streamp;

_SYSCALL3(uint32_t, adler32, uint32_t /* adler */ , const uint8_t * /* buf */, uint32_t /* len */)
_SYSCALL3(uint32_t, crc32, uint32_t /* crc */ , const uint8_t * /* buf */ , uint32_t /* len */)
_SYSCALL3(uint32_t, crc32_combine, uint32_t /* crc1 */, uint32_t /* crc2 */, uint32_t /* len2 */)

_SYSCALL0(const char *, zlibVersion)
_SYSCALL0(uint32_t, zlibCompileFlags)

_SYSCALL(uint32_t, deflateInit2_, z_streamp strm, uint32_t level, uint32_t method, uint32_t windowBits, uint32_t memLevel, uint32_t strategy, const char * version, uint32_t stream_size) _SYSCALL_ARGS(uint32_t, deflateInit2_, strm, level, method, windowBits, memLevel, strategy, version, stream_size)
//_SYSCALL4(uint32_t, deflateInit_, z_streamp /* strm */, uint32_t /* level */, const char * /* version */, uint32_t /* stream_size */)
_SYSCALL2(uint32_t, deflate, z_streamp /* strm */, uint32_t /* flush */)
_SYSCALL1(uint32_t, deflateEnd, z_streamp /* strm */)
_SYSCALL4(uint32_t, inflateInit2_, z_streamp /* strm */, uint32_t /* windowBits */, const char * /* version */, uint32_t /* stream_size */)
_SYSCALL2(uint32_t, inflate, z_streamp /* strm */, uint32_t /* flush */)
_SYSCALL1(uint32_t, inflateEnd, z_streamp /* strm */)

#include <lauxlib.h>
_SYSCALL3(void, luaL_register, lua_State *, const char *, const luaL_Reg *)
_SYSCALL3(const char *, luaL_checklstring, lua_State *, int, size_t *)
_SYSCALLVAR(int,, luaL_error, __attribute__((unused)) lua_State *L, __attribute__((unused)) const char *fmt, ...)

/* lauxlib.h  */
_SYSCALL4(void, luaI_openlib, lua_State *, const char *, const luaL_Reg *, int)
_SYSCALL3(int, luaL_getmetafield, lua_State *, int, const char *)
_SYSCALL3(int, luaL_callmeta, lua_State *, int, const char *)
_SYSCALL3(int, luaL_typerror, lua_State *, int, const char *)
_SYSCALL3(int, luaL_argerror, lua_State *, int, const char *)
_SYSCALL4(const char*, luaL_optlstring, lua_State *, int, const char *, size_t *)
_SYSCALL2(lua_Number, luaL_checknumber, lua_State *, int)
_SYSCALL3(lua_Number, luaL_optnumber, lua_State *, int, lua_Number)

_SYSCALL2(lua_Integer, luaL_checkinteger, lua_State *, int)
_SYSCALL3(lua_Integer, luaL_optinteger, lua_State *, int, lua_Integer)

_SYSCALL3(void, luaL_checkstack, lua_State *, int, const char *)
_SYSCALL3(void, luaL_checktype, lua_State *, int, int);
_SYSCALL2(void, luaL_checkany, lua_State *, int);

_SYSCALL2(int  , luaL_newmetatable, lua_State *, const char *)
_SYSCALL3(void *, luaL_checkudata, lua_State *, int, const char *)

_SYSCALL2(void, luaL_where, lua_State *, int)

_SYSCALL4(int, luaL_checkoption, lua_State *, int, const char *, const char *const*)

_SYSCALL2(int, luaL_ref, lua_State *, int)
_SYSCALL3(void, luaL_unref, lua_State *, int, int)

_SYSCALL2(int, luaL_loadfile, lua_State *, const char *)
_SYSCALL4(int, luaL_loadbuffer, lua_State *, const char *, size_t, const char *)
_SYSCALL2(int, luaL_loadstring, lua_State *, const char *)

_SYSCALL0(lua_State *, luaL_newstate)

_SYSCALL4(const char *, luaL_gsub, lua_State *, const char *, const char *, const char *)

_SYSCALL4(const char *, luaL_findtable, lua_State *, int, const char *, int)

_SYSCALL2(void, luaL_buffinit, lua_State *, luaL_Buffer *)
_SYSCALL1(char *, luaL_prepbuffer, luaL_Buffer *)
_SYSCALL3(void, luaL_addlstring, luaL_Buffer *, const char *, size_t)
_SYSCALL2(void, luaL_addstring, luaL_Buffer *, const char *)
_SYSCALL1(void, luaL_addvalue, luaL_Buffer *)
_SYSCALL1(void, luaL_pushresult, luaL_Buffer *)

/* lua.h */
_SYSCALL2(lua_State *, lua_newstate, lua_Alloc, void *)
_SYSCALL1(void, lua_close, lua_State *)
_SYSCALL1(lua_State *, lua_newthread, lua_State *)
_SYSCALL2(lua_CFunction, lua_atpanic, lua_State *, lua_CFunction)
_SYSCALL1(int, lua_gettop, lua_State *)
_SYSCALL2(void, lua_settop, lua_State *, int)
_SYSCALL2(void, lua_pushvalue, lua_State *, int)
_SYSCALL2(void, lua_remove, lua_State *, int)
_SYSCALL2(void, lua_insert, lua_State *, int)
_SYSCALL2(void, lua_replace, lua_State *, int)
_SYSCALL2(int, lua_checkstack, lua_State *, int)
_SYSCALL3(void, lua_xmove, lua_State *, lua_State *, int)
_SYSCALL2(int, lua_isnumber, lua_State *, int)
_SYSCALL2(int, lua_isstring, lua_State *, int)
_SYSCALL2(int, lua_iscfunction, lua_State *, int)
_SYSCALL2(int, lua_isuserdata, lua_State *, int)
_SYSCALL2(int, lua_type, lua_State *, int)
_SYSCALL2(const char *, lua_typename, lua_State *, int)
_SYSCALL3(int, lua_equal, lua_State *, int, int)
_SYSCALL3(int, lua_rawequal, lua_State *, int, int)
_SYSCALL3(int, lua_lessthan, lua_State *, int, int)
_SYSCALL2(lua_Number, lua_tonumber, lua_State *, int)
_SYSCALL2(lua_Integer, lua_tointeger, lua_State *, int)
_SYSCALL2(int, lua_toboolean, lua_State *, int)
_SYSCALL3(const char *, lua_tolstring, lua_State *, int, size_t *)
_SYSCALL2(size_t, lua_objlen, lua_State *, int)
_SYSCALL2(lua_CFunction, lua_tocfunction, lua_State *, int)
_SYSCALL2(void *, lua_touserdata, lua_State *, int)
_SYSCALL2(lua_State *, lua_tothread, lua_State *, int)
_SYSCALL2(const void *, lua_topointer, lua_State *, int)
_SYSCALL1(void, lua_pushnil, lua_State *)
_SYSCALL2(void, lua_pushnumber, lua_State *, lua_Number)
_SYSCALL2(void, lua_pushinteger, lua_State *, lua_Integer)
_SYSCALL3(void, lua_pushlstring, lua_State *, const char *, size_t)
_SYSCALL2(void, lua_pushstring, lua_State *, const char *)
_SYSCALL3(const char *, lua_pushvfstring, lua_State *, const char *, va_list*)
_SYSCALLVAR(const char *,, lua_pushfstring, __attribute__((unused)) lua_State *L, __attribute__((unused)) const char *fmt, ...)
_SYSCALL3(void, lua_pushcclosure, lua_State *, lua_CFunction, int)
_SYSCALL2(void, lua_pushboolean, lua_State *, int)
_SYSCALL2(void, lua_pushlightuserdata, lua_State *, void *)
_SYSCALL1(int, lua_pushthread, lua_State *)
_SYSCALL2(void, lua_gettable, lua_State *, int)
_SYSCALL3(void, lua_getfield, lua_State *, int, const char *)
_SYSCALL2(void, lua_rawget, lua_State *, int)
_SYSCALL3(void, lua_rawgeti, lua_State *, int, int)
_SYSCALL3(void, lua_createtable, lua_State *, int, int)
_SYSCALL2(void *, lua_newuserdata, lua_State *, size_t)
_SYSCALL2(int, lua_getmetatable, lua_State *, int)
_SYSCALL2(void, lua_getfenv, lua_State *, int)
_SYSCALL2(void, lua_settable, lua_State *, int)
_SYSCALL3(void, lua_setfield, lua_State *, int, const char *)
_SYSCALL2(void, lua_rawset, lua_State *, int)
_SYSCALL3(void, lua_rawseti, lua_State *, int, int)
_SYSCALL2(int, lua_setmetatable, lua_State *, int)
_SYSCALL2(int, lua_setfenv, lua_State *, int)
_SYSCALL3(void, lua_call, lua_State *, int, int)
_SYSCALL4(int, lua_pcall, lua_State *, int, int, int)
_SYSCALL3(int, lua_cpcall, lua_State *, lua_CFunction, void *)
_SYSCALL4(int, lua_load, lua_State *, lua_Reader, void *, const char *)
_SYSCALL3(int, lua_dump, lua_State *, lua_Writer, void *)
_SYSCALL2(int, lua_yield, lua_State *, int)
_SYSCALL2(int, lua_resume, lua_State *, int)
_SYSCALL1(int, lua_status, lua_State *)
_SYSCALL3(int, lua_gc, lua_State *, int, int)
_SYSCALL1(int, lua_error, lua_State *)
_SYSCALL2(int, lua_next, lua_State *, int)
_SYSCALL2(void, lua_concat, lua_State *, int)
_SYSCALL3(int, lua_getstack, lua_State *, int, lua_Debug *)
_SYSCALL3(int, lua_getinfo, lua_State *, const char *, lua_Debug *)

// TI-Nspire-specific USB stuff
#include <bsdcompat.h>
// 'a' must be 2. softc_size must not be null.
_SYSCALLVAR(int,, usb_register_driver, __attribute__((unused)) int a, __attribute__((unused)) int (*methods[])(device_t), __attribute__((unused)) const char *driver_name, __attribute__((unused)) int b, __attribute__((unused)) unsigned softc_size)

// From *BSD's bus.h
_SYSCALL1(void *, device_get_ivars, device_t)
_SYSCALL1(void *, device_get_softc, device_t)

// From *BSD's ubsdi.h
#include <usbdi.h>

_SYSCALL4(usbd_status, usbd_open_pipe, usbd_interface_handle, u_int8_t, u_int8_t, usbd_pipe_handle *)
_SYSCALL1(usbd_status, usbd_close_pipe, usbd_pipe_handle)
_SYSCALL1(usbd_status, usbd_transfer, usbd_xfer_handle)
_SYSCALL1(usbd_xfer_handle, usbd_alloc_xfer, usbd_device_handle)
_SYSCALL1(usbd_status, usbd_free_xfer, usbd_xfer_handle)
_SYSCALLVAR(void,, usbd_setup_xfer, __attribute__((unused)) usbd_xfer_handle a, __attribute__((unused)) usbd_pipe_handle b, __attribute__((unused)) usbd_private_handle c, __attribute__((unused)) void *d, __attribute__((unused)) u_int32_t e, __attribute__((unused)) u_int16_t f, __attribute__((unused)) u_int32_t g, __attribute__((unused)) usbd_callback h)
//_SYSCALLVAR(void,, usbd_setup_default_xfer, __attribute__((unused)) usbd_xfer_handle a, __attribute__((unused)) usbd_device_handle b, __attribute__((unused)) usbd_private_handle c, __attribute__((unused)) u_int32_t d, __attribute__((unused)) usb_device_request_t *e, __attribute__((unused)) void *f, __attribute__((unused)) u_int32_t g, __attribute__((unused)) u_int16_t h, __attribute__((unused)) usbd_callback i)
_SYSCALLVAR(void,, usbd_setup_isoc_xfer, __attribute__((unused)) usbd_xfer_handle a, __attribute__((unused)) usbd_pipe_handle b, __attribute__((unused)) usbd_private_handle c, __attribute__((unused)) u_int16_t *d, __attribute__((unused)) u_int32_t e, __attribute__((unused)) u_int16_t f, __attribute__((unused)) usbd_callback g)
_SYSCALLVAR(void,, usbd_get_xfer_status, __attribute__((unused)) usbd_xfer_handle a, __attribute__((unused)) usbd_private_handle *b, __attribute__((unused)) void **c, __attribute__((unused)) u_int32_t *d, __attribute__((unused)) usbd_status *e)
_SYSCALL2(usb_endpoint_descriptor_t *, usbd_interface2endpoint_descriptor, usbd_interface_handle, u_int8_t)
_SYSCALL1(usbd_status, usbd_abort_pipe, usbd_pipe_handle)
_SYSCALL1(usbd_status, usbd_clear_endpoint_stall, usbd_pipe_handle)
//_SYSCALL1(usbd_status, usbd_clear_endpoint_stall_async, usbd_pipe_handle)
//_SYSCALL1(void, usbd_clear_endpoint_toggle, usbd_pipe_handle)
_SYSCALL2(usbd_status, usbd_endpoint_count, usbd_interface_handle, u_int8_t *)
_SYSCALL2(usbd_status, usbd_interface_count, usbd_device_handle, u_int8_t *)
_SYSCALL2(usbd_status, usbd_interface2device_handle, usbd_interface_handle, usbd_device_handle *)
_SYSCALL3(usbd_status, usbd_device2interface_handle, usbd_device_handle, u_int8_t, usbd_interface_handle *)
_SYSCALL1(usbd_device_handle, usbd_pipe2device_handle, usbd_pipe_handle)
//_SYSCALL2(void *, usbd_alloc_buffer, usbd_xfer_handle, u_int32_t)
//_SYSCALL1(void, usbd_free_buffer, usbd_xfer_handle)
//_SYSCALL1(void *, usbd_get_buffer, usbd_xfer_handle)
_SYSCALL1(usbd_status, usbd_sync_transfer, usbd_xfer_handle)
struct s_usb_pipe_buf { // strangely needed by TI's usbd_open_pipe_intr
 	u_char *buf;
 	int dummy1; // set to 0
 	int dummy2; // set to 0
 };
_SYSCALLVAR(usbd_status,, usbd_open_pipe_intr, __attribute__((unused)) usbd_interface_handle b, __attribute__((unused)) u_int8_t c, __attribute__((unused)) u_int8_t d, __attribute__((unused)) usbd_pipe_handle * e, __attribute__((unused)) usbd_private_handle f, __attribute__((unused)) void *g, __attribute__((unused)) u_int32_t h, __attribute__((unused)) usbd_callback i, __attribute__((unused)) int j)
_SYSCALL3(usbd_status, usbd_do_request, usbd_device_handle , usb_device_request_t *, void *)
//_SYSCALL3(usbd_status, usbd_do_request_async, usbd_device_handle, usb_device_request_t *, void *)
_SYSCALLVAR(usbd_status,, usbd_do_request_flags, __attribute__((unused)) usbd_device_handle a, __attribute__((unused)) usb_device_request_t *b, __attribute__((unused)) void *c, __attribute__((unused)) u_int16_t d, __attribute__((unused)) int *e)
_SYSCALLVAR(usbd_status,, usbd_do_request_flags_pipe, __attribute__((unused)) usbd_device_handle a, __attribute__((unused)) usbd_pipe_handle b, __attribute__((unused)) usb_device_request_t *c, __attribute__((unused)) void *d, __attribute__((unused)) u_int16_t e, __attribute__((unused)) int *f)
_SYSCALL1(usb_interface_descriptor_t *, usbd_get_interface_descriptor, usbd_interface_handle)
_SYSCALL1(usb_config_descriptor_t *, usbd_get_config_descriptor, usbd_device_handle)
_SYSCALL1(usb_device_descriptor_t *, usbd_get_device_descriptor, usbd_device_handle)
_SYSCALL2(usbd_status, usbd_set_interface, usbd_interface_handle, int)
//_SYSCALL2(int, usbd_get_no_alts, usb_config_descriptor_t *, int)
_SYSCALL2(usbd_status,  usbd_get_interface, usbd_interface_handle, u_int8_t *)
//_SYSCALL3(void, usbd_fill_deviceinfo, usbd_device_handle, struct usb_device_info *, int)
//_SYSCALL1(int, usbd_get_interface_altindex, usbd_interface_handle)
_SYSCALL3(usb_interface_descriptor_t *,usbd_find_idesc, usb_config_descriptor_t *, int, int)
//_SYSCALL4(usb_endpoint_descriptor_t *,usbd_find_edesc, usb_config_descriptor_t *, int, int, int)
//_SYSCALL1(void, usbd_dopoll, usbd_interface_handle)
//_SYSCALL2(void, usbd_set_polling, usbd_interface_handle, int)
_SYSCALL1(const char *, usbd_errstr, usbd_status)
//_SYSCALL2(void, usbd_add_dev_event, int, usbd_device_handle)
//_SYSCALL3(void, usbd_add_drv_event, int, usbd_device_handle, device_ptr_t)
_SYSCALL3(void, usbd_devinfo, usbd_device_handle, int, char *)
_SYSCALL1(const struct usbd_quirks *, usbd_get_quirks, usbd_device_handle)
_SYSCALL2(usb_endpoint_descriptor_t *, usbd_get_endpoint_descriptor, usbd_interface_handle, u_int8_t)
//_SYSCALL1(usbd_status, usbd_reload_device_desc, usbd_device_handle)
//_SYSCALL2(void, usb_add_task, usbd_device_handle, struct usb_task *)
//_SYSCALL2(void, usb_rem_task, usbd_device_handle, struct usb_task *)

// A sub-set of the NavNet functions for calc-to-calc and cal-to-computer USB transfers
typedef void *nn_ch_t;
typedef void *nn_nh_t;
typedef void *nn_oh_t;

_SYSCALL1(uint32_t, TI_NN_GetConnMaxPktSize, nn_ch_t /* ch */)
// caution, returns 0 on timeout
_SYSCALLVAR(int16_t,, TI_NN_Read,  __attribute__((unused)) nn_ch_t ch,  __attribute__((unused)) uint32_t timeout,  __attribute__((unused)) void *buf,  __attribute__((unused)) uint32_t buf_size,  __attribute__((unused)) uint32_t *data_size)
_SYSCALL3(int16_t, TI_NN_Write, nn_ch_t /* ch */, void * /* buf */, uint32_t /* data_size */)
// workaround to make _SYSCALL accept a function pointer
typedef void (*__TI_NN_StartService_cb_t)(nn_ch_t, void*);
_SYSCALL3(int16_t, TI_NN_StartService, uint32_t /* service_id */, void * /* data */, __TI_NN_StartService_cb_t /* cb */)
_SYSCALL1(int16_t, TI_NN_StopService, uint32_t /* service_id */)
typedef void (*__TI_NN_RegisterNotifyCallback_cb_t)(void); // unknown parameters
// not working on calculator
_SYSCALL2(int16_t, TI_NN_RegisterNotifyCallback, uint32_t /* filter_flags */, __TI_NN_RegisterNotifyCallback_cb_t /* cb */);
_SYSCALL0(nn_oh_t, TI_NN_CreateOperationHandle)
_SYSCALL1(int16_t, TI_NN_NodeEnumInit, nn_ch_t /* ch */)
_SYSCALL1(int16_t, TI_NN_DestroyOperationHandle, nn_oh_t /* oh */)
_SYSCALL2(int16_t, TI_NN_NodeEnumNext, nn_oh_t /* oh */, nn_nh_t * /* nh */)
_SYSCALL1(int16_t, TI_NN_NodeEnumDone, nn_oh_t /* oh */)
_SYSCALL3(int16_t, TI_NN_Connect, nn_nh_t /* nh */, uint32_t /* service_id */, nn_ch_t * /* ch */)
_SYSCALL1(int16_t, TI_NN_Disconnect, nn_ch_t /* ch */)

// returns 1 on success
_SYSCALLVAR(void,, read_nand,  __attribute__((unused)) void* dest,  __attribute__((unused)) int size,  __attribute__((unused)) int nand_offset,  __attribute__((unused)) int unknown,  __attribute__((unused)) int percent_max,  __attribute__((unused)) void *progress_cb)
_SYSCALL3(int, write_nand, void * /* source */, int /* size */, unsigned int /* nand_offset */)
_SYSCALL2(int, nand_erase_range, int /* nand_start_offset */, int /* nand_end_offset */)

_SYSCALL_OSVAR(void *, calc_cmd)

/* Ndless extensions. Not available in thumb state. */
// Given a list of OS-specific value and its size, returns the value for the current OS.
// If the array isn't enough long for the current OS, returns 0.
// You may cast 'values' from unsigned* to int*.
_SYSCALL2(int, nl_osvalue, const int * /* values */, unsigned /* size */)
// Relocates a global variable initialized with symbols (for example an array of function pointers)
#define nl_relocdata(ptr, size) nl_relocdatab(ptr, size, &__base)
_SYSCALL3(void, nl_relocdatab, unsigned * /* dataptr */, unsigned /* size */, void * /* base */)
// 0 on non-CX, 1 on CX
_SYSCALL0(unsigned, nl_hwtype)
_SYSCALL0(unsigned, nl_osid)
_SYSCALL0(BOOL, nl_isstartup)
_SYSCALL0(lua_State *, nl_lua_getstate)
_SYSCALL0(void, nl_set_resident)
_SYSCALL0(unsigned, nl_ndless_rev)
_SYSCALL0(void, nl_no_scr_redraw)
_SYSCALL0(BOOL, nl_loaded_by_3rd_party_loader)
_SYSCALL0(unsigned, nl_hwsubtype)
_SYSCALL3(int, nl_exec, const char * /* prgm_path */, int /* argsn */, char **/* args */)
_SYSCALL1(unsigned, _nl_hassyscall, unsigned)
#define nl_hassyscall(s) _nl_hassyscall(CONCAT(e_,s))

/* stdlib replacements not directly available as syscalls */
extern unsigned __crt0exit;
extern unsigned __crt0_savedsp;
static void __attribute__((noreturn, naked)) exit(int __attribute__((unused)) status) {
	__asm volatile(
		" mov sp, %0 \n"
		" mov pc, %1"
		:: "r" (__crt0_savedsp), "r" (&__crt0exit));
	__builtin_unreachable();
}

static void __attribute__((noreturn)) abort(void) {
	exit(-1);
}

#endif // GCC C
#ifdef __cplusplus
}
#endif
#endif
