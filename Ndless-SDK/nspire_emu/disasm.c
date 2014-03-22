static char *strcpy2(char *dest, const char *src) {
	while ((*dest = *src)) { dest++; src++; }
	return dest;
}

static const char reg_name[16][4] = {
	"r0", "r1", "r2",  "r3",  "r4",  "r5", "r6", "r7",
	"r8", "r9", "r10", "r11", "r12", "sp", "lr", "pc"
};

static const char condcode[16][3] = {
	"eq", "ne", "cs", "cc", "mi", "pl", "vs", "vc",
	"hi", "ls", "ge", "lt", "gt", "le", "",   "2"
};

enum suffix {
	none_,
	XY,      // halfword signed mul
	Y,       // halfword signed mul
	S,       // Bit 20    S: alu, MUL etc
	B,       // Bit 22    B: LDR/STR, SWP
	BT,      // Bit 21    T: LDR/STR with postindex (bit 24=0)
	M,       // Bit 23-24 DA/IA/DB/IB
	H,       // H/SB/SH
	D,       // double-word insn
	L,       // Bit 22    L: LDC/STC
};

enum operand {
	none,
	REG0,  // Bits 0-3   specify register
	REG8,  // Bits 8-11  specify register
	REG12, // Bits 12-15 specify register
	REG16, // Bits 16-19 specify register
	PSR,
	SHFOP, // Bits 0-11  specify shifted reg or immediate
	IMMED, // Bits 0-11  specify rotated immediate
	MEM,
	MEMH,
	MEM16,
	MULTI,
	BRCH,  // Bits 0-23  specify branch target
	BRCHT, // Bits 0-24  specify branch target for THUMB code
	COPR,  // Bits 8-11  specify coprocessor number
	CDP, MRC, MRRC, MEMC,
	BKPT, SWI,
};

static const struct arm_insn {
	u32 mask;
	u32 value;
	char name[7];
	u8 suffix;
	u8 op1, op2, op3, op4;
} table[] = {
	{0xFD70F000,0xF550F000, "pld",   0, MEM,   none,  none,  none  },
	{0xFE000000,0xFA000000, "blx",   0, BRCHT, none,  none,  none  },

	/* Coprocessor instructions may have any condition field */
	{ 0xFF00000, 0xC400000, "mcrr",  0, COPR,  MRRC,  none,  none  },
	{ 0xFF00000, 0xC500000, "mrrc",  0, COPR,  MRRC,  none,  none  },
	{ 0xE100000, 0xC000000, "stc",   L, COPR,  MEMC,  none,  none  },
	{ 0xE100000, 0xC100000, "ldc",   L, COPR,  MEMC,  none,  none  },
	{ 0xF000010, 0xE000000, "cdp",   0, COPR,  CDP,   none,  none  },
	{ 0xF100010, 0xE000010, "mcr",   0, COPR,  MRC,   none,  none  },
	{ 0xF100010, 0xE100010, "mrc",   0, COPR,  MRC,   none,  none  },

	/* No other instructions are valid with condition field 1111 */
	{0xF0000000,0xF0000000, "???",   0, none,  none,  none,  none  },

	{ 0xFE0F0F0, 0x0000090, "mul",   S, REG16, REG0,  REG8,  none  },
	{ 0xFE000F0, 0x0200090, "mla",   S, REG16, REG0,  REG8,  REG12 },
	{ 0xFE000F0, 0x0800090, "umull", S, REG12, REG16, REG0,  REG8  },
	{ 0xFE000F0, 0x0A00090, "umlal", S, REG12, REG16, REG0,  REG8  },
	{ 0xFE000F0, 0x0C00090, "smull", S, REG12, REG16, REG0,  REG8  },
	{ 0xFE000F0, 0x0E00090, "smlal", S, REG12, REG16, REG0,  REG8  },
	{ 0xFB00FF0, 0x1000090, "swp",   B, REG12, REG0,  MEM16, none  },
	{ 0xE0000F0, 0x0000090, "???",   0, none,  none,  none,  none  },

	{ 0xE1000F0, 0x00000B0, "str",   H, REG12, MEMH,  none,  none  },
	{ 0xE1010F0, 0x00000D0, "ldr",   D, REG12, MEMH,  none,  none  },
	{ 0xE1010F0, 0x00000F0, "str",   D, REG12, MEMH,  none,  none  },
	{ 0xE1000F0, 0x01000B0, "ldr",   H, REG12, MEMH,  none,  none  },
	{ 0xE1000F0, 0x01000D0, "ldr",   H, REG12, MEMH,  none,  none  },
	{ 0xE1000F0, 0x01000F0, "ldr",   H, REG12, MEMH,  none,  none  },

	{ 0xFBF0FFF, 0x10F0000, "mrs",   0, REG12, PSR,   none,  none  },
	{ 0xFB0FFF0, 0x120F000, "msr",   0, PSR,   REG0,  none,  none  },
	{ 0xFF00FF0, 0x1000050, "qadd",  0, REG12, REG0,  REG16, none  },
	{ 0xFF00FF0, 0x1200050, "qsub",  0, REG12, REG0,  REG16, none  },
	{ 0xFF00FF0, 0x1400050, "qdadd", 0, REG12, REG0,  REG16, none  },
	{ 0xFF00FF0, 0x1600050, "qdsub", 0, REG12, REG0,  REG16, none  },
	{0xFFF000F0,0xE1200070, "bkpt",  0, BKPT,  none,  none,  none  },

	{ 0xFB0F000, 0x320F000, "msr",   0, PSR,   IMMED, none,  none  },

	{ 0xFF00090, 0x1000080, "smla",  XY,REG16, REG0,  REG8,  REG12 },
	{ 0xFF000B0, 0x1200080, "smlaw", Y, REG16, REG0,  REG8,  REG12 },
	{ 0xFF0F0B0, 0x12000A0, "smulw", Y, REG16, REG0,  REG8,  none  },
	{ 0xFF00090, 0x1400080, "smlal", XY,REG12, REG16, REG0,  REG8  },
	{ 0xFF0F090, 0x1600080, "smul",  XY,REG16, REG0,  REG8,  none  },

	{ 0xFFFFFF0, 0x12FFF10, "bx",    0, REG0,  none,  none,  none  },
	{ 0xFFFFFF0, 0x12FFF20, "bxj",   0, REG0,  none,  none,  none  },
	{ 0xFFFFFF0, 0x12FFF30, "blx",   0, REG0,  none,  none,  none  },

	{ 0xFFF0FF0, 0x16F0F10, "clz",   0, REG12, REG0,  none,  none  },

	{ 0xDE00000, 0x0000000, "and",   S, REG12, REG16, SHFOP, none  },
	{ 0xDE00000, 0x0200000, "eor",   S, REG12, REG16, SHFOP, none  },
	{ 0xDE00000, 0x0400000, "sub",   S, REG12, REG16, SHFOP, none  },
	{ 0xDE00000, 0x0600000, "rsb",   S, REG12, REG16, SHFOP, none  },
	{ 0xDE00000, 0x0800000, "add",   S, REG12, REG16, SHFOP, none  },
	{ 0xDE00000, 0x0A00000, "adc",   S, REG12, REG16, SHFOP, none  },
	{ 0xDE00000, 0x0C00000, "sbc",   S, REG12, REG16, SHFOP, none  },
	{ 0xDE00000, 0x0E00000, "rsc",   S, REG12, REG16, SHFOP, none  },
	{ 0xDF0F000, 0x1100000, "tst",   0, REG16, SHFOP, none,  none  },
	{ 0xDF0F000, 0x1300000, "teq",   0, REG16, SHFOP, none,  none  },
	{ 0xDF0F000, 0x1500000, "cmp",   0, REG16, SHFOP, none,  none  },
	{ 0xDF0F000, 0x1700000, "cmn",   0, REG16, SHFOP, none,  none  },
	{ 0xDE00000, 0x1800000, "orr",   S, REG12, REG16, SHFOP, none  },
	{ 0xDEF0000, 0x1A00000, "mov",   S, REG12, SHFOP, none,  none  },
	{ 0xDE00000, 0x1C00000, "bic",   S, REG12, REG16, SHFOP, none  },
	{ 0xDEF0000, 0x1E00000, "mvn",   S, REG12, SHFOP, none,  none  },

	/* 4000000-9FFFFFF: word-sized memory accesses */
	{ 0xD100000, 0x4000000, "str",   BT,REG12, MEM,   none,  none  },
	{ 0xD100000, 0x4100000, "ldr",   BT,REG12, MEM,   none,  none  },
	{ 0xD100000, 0x5000000, "str",   B, REG12, MEM,   none,  none  },
	{ 0xD100000, 0x5100000, "ldr",   B, REG12, MEM,   none,  none  },
	{ 0xE100000, 0x8000000, "stm",   M, MULTI, none,  none,  none  },
	{ 0xE100000, 0x8100000, "ldm",   M, MULTI, none,  none,  none  },

	/* A000000-BFFFFFF: branches */
	{ 0xF000000, 0xA000000, "b",     0, BRCH,  none,  none,  none  },
	{ 0xF000000, 0xB000000, "bl",    0, BRCH,  none,  none,  none  },

	/* F000000-FFFFFFF: software interrupt */
	{ 0xF000000, 0xF000000, "swi",   0, SWI,   none,  none,  none  },

	/* Catch-all */
	{ 0x0000000, 0x0000000, "???",   0, none,  none,  none,  none  },
};

static char *do_shift(char *out, u32 insn) {
	static const char shifts[4][4] = { "lsl", "lsr", "asr", "ror" };
	int shift = insn >> 7 & 31;
	int stype = insn >> 5 & 3;

	out = strcpy2(out, reg_name[insn & 15]);
	if (insn & 0x10) {
		// shift by register (for data processing only, not load/store)
		if (shift & 1) {
			*out++ = '?';
			return out;
		} 
		out += sprintf(out, " %s %s", shifts[stype], reg_name[shift >> 1]);
	} else {
		// shift by immediate
		int shift = insn >> 7 & 31;
		int stype = insn >> 5 & 3;
		if (shift == 0) {
			if (stype == 0) {
				// lsl #0 is a no-op
				return out;
			} else if (stype == 3) {
				// ror #0 
				return strcpy2(out, " rrx");
			} else {
				// lsr #0 and asr #0 act like shift of 32
				shift = 32;
			}
		}
		out += sprintf(out, " %s #%d", shifts[stype], shift);
	}
	return out;
}

static char *do_reglist(char *out, int regs) {
	int i;
	*out++ = '{';
	for (i = 0; i < 16; i++) {
		if (regs >> i & 1) {
			out = strcpy2(out, reg_name[i]);
			if (regs >> i & 2) {
				*out++ = '-';
				while (regs >> ++i & 1);
				out = strcpy2(out, reg_name[i-1]);
			}
			*out++ = ',';
		}
	}
	out[-1] = '}';
	*out = '\0';
	return out;
}

u32 disasm_arm_insn(u32 pc) {
	char buf[80];
	u32 *pc_ptr = virt_mem_ptr(pc, 4);
	if (!pc_ptr)
		return 0;

	u32 insn = *pc_ptr;
	char *out = buf + sprintf(buf, "%08x: %08x\t", pc, insn);

	int i;

	const struct arm_insn *t = table;
	while ((insn & t->mask) != t->value)
		t++;

	out = strcpy2(out, t->name);

	switch (t->suffix) {
		case XY:
			*out++ = (insn & (1 << 5)) ? 't' : 'b';
			/* fallthrough */
		case Y:
			*out++ = (insn & (1 << 6)) ? 't' : 'b';
	}

	if (!(t->mask & 0xF0000000))
		out = strcpy2(out, condcode[insn >> 28]);

	switch (t->suffix) {
		case S:
			if (insn & (1 << 20)) *out++ = 's';
			break;
		case B:
			if (insn & (1 << 22)) *out++ = 'b';
			break;
		case BT:
			if (insn & (1 << 22)) *out++ = 'b';
			if (insn & (1 << 21)) *out++ = 't';
			break;
		case M:
			*out++ = insn & (1 << 23) ? 'i' : 'd';
			*out++ = insn & (1 << 24) ? 'b' : 'a';
			break;
		case H:
			if (insn & (1 << 6)) *out++ = 's';
			*out++ = insn & (1 << 5) ? 'h' : 'b';
			break;
		case D:
			*out++ = 'd';
			break;
		case L:
			if (insn & (1 << 22)) *out++ = 'l';
			break;
	}

	for (i = 0; i < 4 && (&t->op1)[i] != none; i++) {
		*out++ = i ? ',' : '\t';
		switch ((&t->op1)[i]) {
			case REG0:  out = strcpy2(out, reg_name[insn       & 15]); break;
			case REG8:  out = strcpy2(out, reg_name[insn >>  8 & 15]); break;
			case REG12: out = strcpy2(out, reg_name[insn >> 12 & 15]); break;
			case REG16: out = strcpy2(out, reg_name[insn >> 16 & 15]); break;
			case SHFOP:
				if (!(insn & (1 << 25))) {
					out = do_shift(out, insn);
					break;
				}
				/* fallthrough */
			case IMMED: {
				u32 imm = insn & 255, shift = insn >> 7 & 30;
				out += sprintf(out, "%08x", imm >> shift | imm << (32 - shift));
				break;
			}
			case PSR:
				*out++ = (insn & (1 << 22)) ? 's' : 'c';
				*out++ = 'p'; *out++ = 's'; *out++ = 'r';
				if (~insn >> 16 & 15) {
					*out++ = '_';
					if (insn & (1 << 19)) *out++ = 'f';
					if (insn & (1 << 18)) *out++ = 's';
					if (insn & (1 << 17)) *out++ = 'x';
					if (insn & (1 << 16)) *out++ = 'c';
				}
				break;
			case MEM:
				*out++ = '[';
				out = strcpy2(out, reg_name[insn >> 16 & 15]);
				if ((insn & 0x32F0000) == 0x10F0000) {
					// immediate, offset mode, PC relative
					int addr = insn & 0xFFF;
					if (!(insn & (1 << 23))) addr = -addr;
					addr += pc + 8;
					out -= 2;
					out += sprintf(out, "%08x]", addr);
					u32 *ptr = virt_mem_ptr(addr, 4);
					if (ptr)
						out += sprintf(out, " = %08x", *ptr);
				} else {
					if (!(insn & (1 << 24))) // post-index
						*out++ = ']';
					*out++ = ' ';
					*out++ = (insn & (1 << 23)) ? '+' : '-';
					*out++ = ' ';
					if (insn & (1 << 25)) {
						// register offset
						if (insn & 0x10) {
							// register shifted by register not allowed
							*out++ = '?';
						} else {
							out = do_shift(out, insn);
						}
					} else {
						// immediate offset
						if ((insn & 0xFFF) || !(insn & (1 << 23)))
							out += sprintf(out, "%03x", insn & 0xFFF);
						else
							// don't display an added offset of 0
							out -= 3;
					}
					if (insn & (1 << 24)) { // pre-index
						*out++ = ']';
						if (insn & (1 << 21)) // writeback
							*out++ = '!';
					}
				}
				break;
			case MEMH:
				*out++ = '[';
				out = strcpy2(out, reg_name[insn >> 16 & 15]);
				if (!(insn & (1 << 24))) // post-index
					*out++ = ']';
				*out++ = ' ';
				*out++ = (insn & (1 << 23)) ? '+' : '-';
				*out++ = ' ';
				if (insn & (1 << 22)) {
					// immediate offset
					u32 imm = (insn & 0x0F) | (insn >> 4 & 0xF0);
					if (imm || !(insn & (1 << 23)))
						out += sprintf(out, "%03x", imm);
					else
						// don't display an added offset of 0
						out -= 3;
				} else {
					// register offset
					out = strcpy2(out, reg_name[insn & 15]);
				}
				if (insn & (1 << 24)) { // pre-index
					*out++ = ']';
					if (insn & (1 << 21)) // writeback
						*out++ = '!';
				} else { // post-index
					// writeback assumed, setting W bit is invalid.
					if (insn & (1 << 21))
						*out++ = '?';
				}
				break;
			case MEM16:
				out += sprintf(out, "[%s]", reg_name[insn >> 16 & 15]);
				break;
			case MULTI:
				out = strcpy2(out, reg_name[insn >> 16 & 15]);
				if (insn & (1 << 21)) // Writeback
					*out++ = '!';
				*out++ = ',';
				out = do_reglist(out, insn & 0xFFFF);
				if (insn & (1 << 22)) // Load PSR or force user mode
					*out++ = '^';
				break;
			case BRCH:
				out += sprintf(out, "%08x", pc + 8 + ((int)insn << 8 >> 6));
				break;
			case BRCHT:
				out += sprintf(out, "%08x", pc + 8 + ((int)insn << 8 >> 6 | (insn >> 23 & 2)));
				break;
			case COPR:
				out += sprintf(out, "p%d", insn >> 8 & 15);
				break;
			case CDP:
				out += sprintf(out, "%d,c%d,c%d,c%d,%d", insn >> 20 & 15,
					insn >> 12 & 15, insn >> 16 & 15, insn & 15, insn >> 5 & 7);
				break;
			case MRC:
				out += sprintf(out, "%d,%s,c%d,c%d,%d", insn >> 21 & 7,
					reg_name[insn >> 12 & 15], insn >> 16 & 15, insn & 15, insn >> 5 & 7);
				break;
			case MRRC:
				out += sprintf(out, "%d,%s,%s,c%d", insn >> 4 & 15,
					reg_name[insn >> 12 & 15], reg_name[insn >> 16 & 15], insn & 15);
				break;
			case MEMC:
				out += sprintf(out, "c%d,[%s", insn >> 12 & 15,
					reg_name[insn >> 16 & 15]);
				if (!(insn & (1 << 24))) { // Post-indexed or unindexed
					*out++ = ']';
					if (!(insn & (1 << 21))) {
						// Unindexed addressing
						if (!(insn & (1 << 23)))
							*out++ = '?';
						out += sprintf(out, ",{%02x}", insn & 0xFF);
						break;
					}
				}
				if (!(insn & (1 << 23)) || insn & 0xFF)
					out += sprintf(out, " %c %03x",
						(insn & (1 << 23)) ? '+' : '-',
						(insn & 0xFF) << 2);
				if (insn & (1 << 24)) { // Pre-indexed or offset
					*out++ = ']';
					if (insn & (1 << 21)) // Writeback (pre-indexed)
						*out++ = '!';
				}
				break;
			case BKPT:
				out += sprintf(out, "%04x", (insn >> 4 & 0xFFF0) | (insn & 0x0F));
				break;
			case SWI:
				out += sprintf(out, "%06x", insn & 0xFFFFFF);
				break;
		}
	}
	*out = '\0';
	puts(buf);
	return 4;
}

u32 disasm_thumb_insn(u32 pc) {
	char buf[80];
	u16 *pc_ptr = virt_mem_ptr(pc, 2);
	if (!pc_ptr)
		return 0;

	u16 insn = *pc_ptr;
	char *out = buf + sprintf(buf, "%08x: %04x    \t", pc, insn);

	if (insn < 0x1800) {
		static const char name[][4] = { "lsl", "lsr", "asr" };
		sprintf(out, "%s\tr%d,r%d,%02x", name[insn >> 11],
			insn & 7, insn >> 3 & 7, insn >> 6 & 31);
	} else if (insn < 0x2000) {
		sprintf(out, "%s\tr%d,r%d,%s%d",
			insn & 0x0200 ? "sub" : "add",
			insn & 7, insn >> 3 & 7,
			(insn & 0x400) ? "" : "r", insn >> 6 & 7);
	} else if (insn < 0x4000) {
		static const char name[][4] = { "mov", "cmp", "add", "sub" };
		sprintf(out, "%s\tr%d,%02x", name[insn >> 11 & 3],
			insn >> 8 & 7, insn & 0xFF);
	} else if (insn < 0x4400) {
		static const char name[][4] = {
			"and", "eor", "lsl", "lsr", "asr", "adc", "sbc", "ror",
			"tst", "neg", "cmp", "cmn", "orr", "mul", "bic", "mvn"
		};
		sprintf(out, "%s\tr%d,r%d", name[insn >> 6 & 15], insn & 7, insn >> 3 & 7);
	} else if (insn < 0x4700) {
		static const char name[][4] = { "add", "cmp", "mov" };
		int rd = (insn & 7) | (insn >> 4 & 8);
		int rn = insn >> 3 & 15;
		if (!((rd | rn) & 8))
			goto invalid;
		sprintf(out, "%s\t%s,%s", name[insn >> 8 & 3], reg_name[rd], reg_name[rn]);
	} else if (insn < 0x4800) {
		if (insn & 7)
			goto invalid;
		sprintf(out, "%s\t%s", (insn & 0x80) ? "blx" : "bx", reg_name[insn >> 3 & 15]);
	} else if (insn < 0x5000) {
		int addr = ((pc + 4) & -4) + ((insn & 0xFF) << 2);
		out += sprintf(out, "ldr\tr%d,[%08x]", insn >> 8 & 7, addr);
		u32 *ptr = virt_mem_ptr(addr, 4);
		if (ptr)
			out += sprintf(out, " = %08x", *ptr);
	} else if (insn < 0x6000) {
		static const char name[][6] = {
			"str", "strh", "strb", "ldrsb",
			"ldr", "ldrh", "ldrb", "ldrsh"
		};
		sprintf(out, "%s\tr%d,[r%d + r%d]", name[insn >> 9 & 7],
			insn & 7, insn >> 3 & 7, insn >> 6 & 7);
	} else if (insn < 0x9000) {
		static const char name[][5] = { "str", "ldr", "strb", "ldrb", "strh", "ldrh" };
		int type = (insn - 0x6000) >> 11;
		sprintf(out, "%s\tr%d,[r%d + %03x]", name[type],
			insn & 7, insn >> 3 & 7,
			(insn >> 6 & 31) << (0x12 >> (type & 6) & 3));
	} else if (insn < 0xA000) {
		sprintf(out, "%s\tr%d,[sp + %03x]",
			(insn & 0x800) ? "ldr" : "str",
			insn >> 8 & 7, (insn & 0xFF) << 2);
	} else if (insn < 0xB000) {
		sprintf(out, "add\tr%d,%s,%03x",
			insn >> 8 & 7,
			(insn & 0x800) ? "sp" : "pc", (insn & 0xFF) << 2);
	} else if (insn < 0xB100) {
		sprintf(out, "%s\tsp,%03x",
			(insn & 0x80) ? "sub" : "add", (insn & 0x7F) << 2);
	} else if (insn < 0xB400) {
		goto invalid;
	} else if (insn < 0xB600) {
		out = strcpy2(out, "push\t");
		do_reglist(out, (insn & 0xFF) | (insn & 0x100) << (14 - 8));
	} else if (insn < 0xBC00) {
		goto invalid;
	} else if (insn < 0xBE00) {
		out = strcpy2(out, "pop\t");
		do_reglist(out, (insn & 0xFF) | (insn & 0x100) << (15 - 8));
	} else if (insn < 0xBF00) {
		sprintf(out, "bkpt\t%02x", insn & 0xFF);
	} else if (insn < 0xC000) {
		goto invalid;
	} else if (insn < 0xD000) {
		out += sprintf(out, "%smia\tr%d!,", (insn & 0x800) ? "ld" : "st", insn >> 8 & 7);
		do_reglist(out, insn & 0xFF);
	} else if (insn < 0xDE00) {
		sprintf(out, "b%s\t%08x", condcode[insn >> 8 & 15], pc + 4 + ((s8)insn << 1));
	} else if (insn < 0xDF00) {
	invalid:
		sprintf(out, "???");
	} else if (insn < 0xE000) {
		sprintf(out, "swi\t%02x", insn & 0xFF);
	} else if (insn < 0xE800) {
		sprintf(out, "b\t%08x", pc + 4 + ((s32)insn << 21 >> 20));
	} else if (insn < 0xF000) {
		sprintf(out, "(blx\tlr + %03x)", (insn & 0x7FF) << 1);
	} else if (insn < 0xF800) {
		s32 target = (s32)insn << 21 >> 9;
		/* Check next instruction to see if this is part of a BL or BLX pair */
		pc_ptr = virt_mem_ptr(pc + 2, 2);
		if (pc_ptr && ((insn = *pc_ptr) & 0xE800) == 0xE800) {
			/* It is; show both instructions combined as one */
			target += pc + 4 + ((insn & 0x7FF) << 1);
			if (!(insn & 0x1000)) target &= ~3;
			sprintf(out - 5, "%04x\t%s\t%08x", insn,
				(insn & 0x1000) ? "bl" : "blx", target);
			puts(buf);
			return 4;
		}
		sprintf(out, "(add\tlr,pc,%08x)", target);
	} else {
		sprintf(out, "(bl\tlr + %03x)", (insn & 0x7FF) << 1);
	}
	puts(buf);
	return 2;
}
