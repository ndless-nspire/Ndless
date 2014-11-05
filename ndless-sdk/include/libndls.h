/****************************************************************************
 * libndls definitions
 ****************************************************************************/

/* This file is in the public domain.
 * See http://creativecommons.org/licenses/publicdomain/deed.fr */

#ifndef _LIBNDLS_H_
#define _LIBNDLS_H_

#define SCREEN_WIDTH            320
#define SCREEN_HEIGHT           240
#define BLACK                   0x0
#define WHITE                   0xF

#ifdef GNU_AS
	.macro halt
halt\@: b halt\@
	.endm

	.macro bkpt
#ifdef __thumb__
	.word 0xbe01
#else
	.long 0xE1212374
#endif
	.endm

#else /* GNU_AS */

#ifdef __cplusplus
extern "C" {
#endif

#include <keys.h>
#include <stdint.h>
#include <stdarg.h>
#include <sys/types.h>
#include <usbdi.h>
#include <os.h>
#include <nucleus.h>
#include <syscall-list.h>

// Directory where Ndless files are stored
#define NDLESS_DIR "/documents/ndless"

typedef struct {
	uint16_t width;
	uint16_t height;
} touchpad_info_t;

typedef struct {
	unsigned char contact; /* "touched". TRUE or FALSE */
	unsigned char proximity;
	uint16_t x;
	uint16_t y;
	unsigned char x_velocity;
	unsigned char y_velocity;
	uint16_t dummy;
	unsigned char pressed; /* "key pressed". TRUE or FALSE */
	unsigned char arrow; /* area of the pad currently touched. see tpad_arrow_t. */
} touchpad_report_t;

/* for set_cpu_speed() */
#define CPU_SPEED_150MHZ 0x00000002
#define CPU_SPEED_120MHZ 0x000A1002
#define CPU_SPEED_90MHZ  0x00141002

void assert_ndless_rev(unsigned required_rev);
BOOL any_key_pressed(void);
void clear_cache(void);
void clrscr(void);
int enable_relative_paths(char **argv);
int file_each(const char *folder, int (*callback)(const char *path, void *context), void *context);
void idle(void);
BOOL lcd_isincolor(void);
void lcd_incolor(void);
void lcd_ingray(void);
int locate(const char *filename, char *dst_path, size_t dst_path_size);
BOOL on_key_pressed(void);
void refresh_osscr(void);
unsigned _scrsize(void);
unsigned set_cpu_speed(unsigned speed);
unsigned _show_msgbox(const char *title, const char *msg, unsigned button_num, ...);
int show_msg_user_input(const char * title, const char * msg, char * defaultvalue, char ** value_ref);
int show_1numeric_input(const char * title, const char * subtitle, const char * msg, int * value_ref, int min_value, int max_value);
int show_2numeric_input(const char * title, const char * subtitle, const char * msg1, int * value1_ref, int min_value1, int max_value1, const char * msg2, int * value2_ref, int min_value2, int max_value2);
touchpad_info_t *touchpad_getinfo(void);
int touchpad_scan(touchpad_report_t *report);
BOOL touchpad_arrow_pressed(tpad_arrow_t arrow); /* internal, use isKeyPressed() */
usbd_status usbd_set_idle(usbd_interface_handle iface, int duration, int id);
usbd_status usbd_set_protocol(usbd_interface_handle iface, int report);
BOOL isKeyPressed(const t_key *key);
#define isKeyPressed(x) isKeyPressed(&x)
void wait_key_pressed(void);
void wait_no_key_pressed(void);
/* config.c */
void cfg_open(void);
void cfg_open_file(const char *filepath);
void cfg_close(void);
char *cfg_get(const char *key);
void cfg_register_fileext(const char *ext, const char *prgm);
void cfg_register_fileext_file(const char *fielpath, const char *ext, const char *prgm);
#define nl_hassyscall(x) _nl_hassyscall(e_##x)

BOOL _is_touchpad(void);
#define is_touchpad _is_touchpad()

static inline void halt(void) {
	__asm volatile("0: b 0b");
}

static inline void bkpt(void) {
#ifdef __thumb__
	asm(".word 0xBE01");
#else
	asm(".long 0xE1212374");
#endif
}
	
#define show_msgbox(title, msg) _show_msgbox(title, msg, 0)
#define show_msgbox_2b(title, msg, button1, button2) _show_msgbox(title, msg, 2, button1, button2)
#define show_msgbox_3b(title, msg, button1, button2, button3) _show_msgbox(title, msg, 3, button1, button2, button3)

unsigned hwtype(void);
#define is_classic (hwtype() < 1)
#define is_cm (nl_hwsubtype() == 1)
#define has_colors (!is_classic)
#define IO(a,b) (((volatile unsigned*[]){ (unsigned*)a, (unsigned*)b })[hwtype()])
#define IO_LCD_CONTROL IO(0xC000001C, 0xC0000018)

#define SCREEN_BASE_ADDRESS     (*(void**)0xC0000010)
#define SCREEN_BYTES_SIZE       ((int)({_scrsize();}))
#define SCREEN_BYTES_SIZE       ((int)({_scrsize();}))

#ifdef __cplusplus
}
#endif

#endif /* GNU_AS */
#endif /* _LIBNDLS_H_ */
