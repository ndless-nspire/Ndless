#include <stdio.h>

typedef unsigned char      u8;
typedef unsigned short     u16;
typedef unsigned int       u32;
typedef unsigned long long u64;
typedef signed char        s8;
typedef signed short       s16;
typedef signed int         s32;
typedef signed long long   s64;

typedef enum { false, true } bool;

static inline u16 BSWAP16(u16 x) { return x << 8 | x >> 8; }
static inline u32 BSWAP32(u32 x) {
	if (__builtin_constant_p(x)) return x << 24 | (x << 8 & 0xFF0000) | (x >> 8 & 0xFF00) | x >> 24;
	asm ("bswap %0" : "=r" (x) : "0" (x)); return x;
}

/* Declarations for emu.c */

extern int cycle_count_delta;

extern int throttle_delay;

extern u32 cpu_events;
#define EVENT_IRQ 1
#define EVENT_FIQ 2
#define EVENT_RESET 4
#define EVENT_DEBUG_STEP 8
#define EVENT_WAITING 16

extern bool exiting;
extern bool do_translate;
extern int product;
extern int asic_user_flags;
#define emulate_casplus (product == 0x0C0)
// 0C-0E (CAS, lab cradle, plain Nspire) use old ASIC
// 0F-12 (CX CAS, CX, CM CAS, CM) use new ASIC
#define emulate_cx (product >= 0x0F0)
extern bool turbo_mode;
extern bool is_halting;
extern bool show_speed;

enum { LOG_CPU, LOG_IO, LOG_FLASH, LOG_INTS, LOG_ICOUNT, LOG_USB, LOG_GDB, MAX_LOG };
#define LOG_TYPE_TBL "CIFQ#UG";
extern int log_enabled[MAX_LOG];
void logprintf(int type, char *str, ...);

void warn(char *fmt, ...);
__attribute__((noreturn)) void error(char *fmt, ...);
void throttle_timer_on();
void throttle_timer_off();
int exec_hack();
typedef void fault_proc(u32 mva, u8 status);
fault_proc prefetch_abort, data_abort;
void add_reset_proc(void (*proc)(void));

/* Declarations for casplus.c */

void casplus_lcd_draw_frame(u8 buffer[240][160]);
u8 casplus_nand_read_byte(u32 addr);
u16 casplus_nand_read_half(u32 addr);
void casplus_nand_write_byte(u32 addr, u8 value);
void casplus_nand_write_half(u32 addr, u16 value);

void casplus_int_set(u32 int_num, bool on);

u8 omap_read_byte(u32 addr);
u16 omap_read_half(u32 addr);
u32 omap_read_word(u32 addr);
void omap_write_byte(u32 addr, u8 value);
void omap_write_half(u32 addr, u16 value);
void omap_write_word(u32 addr, u32 value);

void casplus_reset(void);

/* Declarations for cpu.c */

struct arm_state {  // Remember to update asmcode.S if this gets rearranged
	u32 reg[16];    // Registers for current mode.

	u32 cpsr_low28; // CPSR bits 0-27
	u8  cpsr_n;     // CPSR bit 31
	u8  cpsr_z;     // CPSR bit 30
	u8  cpsr_c;     // CPSR bit 29
	u8  cpsr_v;     // CPSR bit 28

	/* CP15 registers */
	u32 control;
	u32 translation_table_base;
	u32 domain_access_control;
	u8  data_fault_status, instruction_fault_status;
	u32 fault_address;

	u32 r8_usr[5], r13_usr[2];
	u32 r8_fiq[5], r13_fiq[2], spsr_fiq;
	u32 r13_irq[2], spsr_irq;
	u32 r13_svc[2], spsr_svc;
	u32 r13_abt[2], spsr_abt;
	u32 r13_und[2], spsr_und;

	u8  interrupts;
};
extern struct arm_state arm;

#define MODE_USR 0x10
#define MODE_FIQ 0x11
#define MODE_IRQ 0x12
#define MODE_SVC 0x13
#define MODE_ABT 0x17
#define MODE_UND 0x1B
#define MODE_SYS 0x1F
#define PRIVILEGED_MODE() (arm.cpsr_low28 & 3)
#define USER_MODE()       (!(arm.cpsr_low28 & 3))

#define EX_RESET          0
#define EX_UNDEFINED      1
#define EX_SWI            2
#define EX_PREFETCH_ABORT 3
#define EX_DATA_ABORT     4
#define EX_IRQ            6
#define EX_FIQ            7

#define current_instr_size (arm.cpsr_low28 & 0x20 ? 2 /* thumb */ : 4)

void cpu_int_check();
u32 __attribute__((fastcall)) get_cpsr();
void set_cpsr_full(u32 cpsr);
void __attribute__((fastcall)) set_cpsr(u32 cpsr, u32 mask);
u32 __attribute__((fastcall)) get_spsr();
void __attribute__((fastcall)) set_spsr(u32 cpsr, u32 mask);
void cpu_exception(int type);
void cpu_interpret_instruction(u32 insn);
void cpu_arm_loop();
void cpu_thumb_loop();
void *cpu_save_state(size_t *size);
void cpu_reload_state(void *state);

/* Declarations for debug.c */

#ifdef EOF // following is only meaningful if stdio.h included
extern FILE *debugger_input;
#endif
extern bool gdb_connected;
enum DBG_REASON {
	DBG_USER,
	DBG_EXCEPTION,
	DBG_EXEC_BREAKPOINT,
	DBG_READ_BREAKPOINT,
	DBG_WRITE_BREAKPOINT,
};

void *virt_mem_ptr(u32 addr, u32 size);
void backtrace(u32 fp);
void debugger(enum DBG_REASON reason, u32 addr);
void *debug_save_state(size_t *size);
void debug_reload_state(void *state);

/* Declarations for des.c */

void des_initialize();
void des_reset(void);
u32 des_read_word(u32 addr);
void des_write_word(u32 addr, u32 value);
void *des_save_state(size_t *size);
void des_reload_state(void *state);

/* Declarations for flash.c */

extern bool nand_writable;
void nand_initialize(bool large);
void nand_write_command_byte(u8 command);
void nand_write_address_byte(u8 byte);
u8 nand_read_data_byte(void);
u32 nand_read_data_word(void);
void nand_write_data_byte(u8 value);
void nand_write_data_word(u32 value);

void nand_phx_reset(void);
u32 nand_phx_read_word(u32 addr);
void nand_phx_write_word(u32 addr, u32 value);
u8 nand_phx_raw_read_byte(u32 addr);
void nand_phx_raw_write_byte(u32 addr, u8 value);
u8 nand_cx_read_byte(u32 addr);
u32 nand_cx_read_word(u32 addr);
void nand_cx_write_byte(u32 addr, u8 value);
void nand_cx_write_word(u32 addr, u32 value);

void flash_open(char *filename);
void flash_save_changes();
int flash_save_as(char *filename);
void flash_create_new(char **preload, int product, bool large_sdram);
void flash_read_settings(u32 *sdram_size);
void *flash_save_state(size_t *size);
void flash_reload_state(void *state);

/* Declarations for gdbstub.c */

void gdbstub_init(int port);
void gdbstub_reset(void);
void gdbstub_recv(void);
void gdbstub_debugger(enum DBG_REASON reason, u32 addr);
void *gdbstub_save_state(size_t *size);
void gdbstub_reload_state(void *state);
 
/* Declarations for gui.c */

void gui_initialize();
void get_messages();
extern char target_folder[256];
void *gui_save_state(size_t *size);
void gui_reload_state(void *state);

/* Declarations for interrupt.c */

#define INT_SERIAL   1
#define INT_WATCHDOG 3
#define INT_USB      8
#define INT_ADC      11
#define INT_POWER    15
#define INT_KEYPAD   16
#define INT_TIMER0   17
#define INT_TIMER1   18
#define INT_TIMER2   19
#define INT_LCD      21

extern struct interrupt_state {
	u32 active;
	u32 raw_status;         // .active ^ ~.noninverted
	u32 sticky_status;      // set on rising transition of .raw_status
	u32 status;             // +x04: mixture of bits from .raw_status and .sticky_status
	                        //       (determined by .sticky)
	u32 mask[2];            // +x08: enabled interrupts
	u8  prev_pri_limit[2];  // +x28: saved .priority_limit from reading +x24
	u8  priority_limit[2];  // +x2C: interrupts with priority >= this value are disabled
	u32 noninverted;        // +200: which interrupts not to invert in .raw_status
	u32 sticky;             // +204: which interrupts to use .sticky_status
	u8  priority[32];       // +3xx: priority per interrupt (0=max, 7=min)
} intr;
u32 int_read_word(u32 addr);
void int_write_word(u32 addr, u32 value);
u32 int_cx_read_word(u32 addr);
void int_cx_write_word(u32 addr, u32 value);
void int_set(u32 int_num, bool on);
void int_reset();
void *int_save_state(size_t *size);
void int_reload_state(void *state);

/* Declarations for sha256.c */

void sha256_reset(void);
u32 sha256_read_word(u32 addr);
void sha256_write_word(u32 addr, u32 value);
void *sha256_save_state(size_t *size);
void sha256_reload_state(void *state);

/* Declarations for keypad.c */

#define NUM_KEYPAD_TYPES 5
extern volatile int keypad_type;
extern volatile u16 key_map[16];
extern volatile u8 touchpad_proximity;
extern volatile u16 touchpad_x;
extern volatile u16 touchpad_y;
extern volatile u8 touchpad_down;

extern struct keypad_controller_state {
	u32 control;
	u32 size;
	u8  current_row;
	u8  int_active;
	u8  int_enable;
	u16 data[16];
	u32 gpio_int_enable;
	u32 gpio_int_active;
} kpc;
void keypad_reset();
void keypad_int_check();
u32 keypad_read(u32 addr);
void keypad_write(u32 addr, u32 value);
void touchpad_cx_reset(void);
u32 touchpad_cx_read(u32 addr);
void touchpad_cx_write(u32 addr, u32 value);

#define TOUCHPAD_X_MAX 0x0918
#define TOUCHPAD_Y_MAX 0x069B
void touchpad_set(u8 proximity, u16 x, u16 y, u8 down);
void touchpad_gpio_reset(void);
void touchpad_gpio_change();
void *keypad_save_state(size_t *size);
void keypad_reload_state(void *state);

/* Declarations for lcd.c */

void lcd_draw_frame(u8 buffer[240][160]);
void lcd_cx_draw_frame(u16 buffer[240][320], u32 colormasks[3]);
void lcd_reset(void);
u32 lcd_read_word(u32 addr);
void lcd_write_word(u32 addr, u32 value);
void *lcd_save_state(size_t *size);
void lcd_reload_state(void *state);

/* Declarations for link.c */

void send_file(char *filename);

void ti84_io_link_reset(void);
u32 ti84_io_link_read(u32 addr);
void ti84_io_link_write(u32 addr, u32 value);
void *link_save_state(size_t *size);
void link_reload_state(void *state);

/* Declarations for memory.c */

#define MEM_MAXSIZE (65*1024*1024) // also defined as RAM_FLAGS in asmcode.S

// Must be allocated below 2GB (see comments for mmu.c)
extern u8 *mem_and_flags;
struct mem_area_desc {
	u32 base, size;
	u8 *ptr;
};
extern struct mem_area_desc mem_areas[4];
void *phys_mem_ptr(u32 addr, u32 size);

/* Each word of memory has a flag word associated with it. For fast access,
 * flags are located at a constant offset from the memory data itself.
 *
 * These can't be per-byte because a translation index wouldn't fit then.
 * This does mean byte/halfword accesses have to mask off the low bits to
 * check flags, but the alternative would be another 32MB of memory overhead. */
#define RAM_FLAGS(memptr) (*(u32 *)((u8 *)(memptr) + MEM_MAXSIZE))

#define RF_READ_BREAKPOINT   1
#define RF_WRITE_BREAKPOINT  2
#define RF_EXEC_BREAKPOINT   4
#define RF_EXEC_DEBUG_NEXT   8
#define RF_EXEC_HACK         16
#define RF_CODE_TRANSLATED   32
#define RF_CODE_NO_TRANSLATE 64
#define RF_READ_ONLY         128
#define RF_ARMLOADER_CB      256
#define RFS_TRANSLATION_INDEX 9

u8 bad_read_byte(u32 addr);
u16 bad_read_half(u32 addr);
u32 bad_read_word(u32 addr);
void bad_write_byte(u32 addr, u8 value);
void bad_write_half(u32 addr, u16 value);
void bad_write_word(u32 addr, u32 value);

u32 __attribute__((fastcall)) mmio_read_byte(u32 addr);
u32 __attribute__((fastcall)) mmio_read_half(u32 addr);
u32 __attribute__((fastcall)) mmio_read_word(u32 addr);
void __attribute__((fastcall)) mmio_write_byte(u32 addr, u32 value);
void __attribute__((fastcall)) mmio_write_half(u32 addr, u32 value);
void __attribute__((fastcall)) mmio_write_word(u32 addr, u32 value);

void memory_initialize();
void *memory_save_state(size_t *size);
void memory_reload_state(void *state);

/* Declarations for misc.c */

void sdramctl_write_word(u32 addr, u32 value);

void memctl_cx_reset(void);
u32 memctl_cx_read_word(u32 addr);
void memctl_cx_write_word(u32 addr, u32 value);

union gpio_reg { u32 w; u8 b[4]; };
extern struct gpio_state {
	union gpio_reg direction;
	union gpio_reg output;
	union gpio_reg input;
	union gpio_reg invert;
	union gpio_reg sticky;
	union gpio_reg unknown_24;
} gpio;
void gpio_reset();
u32 gpio_read(u32 addr);
void gpio_write(u32 addr, u32 value);

extern struct timerpair {
	struct timer {
		u16 ticks;
		u16 start_value;     /* Write value of +00 */
		u16 value;           /* Read value of +00  */
		u16 divider;         /* Value of +04 */
		u16 control;         /* Value of +08 */
	} timers[2];
	u16 completion_value[6];
	u8 int_mask;
	u8 int_status;
} timerpairs[3];
u32 timer_read(u32 addr);
void timer_write(u32 addr, u32 value);
void timer_reset(void);

void xmodem_send(char *filename);
void serial_reset(void);
u32 serial_read(u32 addr);
void serial_write(u32 addr, u32 value);
void serial_cx_reset(void);
u32 serial_cx_read(u32 addr);
void serial_cx_write(u32 addr, u32 value);
void serial_byte_in(u8 byte);

u32 unknown_cx_read(u32 addr);
void unknown_cx_write(u32 addr, u32 value);

void watchdog_reset();
u32 watchdog_read(u32 addr);
void watchdog_write(u32 addr, u32 value);

void unknown_9008_write(u32 addr, u32 value);

u32 rtc_read(u32 addr);
void rtc_write(u32 addr, u32 value);
u32 rtc_cx_read(u32 addr);
void rtc_cx_write(u32 addr, u32 value);

u32 misc_read(u32 addr);
void misc_write(u32 addr, u32 value);

extern struct pmu_state {
	u32 clocks_load;
	u32 wake_mask;
	u32 disable;
	u32 disable2;
	u32 clocks;
} pmu;
void pmu_reset(void);
u32 pmu_read(u32 addr);
void pmu_write(u32 addr, u32 value);

u32 timer_cx_read(u32 addr);
void timer_cx_write(u32 addr, u32 value);
void timer_cx_reset(void);

void hdq1w_reset(void);
u32 hdq1w_read(u32 addr);
void hdq1w_write(u32 addr, u32 value);

u32 unknown_9011_read(u32 addr);
void unknown_9011_write(u32 addr, u32 value);

u32 spi_read_word(u32 addr);
void spi_write_word(u32 addr, u32 value);

u8 sdio_read_byte(u32 addr);
u16 sdio_read_half(u32 addr);
u32 sdio_read_word(u32 addr);
void sdio_write_byte(u32 addr, u8 value);
void sdio_write_half(u32 addr, u16 value);
void sdio_write_word(u32 addr, u32 value);

u32 sramctl_read_word(u32 addr);
void sramctl_write_word(u32 addr, u32 value);

u32 unknown_BC_read_word(u32 addr);

void adc_reset();
u32 adc_read_word(u32 addr);
void adc_write_word(u32 addr, u32 value);

/* Declarations for mmu.c */

/* Translate a VA to a PA, using a page table lookup */
u32 mmu_translate(u32 addr, bool writing, fault_proc *fault);

/* Table for quickly accessing RAM and ROM by virtual addresses. This contains
 * two entries for each 1kB of virtual address space, one for reading and one
 * for writing, and each entry may contain one of three kinds of values:
 *
 * a) Pointer entry
 *    The result of adding the virtual address (VA) to the entry has bit 31
 *    clear, and that sum is a pointer to within mem_and_flags.
 *    It would be cleaner to just use bit 0 or 1 to distinguish this case, but
 *    this way we can simultaneously check both that this is a pointer entry,
 *    and that the address is aligned, with a single bit test instruction.
 * b) Physical address entry
 *    VA + entry has bit 31 set, and the entry (not the sum) has bit 22 clear.
 *    Bits 0-21 contain the difference between virtual and physical address.
 * c) Invalid entry
 *    VA + entry has bit 31 set, entry has bit 22 set. Entry is invalid and
 *    addr_cache_miss must be called.
 */
 
#define AC_NUM_ENTRIES (4194304*2)
typedef u8 *ac_entry;
extern ac_entry *addr_cache;
#define AC_SET_ENTRY_PTR(entry, va, ptr) \
	entry = (ptr) - (va);
#define AC_NOT_PTR 0x80000000
#define AC_SET_ENTRY_PHYS(entry, va, pa) \
	entry = (ac_entry)(((pa) - (va)) >> 10); \
	entry += (~(u32)((va) + entry) & AC_NOT_PTR);
#define AC_SET_ENTRY_INVALID(entry, va) \
	entry = (ac_entry)(1 << 22); \
	entry += (~(u32)((va) + entry) & AC_NOT_PTR);

bool addr_cache_pagefault(void *addr);
void *addr_cache_miss(u32 addr, bool writing, fault_proc *fault);
void addr_cache_flush();
void *mmu_save_state(size_t *size);
void mmu_reload_state(void *state);

/* Declarations for asmcode.S */

void translation_enter();

u32 __attribute__((fastcall)) read_byte(u32 addr);
u32 __attribute__((fastcall)) read_half(u32 addr);
u32 __attribute__((fastcall)) read_word(u32 addr);
u32 __attribute__((fastcall)) read_word_ldr(u32 addr);
void __attribute__((fastcall)) write_byte(u32 addr, u32 value);
void __attribute__((fastcall)) write_half(u32 addr, u32 value);
void __attribute__((fastcall)) write_word(u32 addr, u32 value);

/* Declarations for armsnippets.S */

enum SNIPPETS {
	SNIPPET_ndls_debug_alloc, SNIPPET_ndls_debug_free
};
extern char binary_snippets_bin_start[];
extern char binary_snippets_bin_end[];
enum ARMLOADER_PARAM_TYPE {ARMLOADER_PARAM_VAL, ARMLOADER_PARAM_PTR};
struct armloader_load_params {
	enum ARMLOADER_PARAM_TYPE t;
	union {
		struct p {
			void *ptr;
			unsigned int size;
		} p;
		u32 v; // simple value
	};
};
void armloader_cb(void);
int armloader_load_snippet(enum SNIPPETS snippet, struct armloader_load_params params[],
                           unsigned params_num, void (*callback)(struct arm_state *));

/* Declarations for schedule.c */

enum clock_id { CLOCK_CPU, CLOCK_AHB, CLOCK_APB, CLOCK_27M, CLOCK_12M, CLOCK_32K };
extern u32 clock_rates[6];
enum sched_item_index {
	SCHED_THROTTLE,
	SCHED_KEYPAD,
	SCHED_LCD,
	SCHED_TIMERS,
	SCHED_WATCHDOG,
	SCHED_NUM_ITEMS
};
#define SCHED_CASPLUS_TIMER1 SCHED_KEYPAD
#define SCHED_CASPLUS_TIMER2 SCHED_LCD
#define SCHED_CASPLUS_TIMER3 SCHED_TIMERS
extern struct sched_item {
	enum clock_id clock;
	int second; // -1 = disabled
	u32 tick;
	u32 cputick;
	void (*proc)(int index);
} sched_items[SCHED_NUM_ITEMS];

void sched_reset(void);
void event_repeat(int index, u32 ticks);
void sched_update_next_event(u32 cputick);
u32 sched_process_pending_events();
void event_clear(int index);
void event_set(int index, int ticks);
u32 event_ticks_remaining(int index);
void sched_set_clocks(int count, u32 *new_rates);
void *sched_save_state(size_t *size);
void sched_reload_state(void *state);

/* Declarations for translate.c */

struct translation {
	u32 unused;
	u32 jump_table;
	u32 *start_ptr;
	u32 *end_ptr;
};
extern struct translation translation_table[];
#define INSN_BUFFER_SIZE 10000000
extern u8 *insn_buffer;
extern u8 *insn_bufptr;

int translate(u32 start_pc, u32 *insnp);
void flush_translations();
void invalidate_translation(int index);
void fix_pc_for_fault();
int range_translated(u32 range_start, u32 range_end);
void *translate_save_state(size_t *size);
void translate_reload_state(void *state);

/* Declarations for usb.c */

extern struct usb_state {
	u32 usbcmd;      // +140
	u32 usbsts;      // +144
	u32 usbintr;     // +148
	u32 deviceaddr;  // +154
	u32 eplistaddr;  // +158
	u32 portsc;      // +184
	u32 otgsc;       // +1A4
	u32 epsetupsr;   // +1AC
	u32 epsr;        // +1B8
	u32 epcomplete;  // +1BC
} usb;
void usb_reset(void);
u8 usb_read_byte(u32 addr);
u16 usb_read_half(u32 addr);
u32 usb_read_word(u32 addr);
void usb_write_word(u32 addr, u32 value);

/* Declarations for usblink.c */

bool usblink_put_file(char *filepath, char *folder);
void usblink_send_os(char *filepath);

void usblink_reset();
void usblink_connect();
void *usblink_save_state(size_t *size);
void usblink_reload_state(void *state);
