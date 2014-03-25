#include <ctype.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "emu.h"

void *virt_mem_ptr(u32 addr, u32 size) {
	// Note: this is not guaranteed to be correct when range crosses page boundary
	return phys_mem_ptr(mmu_translate(addr, false, NULL), size);
}

#include "disasm.c"

void backtrace(u32 fp) {
	u32 *frame;
	printf("Frame     PrvFrame Self     Return   Start\n");
	do {
		printf("%08X:", fp);
		frame = virt_mem_ptr(fp - 12, 16);
		if (!frame) {
			printf(" invalid address\n");
			break;
		}
		vprintf(" %08X %08X %08X %08X\n", (va_list)frame);
		if (frame[0] <= fp) /* don't get stuck in infinite loop :) */
			break;
		fp = frame[0];
	} while (frame[2] != 0);
}

static void dump(u32 addr) {
	u32 start = addr;
	u32 end = addr + 0x7F;

	u32 row, col;
	for (row = start & ~0xF; row <= end; row += 0x10) {
		u8 *ptr = virt_mem_ptr(row, 16);
		if (!ptr) {
			printf("Address %08X is not in RAM.\n", row);
			break;
		}
		printf("%08X  ", row);
		for (col = 0; col < 0x10; col++) {
			addr = row + col;
			if (addr < start || addr > end)
				printf("  ");
			else
				printf("%02X", ptr[col]);
			putchar(col == 7 && addr >= start && addr < end ? '-' : ' ');
		}
		printf("  ");
		for (col = 0; col < 0x10; col++) {
			addr = row + col;
			if (addr < start || addr > end)
				putchar(' ');
			else if (ptr[col] < 0x20)
				putchar('.');
			else
				putchar(ptr[col]);
		}
		putchar('\n');
	}
}

static u32 parse_expr(char *str) {
	u32 sum = 0;
	int sign = 1;
	if (str == NULL)
		return 0;
	while (*str) {
		int reg;
		if (isxdigit(*str)) {
			sum += sign * strtoul(str, &str, 16);
			sign = 1;
		} else if (*str == '+') {
			str++;
		} else if (*str == '-') {
			sign = -1;
			str++;
		} else if (*str == 'v') {
			sum += sign * mmu_translate(strtoul(str + 1, &str, 16), false, NULL);
			sign = 1;
		} else if (*str == 'r') {
			reg = strtoul(str + 1, &str, 10);
			sum += sign * arm.reg[reg];
			sign = 1;
		} else if (isxdigit(*str)) {
			sum += sign * strtoul(str, &str, 16);
			sign = 1;
		} else {
			for (reg = 13; reg < 16; reg++) {
				if (!memcmp(str, reg_name[reg], 2)) {
					str += 2;
					sum += sign * arm.reg[reg];
					sign = 1;
					goto ok;
				}
			}
			printf("syntax error\n");
			return 0;
			ok:;
		}
	}
	return sum;
}

u32 disasm_insn(u32 pc) {
	return arm.cpsr_low28 & 0x20 ? disasm_thumb_insn(pc) : disasm_arm_insn(pc);
}

static void disasm(u32 (*dis_func)(u32 pc)) {
	char *arg = strtok(NULL, " \n");
	u32 addr = arg ? parse_expr(arg) : arm.reg[15];
	int i;
	for (i = 0; i < 16; i++) {
		u32 len = dis_func(addr);
		if (!len) {
			printf("Address %08X is not in RAM.\n", addr);
			break;
		}
		addr += len;
	}
}

u32 *debug_next;
static void set_debug_next(u32 *next) {
	if (debug_next != NULL)
		RAM_FLAGS(debug_next) &= ~RF_EXEC_DEBUG_NEXT;
	if (next != NULL) {
		if (RAM_FLAGS(next) & RF_CODE_TRANSLATED)
			flush_translations();
		RAM_FLAGS(next) |= RF_EXEC_DEBUG_NEXT;
	}
	debug_next = next;
}

bool gdb_connected = false;
FILE *debugger_input;

static void native_debugger(void) {
	char line[300];
	char *cmd;
	u32 *cur_insn = virt_mem_ptr(arm.reg[15] & ~3, 4);

	// Did we hit the "next" breakpoint?
	if (cur_insn == debug_next) {
		set_debug_next(NULL);
		disasm_insn(arm.reg[15]);
	}

	if (cpu_events & EVENT_DEBUG_STEP) {
		cpu_events &= ~EVENT_DEBUG_STEP;
		disasm_insn(arm.reg[15]);
	}

	throttle_timer_off();
	while (1) {
		printf("debug> ");
		fflush(stdout);
		fflush(stderr);
		while (!fgets(line, sizeof line, debugger_input)) {
			if (debugger_input == stdin)
				exit(1);
			// switch to stdin and try again
			fclose(debugger_input);
			debugger_input = stdin;
		}
		if (debugger_input != stdin)
			printf("%s", line);
		cmd = strtok(line, " \n");
		if (!cmd) {
			continue;
		} else if (!stricmp(cmd, "?") || !stricmp(cmd, "h")) {
			printf(
				"Debugger commands:\n"
				"b - stack backtrace\n"
				"c - continue\n"
				"d <address> - dump memory\n"
				"k <address> <+r|+w|+x|-r|-w|-x> - add/remove breakpoint\n"
				"k - show breakpoints\n"
				"ln c - connect\n"
				"ln s <file> - send a file\n"
				"ln st <dir> - set target directory\n"
				"n - continue until next instruction\n"
				"pr <address> - port or memory read\n"
				"pw <address> <value> - port or memory write\n"
				"q - quit\n"
				"r - show registers\n"
				"rs <regnum> <value> - change register value\n"
				"ss <address> <length> <string> - search a string\n"
				"s - step instruction\n"
				"t+ - enable instruction translation\n"
				"t- - disable instruction translation\n"
				"u[a|t] [address] - disassemble memory\n"
				"wm <file> <start> <size> - write memory to file\n"
				"wf <file> <start> [size] - write file to memory\n");
		} else if (!stricmp(cmd, "b")) {
			char *fp = strtok(NULL, " \n");
			backtrace(fp ? parse_expr(fp) : arm.reg[11]);
		} else if (!stricmp(cmd, "r")) {
			int i, show_spsr;
			u32 cpsr = get_cpsr();
			char *mode;
			for (i = 0; i < 16; i++) {
				int newline = ((1 << 5) | (1 << 11) | (1 << 15)) & (1 << i);
				printf("%3s=%08x%c", reg_name[i], arm.reg[i], newline ? '\n' : ' ');
			}
			switch (cpsr & 0x1F) {
				case MODE_USR: mode = "usr"; show_spsr = 0; break;
				case MODE_SYS: mode = "sys"; show_spsr = 0; break;
				case MODE_FIQ: mode = "fiq"; show_spsr = 1; break;
				case MODE_IRQ: mode = "irq"; show_spsr = 1; break;
				case MODE_SVC: mode = "svc"; show_spsr = 1; break;
				case MODE_ABT: mode = "abt"; show_spsr = 1; break;
				case MODE_UND: mode = "und"; show_spsr = 1; break;
				default:       mode = "???"; show_spsr = 0; break;
			}
			printf("cpsr=%08x (N=%d Z=%d C=%d V=%d Q=%d IRQ=%s FIQ=%s T=%d Mode=%s)",
				cpsr,
				arm.cpsr_n, arm.cpsr_z, arm.cpsr_c, arm.cpsr_v,
				cpsr >> 27 & 1,
				(cpsr & 0x80) ? "off" : "on ",
				(cpsr & 0x40) ? "off" : "on ",
				cpsr >> 5 & 1,
				mode);
			if (show_spsr)
				printf(" spsr=%08x", get_spsr());
			printf("\n");
		} else if (!stricmp(cmd, "rs")) {
			char *reg = strtok(NULL, " \n");
			if (!reg) {
				printf("Parameters are missing.\n");
			} else {
				char *value = strtok(NULL, " \n");
				if (!value) {
					printf("Missing value parameter.\n");
				} else {
					int regi = atoi(reg);
					int valuei = parse_expr(value);
					if (regi >= 0 && regi < 15)
						arm.reg[regi] = valuei;
					else
						printf("Invalid register.\n");
				}
			}
		} else if (!stricmp(cmd, "k")) {
			char *addr_str = strtok(NULL, " \n");
			char *flag_str = strtok(NULL, " \n");
			if (!flag_str)
				flag_str = "+x";
			if (addr_str) {
				u32 addr = parse_expr(addr_str);
				void *ptr = phys_mem_ptr(addr & ~3, 4);
				if (ptr) {
					u32 *flags = &RAM_FLAGS(ptr);
					bool on = true;
					for (; *flag_str; flag_str++) {
						switch (tolower(*flag_str)) {
							case '+': on = true; break;
							case '-': on = false; break;
							case 'r':
								if (on) *flags |= RF_READ_BREAKPOINT;
								else *flags &= ~RF_READ_BREAKPOINT;
								break;
							case 'w':
								if (on) *flags |= RF_WRITE_BREAKPOINT;
								else *flags &= ~RF_WRITE_BREAKPOINT;
								break;
							case 'x':
								if (on) {
									if (*flags & RF_CODE_TRANSLATED) flush_translations();
									*flags |= RF_EXEC_BREAKPOINT;
								} else
									*flags &= ~RF_EXEC_BREAKPOINT;
								break;
						}
					}
				} else {
					printf("Address %08X is not in RAM.\n", addr);
				}
			} else {
				unsigned int area;
				for (area = 0; area < sizeof(mem_areas)/sizeof(*mem_areas); area++) {
					u32 *flags;
					u32 *flags_start = &RAM_FLAGS(mem_areas[area].ptr);
					u32 *flags_end = &RAM_FLAGS(mem_areas[area].ptr + mem_areas[area].size);
					for (flags = flags_start; flags != flags_end; flags++) {
						if (*flags & (RF_READ_BREAKPOINT | RF_WRITE_BREAKPOINT | RF_EXEC_BREAKPOINT)) {
							printf("%08x %c%c%c\n",
								mem_areas[area].base + ((u8 *)flags - (u8 *)flags_start),
								(*flags & RF_READ_BREAKPOINT)  ? 'r' : ' ',
								(*flags & RF_WRITE_BREAKPOINT) ? 'w' : ' ',
								(*flags & RF_EXEC_BREAKPOINT)  ? 'x' : ' ');
						}
					}
				}
			}
		} else if (!stricmp(cmd, "c")) {
			break;
		} else if (!stricmp(cmd, "s")) {
			cpu_events |= EVENT_DEBUG_STEP;
			break;
		} else if (!stricmp(cmd, "n")) {
			if (cur_insn)
				set_debug_next(cur_insn + 1);
			break;
		} else if (!stricmp(cmd, "d")) {
			char *arg = strtok(NULL, " \n");
			if (!arg) {
				printf("Missing address parameter.\n");
			} else {
				u32 addr = parse_expr(arg);
				dump(addr);
			}
		} else if (!stricmp(cmd, "u")) {
			disasm(disasm_insn);
		} else if (!stricmp(cmd, "ua")) {
			disasm(disasm_arm_insn);
		} else if (!stricmp(cmd, "ut")) {
			disasm(disasm_thumb_insn);
		} else if (!stricmp(cmd, "ln")) {
			char *ln_cmd = strtok(NULL, " \n");
			if (!ln_cmd) continue;
			if (!stricmp(ln_cmd, "c")) {
				usblink_connect();
				break; // and continue, ARM code needs to be run
			} else if (!stricmp(ln_cmd, "s")) {
				char *file = strtok(NULL, "\n");
				if (!file) {
					printf("Missing file parameter.\n");
				} else {
					// remove optional surrounding quotes
					if (*file == '"') file++;
					size_t len = strlen(file);
					if (*(file + len - 1) == '"')
						*(file + len - 1) = '\0';
					if (usblink_put_file(file, target_folder))
						break; // and continue
				}
			} else if (!stricmp(ln_cmd, "st")) {
				char *dir = strtok(NULL, " \n");
				if (dir)
					strncpy(target_folder, dir, sizeof target_folder);
				else
					printf("Missing directory parameter.\n");
			}
		} else if (!stricmp(cmd, "taskinfo")) {
			u32 task = parse_expr(strtok(NULL, " \n"));
			u8 *p = virt_mem_ptr(task, 52);
			if (p) {
				printf("Previous:	%08x\n", *(u32 *)&p[0]);
				printf("Next:		%08x\n", *(u32 *)&p[4]);
				printf("ID:		%c%c%c%c\n", p[15], p[14], p[13], p[12]);
				printf("Name:		%.8s\n", &p[16]);
				printf("Status:		%02x\n", p[24]);
				printf("Delayed suspend:%d\n", p[25]);
				printf("Priority:	%02x\n", p[26]);
				printf("Preemption:	%d\n", p[27]);
				printf("Stack start:	%08x\n", *(u32 *)&p[36]);
				printf("Stack end:	%08x\n", *(u32 *)&p[40]);
				printf("Stack pointer:	%08x\n", *(u32 *)&p[44]);
				printf("Stack size:	%08x\n", *(u32 *)&p[48]);
				u32 sp = *(u32 *)&p[44];
				u32 *psp = virt_mem_ptr(sp, 18 * 4);
				if (psp) {
					printf("Stack type:	%d (%s)\n", psp[0], psp[0] ? "Interrupt" : "Normal");
					if (psp[0]) {
						vprintf("cpsr=%08x  r0=%08x r1=%08x r2=%08x r3=%08x  r4=%08x\n"
						        "  r5=%08x  r6=%08x r7=%08x r8=%08x r9=%08x r10=%08x\n"
						        " r11=%08x r12=%08x sp=%08x lr=%08x pc=%08x\n",
							(va_list)&psp[1]);
					} else {
						vprintf("cpsr=%08x  r4=%08x  r5=%08x  r6=%08x r7=%08x r8=%08x\n"
						        "  r9=%08x r10=%08x r11=%08x r12=%08x pc=%08x\n",
							(va_list)&psp[1]);
					}
				}
			}
		} else if (!stricmp(cmd, "tasklist")) {
			u32 tasklist = parse_expr(strtok(NULL, " \n"));
			u8 *p = virt_mem_ptr(tasklist, 4);
			if (p) {
				u32 first = *(u32 *)p;
				u32 task = first;
				printf("Task      ID   Name     St D Pr P | StkStart StkEnd   StkPtr   StkSize\n");
				do {
					p = virt_mem_ptr(task, 52);
					if (!p)
						break;
					printf("%08X: %c%c%c%c %-8.8s %02x %d %02x %d | %08x %08x %08x %08x\n",
						task, p[15], p[14], p[13], p[12],
						&p[16], /* name */
						p[24],  /* status */
						p[25],  /* delayed suspend */
						p[26],  /* priority */
						p[27],  /* preemption */
						*(u32 *)&p[36], /* stack start */
						*(u32 *)&p[40], /* stack end */
						*(u32 *)&p[44], /* stack pointer */
						*(u32 *)&p[48]  /* stack size */
						);
					task = *(u32 *)&p[4]; /* next */
				} while (task != first);
			}
		} else if (!stricmp(cmd, "t+")) {
			do_translate = 1;
		} else if (!stricmp(cmd, "t-")) {
			flush_translations();
			do_translate = 0;
		} else if (!stricmp(cmd, "q")) {
			exit(1);
		} else if (!stricmp(cmd, "wm") || !stricmp(cmd, "wf")) {
			bool frommem = cmd[1] != 'f';
			char *filename = strtok(NULL, " \n");
			char *start_str = strtok(NULL, " \n");
			char *size_str = strtok(NULL, " \n");
			if (!start_str) {
				printf("Parameters are missing.\n");
				continue;
			}
			u32 start = parse_expr(start_str);
			u32 size = 0;
			if (size_str)
				size = parse_expr(size_str);
			void *ram = phys_mem_ptr(start, size);
			if (!ram) {
				printf("Address range %08x-%08x is not in RAM.\n", start, start + size - 1);
				continue;
			}
			FILE *f = fopen(filename, frommem ? "wb" : "rb");
			if (!f) {
				perror(filename);
				continue;
			}
			if (!size && !frommem) {
				fseek (f, 0, SEEK_END);
				size = ftell(f);
				rewind(f);
			}
			// Use of |, not ||, is intentional. File should be closed regardless of read/write success.
			if (!(frommem ? fwrite(ram, size, 1, f) : fread(ram, size, 1, f)) | fclose(f)) {
				perror(filename);
				continue;
			}
		} else if (!stricmp(cmd, "ss")) {
			char *addr_str = strtok(NULL, " \n");
			char *len_str = strtok(NULL, " \n");
			char *string = strtok(NULL, " \n");
			if (!addr_str || !len_str || !string) {
				printf("Missing parameters.\n");
			} else {
				u32 addr = parse_expr(addr_str);
				u32 len = parse_expr(len_str);
				char *strptr = phys_mem_ptr(addr, len);
				char *ptr = strptr;
				char *endptr = strptr + len;
				if (ptr) {
					size_t slen = strlen(string);
					while (1) {
						ptr = memchr(ptr, *string, endptr - ptr);
						if (!ptr) {
							printf("String not found.\n");
							break;
						}
						if (!memcmp(ptr, string, slen)) {
							printf("Found at address %08X.\n", ptr - strptr + addr);
							break;
						}
						if (ptr < endptr)
							ptr++;
					}
				} else {
					printf("Address range %08x-%08x is not in RAM.\n", addr, addr + len - 1);
				}
			}
		} else if (!stricmp(cmd, "int")) {
			printf("active		= %08x\n", intr.active);
			printf("status		= %08x\n", intr.status);
			printf("mask		= %08x %08x\n", intr.mask[0], intr.mask[1]);
			printf("priority_limit	= %02x       %02x\n", intr.priority_limit[0], intr.priority_limit[1]);
			printf("noninverted	= %08x\n", intr.noninverted);
			printf("sticky		= %08x\n", intr.sticky);
			printf("priority:\n");
			int i, j;
			for (i = 0; i < 32; i += 16) {
				printf("\t");
				for (j = 0; j < 16; j++)
					printf("%02x ", intr.priority[i+j]);
				printf("\n");
			}
		} else if (!stricmp(cmd, "int+")) {
			int_set(atoi(strtok(NULL, " \n")), 1);
		} else if (!stricmp(cmd, "int-")) {
			int_set(atoi(strtok(NULL, " \n")), 0);
		} else if (!stricmp(cmd, "pr")) {
			// TODO: need to avoid entering debugger recursively
			// also, where should error() go?
			u32 addr = parse_expr(strtok(NULL, " \n"));
			printf("%08x\n", mmio_read_word(addr));
		} else if (!stricmp(cmd, "pw")) {
			// TODO: ditto
			u32 addr = parse_expr(strtok(NULL, " \n"));
			u32 value = parse_expr(strtok(NULL, " \n"));
			mmio_write_word(addr, value);
		} else {
			printf("Unknown command %s\n", cmd);
		}
	}
	throttle_timer_on();
}

void debugger(enum DBG_REASON reason, u32 addr) {
	if (gdb_connected)
		gdbstub_debugger(reason, addr);
	else
		native_debugger();
}

#if 0
void *debug_save_state(size_t *size) {
	(void)size;
	return NULL;
}

void debug_reload_state(void *state) {
	(void)state;
}
#endif
