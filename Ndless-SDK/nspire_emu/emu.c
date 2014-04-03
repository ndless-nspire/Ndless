#include <conio.h>
#include <ctype.h>
#include <setjmp.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "emu.h"
#include "os-win32.h"

/* cycle_count_delta is a (usually negative) number telling what the time is relative
 * to the next scheduled event. See sched.c */
int cycle_count_delta = 0;

int throttle_delay = 10; /* in milliseconds */

u32 cpu_events;

bool exiting;
bool do_translate = true;
int product = 0x0E0;
int asic_user_flags;
bool turbo_mode;
bool is_halting;
bool show_speed;

int gdb_port = 0;
int rdebug_port = 0;

jmp_buf restart_after_exception;

void (*reset_procs[20])(void);
int reset_proc_count;

const char log_type_tbl[] = LOG_TYPE_TBL;
int log_enabled[MAX_LOG];
FILE *log_file[MAX_LOG];
void logprintf(int type, char *str, ...) {
	if (log_enabled[type]) {
		va_list va;
		va_start(va, str);
		vfprintf(log_file[type], str, va);
		va_end(va);
	}
}

bool break_on_warn;
void warn(char *fmt, ...) {
	va_list va;
	fprintf(stderr, "Warning at PC=%08X: ", arm.reg[15]);
	va_start(va, fmt);
	vfprintf(stderr, fmt, va);
	va_end(va);
	fprintf(stderr, "\n");
	if (break_on_warn)
		debugger(DBG_EXCEPTION, 0);
}

__attribute__((noreturn))
void error(char *fmt, ...) {
	va_list va;
	fprintf(stderr, "Error at PC=%08X: ", arm.reg[15]);
	va_start(va, fmt);
	vfprintf(stderr, fmt, va);
	va_end(va);
	fprintf(stderr, "\n\tBacktrace:\n");
	backtrace(arm.reg[11]);
	debugger(DBG_EXCEPTION, 0);
	cpu_events |= EVENT_RESET;
	longjmp(restart_after_exception, 0);
}

int exec_hack() {
	if (arm.reg[15] == 0x10040) {
		arm.reg[15] = arm.reg[14];
		warn("BOOT1 is required to run this version of BOOT2.");
		return 1;
	}
	return 0;
}

void prefetch_abort(u32 mva, u8 status) {
	logprintf(LOG_CPU, "Prefetch abort: address=%08x status=%02x\n", mva, status);
	arm.reg[15] += 4;
	// Fault address register not changed
	arm.instruction_fault_status = status;
	cpu_exception(EX_PREFETCH_ABORT);
	if (mva == arm.reg[15])
		error("Abort occurred with exception vectors unmapped");
	longjmp(restart_after_exception, 0);
}

void data_abort(u32 mva, u8 status) {
	logprintf(LOG_CPU, "Data abort: address=%08x status=%02x\n", mva, status);
	fix_pc_for_fault();
	arm.reg[15] += 8;
	arm.fault_address = mva;
	arm.data_fault_status = status;
	cpu_exception(EX_DATA_ABORT);
	longjmp(restart_after_exception, 0);
}

os_frequency_t perffreq;

void throttle_interval_event(int index) {
	event_repeat(index, 27000000 / 100);

	/* Throttle interval (defined arbitrarily as 100Hz) - used for
	 * keeping the emulator speed down, and other miscellaneous stuff
	 * that needs to be done periodically */
	static int intervals;
	intervals++;

	extern void usblink_timer();
	usblink_timer();

	if (_kbhit()) {
		char c = _getch();
		if (c == 4)
			debugger(DBG_USER, 0);
		else
			serial_byte_in(c);
	}

	if (gdb_port)
		gdbstub_recv();
	if (rdebug_port)
		rdebug_recv();
	
	get_messages();

	os_time_t interval_end;
	os_query_time(interval_end);

	{	// Update graphics (frame rate is arbitrary)
		static os_time_t prev;
		s64 time = os_time_diff(interval_end, prev);
		if (time >= os_frequency_hz(perffreq) >> 5) {
			os_redraw_screen();
			prev = interval_end;
		}
	}

	if (show_speed) {
		// Show speed
		static int prev_intervals;
		static os_time_t prev;
		s64 time = os_time_diff(interval_end, prev);
		if (time >= os_frequency_hz(perffreq) >> 1) {
			double speed = (double)os_frequency_hz(perffreq) * (intervals - prev_intervals) / time;
			char buf[40];
			sprintf(buf, "nspire_emu - %.1f%%", speed);
			os_set_window_title(buf);
			prev_intervals = intervals;
			prev = interval_end;
		}
	}
	if (!turbo_mode || is_halting)
		throttle_timer_wait();
	if (is_halting)
		is_halting--;
}

#if 0
void *emu_save_state(size_t *size) {
	(void)size;
	return NULL;
}

void emu_reload_state(void *state) {
	(void)state;
}

void save_state(void) {
	#define SAVE_STATE_WRITE_CHUNK(module) \
		module##_save_state(NULL);
	printf("Saving state...\n");
	// ordered in reload order
	SAVE_STATE_WRITE_CHUNK(emu);
	flush_translations();
	SAVE_STATE_WRITE_CHUNK(memory);
	SAVE_STATE_WRITE_CHUNK(cpu);
	SAVE_STATE_WRITE_CHUNK(apb);
	SAVE_STATE_WRITE_CHUNK(debug);
	SAVE_STATE_WRITE_CHUNK(flash);
	SAVE_STATE_WRITE_CHUNK(gdbstub);
	SAVE_STATE_WRITE_CHUNK(gui);
	SAVE_STATE_WRITE_CHUNK(int);
	SAVE_STATE_WRITE_CHUNK(keypad);
	SAVE_STATE_WRITE_CHUNK(lcd);
	SAVE_STATE_WRITE_CHUNK(link);
	SAVE_STATE_WRITE_CHUNK(mmu);
	SAVE_STATE_WRITE_CHUNK(sha256);
	SAVE_STATE_WRITE_CHUNK(des);
	SAVE_STATE_WRITE_CHUNK(translate);
	SAVE_STATE_WRITE_CHUNK(usblink);
	//flash_save_changes();
	printf("State saved.\n");
}

// Returns true on success
bool reload_state(void) {
	#define RELOAD_STATE_READ_CHUNK(module) \
		module##_reload_state(NULL);
	printf("Reloading state...\n");
	//flash_reload();
	// ordered
	RELOAD_STATE_READ_CHUNK(emu);
	RELOAD_STATE_READ_CHUNK(memory);
	RELOAD_STATE_READ_CHUNK(cpu);
	RELOAD_STATE_READ_CHUNK(apb);
	RELOAD_STATE_READ_CHUNK(debug);
	RELOAD_STATE_READ_CHUNK(flash);
	RELOAD_STATE_READ_CHUNK(gdbstub);
	RELOAD_STATE_READ_CHUNK(gui);
	RELOAD_STATE_READ_CHUNK(int);
	RELOAD_STATE_READ_CHUNK(keypad);
	RELOAD_STATE_READ_CHUNK(lcd);
	RELOAD_STATE_READ_CHUNK(link);
	RELOAD_STATE_READ_CHUNK(mmu);
	RELOAD_STATE_READ_CHUNK(sha256);
	RELOAD_STATE_READ_CHUNK(des);
	RELOAD_STATE_READ_CHUNK(translate);
	RELOAD_STATE_READ_CHUNK(usblink);
	printf("State reloaded.\n");
	return true;
}
#endif

void add_reset_proc(void (*proc)(void)) {
	if (reset_proc_count == sizeof(reset_procs)/sizeof(*reset_procs))
		abort();
	reset_procs[reset_proc_count++] = proc;
}

int main(int argc, char **argv) {
	int i;
	static FILE *boot2_file = NULL;
	static char *boot1_filename = NULL, *boot2_filename = NULL, *flash_filename = NULL;
	char *preload_filename[4] = { NULL };
	bool preload = false;
	volatile u32 boot2_base = 0x11800000;
	u32 sdram_size;
	bool large_sdram = false;
	bool large_flash = false;

	for (i = 1; i < argc; i++) {
		char *arg = argv[i];
		if (*arg == '/' || *arg == '-') {
			arg++;
			switch (toupper(*arg++)) {
				case '1':
					if (*arg == '=') arg++;
					boot1_filename = arg;
					break;
				case 'B':
					if (*arg == '@') {
						boot2_base = strtoul(arg + 1, &arg, 16);
						if (boot2_base == 0) boot2_base = 0x10000000;
					}
					if (*arg == '=') arg++;
					boot2_filename = arg;
					boot2_file = fopen(boot2_filename, "rb");
					if (!boot2_file) {
						perror(boot2_filename);
						return 1;
					}
					break;
				case 'C':
					if (*arg == '=') arg++;
					rdebug_port = atoi(arg);
					if (!rdebug_port) {
						printf("Invalid listen port for remote debugging%s%s\n", *arg ? ": " : "", arg);
						exit(1);
					}
					break;
				case 'D':
					if (cpu_events & EVENT_DEBUG_STEP) goto usage;
					cpu_events |= EVENT_DEBUG_STEP;
					if (*arg) {
						if (*arg == '=')
							arg++;
						debugger_input = fopen(arg, "rt");
						if (!debugger_input) {
							perror(arg);
							return 1;
						}
					}
					break;
				case 'F':
					if (*arg == '=') arg++;
					flash_filename = arg;
					break;
				case 'G':
					if (*arg == '=') arg++;
					gdb_port = atoi(arg);
					if (!gdb_port) {
						printf("Invalid listen port for GDB stub%s%s\n", *arg ? ": " : "", arg);
						exit(1);
					}
					break;
				case 'K':
					keypad_type = 2;
					if (*arg) {
						keypad_type = atoi(arg);
						if (keypad_type < 0 || keypad_type >= NUM_KEYPAD_TYPES)
							goto usage;
					}
					break;
				case 'L': {
					char *p = strchr(log_type_tbl, toupper(*arg++));
					int type = p - log_type_tbl;
					if (!p) goto usage;
					log_enabled[type] = 1;
					if (arg[0] == '=') {
						char *p2 = strchr(log_type_tbl, toupper(arg[1]));
						int type2 = p2 - log_type_tbl;
						if (!p2) goto usage;
						log_file[type] = log_file[type2];
					} else if (strcmp(arg, "-") == 0) {
						log_file[type] = stdout;
					} else {
						log_file[type] = fopen(arg, "wb");
					}
					if (!log_file[type]) {
						perror(arg);
						exit(1);
					}
					break;
				}
				case 'M':
					switch (toupper(*arg)) {
						case 'P': product = 0x0C0; arg++; goto nocas;
						case 'L': product = 0x0D0; arg++; goto nocas;
						case 'X': product = 0x100; arg++; break;
						case 'M': product = 0x120; arg++; break;
					}
					if (toupper(*arg) == 'C') { // CAS
						product = (product == 0x0E0 ? 0x0C1 : (product - 0x10));
						arg++;
					}
				nocas:
					if (*arg) goto usage;
					break;
				case 'N':
					if (*arg) goto usage;
					large_flash = true;
					break;
				case 'P': {
					static const char tbl[] = "MBDO";
					char *p = strchr(tbl, toupper(*arg++));
					if (!p) goto usage;
					if (*arg == '=') arg++;
					preload_filename[p - tbl] = arg;
					preload = true;
					break;
				}
				case 'R':
					if (*arg) goto usage;
					large_sdram = true;
					break;
				case 'W':
					break_on_warn = true;
					break;
				default:
usage:
					printf(
						"nspire emulator v0.70[+Ndless-SDK patches]\n"
						"  /1=boot1	- location of BOOT1 image\n"
						"  /B=boot2	- location of decompressed BOOT2 image\n"
						"  /C=port  - enable remote debugging through the TCP port\n"
						"  /D[=cmdfile]	- enter debugger on startup (optionally read from file)\n"
						"  /F=file	- flash image filename\n"
						"  /G=port	- enable GDB remote protocol through the TCP port\n"
						"  /Kn		- set keypad type (2 = TI-84 Plus, 4 = Touchpad)\n"
						"  /M[P|X|M][C]	- set model (original/CAS+/CX/CM, non-CAS/CAS)\n"
						"  /N		- large NAND flash size\n"
						"  /PB=boot2.img	- preload flash with BOOT2 (.img file)\n"
						"  /PD=diags.img	- preload flash with DIAGS image\n"
						"  /PO=osfile	- preload flash with OS (.tnc/.tno file)\n"
						"  /R		- large SDRAM size\n"
						"  /W		- enter debugger on warning\n");
					return 1;
			}
		} else {
			goto usage;
		}
	}

	switch ((boot1_filename != NULL) + (boot2_filename != NULL)) {
		case 0: goto usage;
		case 1: break;
		default: printf("Must use exactly one of /1 or /B.\n"); return 0;
	}

	if (flash_filename) {
		if (preload) {
			printf("Can't preload to an existing flash image\n");
			return 1;
		}
		flash_open(flash_filename);
	} else {
		nand_initialize(large_flash);
		flash_create_new(preload_filename, product, large_sdram);
	}

	flash_read_settings(&sdram_size);

	// If /K not used, pick a default keypad type appropriate for the model
	if (keypad_type == -1) {
		if (emulate_casplus)
			keypad_type = 0;
		else if (emulate_cx)
			keypad_type = 4;
		else
			keypad_type = 1;
	}

	memory_initialize(sdram_size);

	u8 *rom = mem_areas[0].ptr;
	memset(rom, -1, 0x80000);
	for (i = 0x00000; i < 0x80000; i += 4) {
		RAM_FLAGS(&rom[i]) = RF_READ_ONLY;
	}
	if (boot1_filename) {
		/* Load the ROM */
		FILE *f = fopen(boot1_filename, "rb");
		if (!f) {
			perror(boot1_filename);
			return 1;
		}
		fread(rom, 1, 0x80000, f);
		fclose(f);
	}

	if (!debugger_input)
		debugger_input = stdin;

	insn_buffer = os_alloc_executable(INSN_BUFFER_SIZE);
	insn_bufptr = insn_buffer;

	os_exception_frame_t frame;
	addr_cache_init(&frame);

	os_query_frequency(perffreq);

	gui_initialize();

	throttle_timer_on();
	atexit(throttle_timer_off);

	if (gdb_port)
		gdbstub_init(gdb_port);
	if (rdebug_port)
		rdebug_bind(rdebug_port);

reset:
	memset(&arm, 0, sizeof arm);
	arm.control = 0x00050078;
	arm.cpsr_low28 = MODE_SVC | 0xC0;
	cpu_events &= EVENT_DEBUG_STEP;
	if (gdb_port)
		gdbstub_reset();
	if (boot2_file) {
		/* Start from BOOT2. (needs to be re-loaded on each reset since
		 * it can get overwritten in memory) */
		fseek(boot2_file, 0, SEEK_END);
		u32 boot2_size = ftell(boot2_file);
		fseek(boot2_file, 0, SEEK_SET);
		u8 *boot2_ptr = phys_mem_ptr(boot2_base, boot2_size);
		if (!boot2_ptr) {
			printf("Address %08X is not in RAM.\n", boot2_base);
			return 1;
		}
		fread(boot2_ptr, 1, boot2_size, boot2_file);
		arm.reg[15] = boot2_base;
		if (boot2_ptr[3] < 0xE0) {
			printf("%s does not appear to be an uncompressed BOOT2 image.\n", boot2_filename);
			return 1;
		}

		if (!emulate_casplus) {
			/* To enter maintenance mode (home+enter+P), address A4012ECC
			 * must contain an array indicating those keys before BOOT2 starts */
			u8 *shared = phys_mem_ptr(0xA4012EB0, 0x200);
			memcpy(&shared[0x1C], (void *)key_map, 0x12);

			/* BOOT1 is expected to store the address of a function pointer table
			 * to A4012EE8. OS 3.0 calls some of these functions... */
			static const struct {
				u32 ptrs[8];
				u16 code[16];
			} stuff = { {
				0x10020+0x01, // function 0: return *r0
				0x10020+0x05, // function 1: *r0 = r1
				0x10020+0x09, // function 2: *r0 |= r1
				0x10020+0x11, // function 3: *r0 &= ~r1
				0x10020+0x19, // function 4: *r0 ^= r1
				0x10020+0x20, // function 5: related to C801xxxx (not implemented)
				0x10020+0x03, // function 6: related to 9011xxxx (not implemented)
				0x10020+0x03, // function 7: related to 9011xxxx (not implemented)
			}, {
				0x6800,0x4770,               // return *r0
				0x6001,0x4770,               // *r0 = r1
				0x6802,0x430A,0x6002,0x4770, // *r0 |= r1
				0x6802,0x438A,0x6002,0x4770, // *r0 &= ~r1
				0x6802,0x404A,0x6002,0x4770, // *r0 ^= r1
			} };
			memcpy(&rom[0x10000], &stuff, sizeof stuff);
			RAM_FLAGS(&rom[0x10040]) |= RF_EXEC_HACK;
			*(u32 *)&shared[0x38] = 0x10000;
		}
	}
	addr_cache_flush();
	flush_translations();

	sched_reset();

	for (i = 0; i < reset_proc_count; i++)
		reset_procs[i]();

	sched_items[SCHED_THROTTLE].clock = CLOCK_27M;
	sched_items[SCHED_THROTTLE].proc = throttle_interval_event;

	sched_update_next_event(0);

	setjmp(restart_after_exception);

	while (!exiting) {
		sched_process_pending_events();
		while (cycle_count_delta < 0) {
			if (cpu_events & EVENT_RESET) {
				printf("Reset\n");
				goto reset;
			}

			if (cpu_events & (EVENT_FIQ | EVENT_IRQ)) {
				// Align PC in case the interrupt occurred immediately after a jump
				if (arm.cpsr_low28 & 0x20)
					arm.reg[15] &= ~1;
				else
					arm.reg[15] &= ~3;

				if (cpu_events & EVENT_WAITING)
					arm.reg[15] += 4; // Skip over wait instruction
				logprintf(LOG_INTS, "Dispatching an interrupt\n");
				arm.reg[15] += 4;
				cpu_exception((cpu_events & EVENT_FIQ) ? EX_FIQ : EX_IRQ);
			}
			cpu_events &= ~EVENT_WAITING;

			if (arm.cpsr_low28 & 0x20)
				cpu_thumb_loop();
			else
				cpu_arm_loop();
		}
	}
	return 0;
}
