#include <stdio.h>
#include <string.h>
#include "emu.h"

struct arm_state arm;

void cpu_int_check() {
	if (arm.interrupts & ~arm.cpsr_low28 & 0x80)
		cpu_events |= EVENT_IRQ;
	else
		cpu_events &= ~EVENT_IRQ;
	if (arm.interrupts & ~arm.cpsr_low28 & 0x40)
		cpu_events |= EVENT_FIQ;
	else
		cpu_events &= ~EVENT_FIQ;
}

/* Access the Current Program Status Register.
 * The flag bits (NZCV) are stored separately since they are so
 * frequently written to independently. */
u32 __attribute__((fastcall)) get_cpsr() {
	return arm.cpsr_n << 31
	     | arm.cpsr_z << 30
	     | arm.cpsr_c << 29
	     | arm.cpsr_v << 28
	     | arm.cpsr_low28;
}

void set_cpsr_full(u32 cpsr) {
	if ((cpsr ^ arm.cpsr_low28) & 0x1F) {
		/* Switching to a different processor mode. Swap out registers of old mode */
		if ((arm.cpsr_low28 & 0x1F) == MODE_FIQ)
			memcpy(arm.r8_fiq, &arm.reg[8], 20);
		else
			memcpy(arm.r8_usr, &arm.reg[8], 20);
		switch (arm.cpsr_low28 & 0x1F) {
			case MODE_USR:
			case MODE_SYS: memcpy(arm.r13_usr, &arm.reg[13], 8); break;
			case MODE_FIQ: memcpy(arm.r13_fiq, &arm.reg[13], 8); break;
			case MODE_IRQ: memcpy(arm.r13_irq, &arm.reg[13], 8); break;
			case MODE_SVC: memcpy(arm.r13_svc, &arm.reg[13], 8); break;
			case MODE_ABT: memcpy(arm.r13_abt, &arm.reg[13], 8); break;
			case MODE_UND: memcpy(arm.r13_und, &arm.reg[13], 8); break;
			default:       error("Invalid previous processor mode (This can't happen)\n");
		}

		/* Swap in registers of new mode */
		if ((cpsr & 0x1F) == MODE_FIQ)
			memcpy(&arm.reg[8], arm.r8_fiq, 20);
		else
			memcpy(&arm.reg[8], arm.r8_usr, 20);
		switch (cpsr & 0x1F) {
			case MODE_USR:
			case MODE_SYS: memcpy(&arm.reg[13], arm.r13_usr, 8); break;
			case MODE_FIQ: memcpy(&arm.reg[13], arm.r13_fiq, 8); break;
			case MODE_IRQ: memcpy(&arm.reg[13], arm.r13_irq, 8); break;
			case MODE_SVC: memcpy(&arm.reg[13], arm.r13_svc, 8); break;
			case MODE_ABT: memcpy(&arm.reg[13], arm.r13_abt, 8); break;
			case MODE_UND: memcpy(&arm.reg[13], arm.r13_und, 8); break;
			default:       error("Invalid new processor mode\n");
		}

		/* If going to or from user mode, memory access permissions may be different */
		if (!(arm.cpsr_low28 & 3) || !(cpsr & 3))
			addr_cache_flush();
	}

	if (cpsr & 0x01000000)
		error("J mode is not implemented");

	arm.cpsr_n = cpsr >> 31 & 1;
	arm.cpsr_z = cpsr >> 30 & 1;
	arm.cpsr_c = cpsr >> 29 & 1;
	arm.cpsr_v = cpsr >> 28 & 1;
	arm.cpsr_low28 = cpsr & 0x090000FF; /* Mask off reserved bits */
	cpu_int_check();
}
void __attribute__((fastcall)) set_cpsr(u32 cpsr, u32 mask) {
	if (!(arm.cpsr_low28 & 0x0F)) {
		/* User mode. Don't change privileged or execution state bits */
		mask &= ~0x010000FF;
	}
	cpsr = (cpsr & mask) | (get_cpsr() & ~mask);
	if (cpsr & 0x20)
		error("Cannot set T bit with MSR instruction");
	set_cpsr_full(cpsr);
}

/* Access the Saved Program Status Register. */
static u32 *ptr_spsr() {
	switch (arm.cpsr_low28 & 0x1F) {
		case MODE_FIQ: return &arm.spsr_fiq;
		case MODE_IRQ: return &arm.spsr_irq;
		case MODE_SVC: return &arm.spsr_svc;
		case MODE_ABT: return &arm.spsr_abt;
		case MODE_UND: return &arm.spsr_und;
	}
	error("Attempted to access SPSR from user or system mode");
}
inline u32 __attribute__((fastcall)) get_spsr() {
	return *ptr_spsr();
}
inline void set_spsr_full(u32 spsr) {
	*ptr_spsr() = spsr;
}
inline void __attribute__((fastcall)) set_spsr(u32 spsr, u32 mask) {
	*ptr_spsr() ^= (*ptr_spsr() ^ spsr) & mask;
}

/* Retrieve an ARM register. Deal with the annoying effect of the CPU pipeline
 * that accessing R15 (PC) gives you the next instruction plus 4 (8 for str/stm) */
static u32 get_reg_pc(int rn) {
	return arm.reg[rn] + ((rn == 15) ? 4 : 0);
}
static u32 get_reg_pc_store(int rn) {
	return arm.reg[rn] + ((rn == 15) ? 8 : 0);
}
static u32 get_reg_pc_thumb(int rn) {
	return arm.reg[rn] + ((rn == 15) ? 2 : 0);
}
static inline void set_reg_pc(int rn, u32 value) {
	arm.reg[rn] = value;
}
static inline void set_reg_pc_bx(int rn, u32 value) {
	if (rn == 15 && (value & 1)) {
		arm.reg[15] = value - 1;
		arm.cpsr_low28 |= 0x20; /* Enter THUMB mode */
		return;
	}
	arm.reg[rn] = value;
}
static u32 get_reg(int rn) {
	if (rn == 15) error("Invalid use of R15");
	return arm.reg[rn];
}
static void set_reg(int rn, u32 value) {
	if (rn == 15) error("Invalid use of R15");
	arm.reg[rn] = value;
}

static inline void set_nz_flags(u32 value) {
	arm.cpsr_n = value >> 31;
	arm.cpsr_z = value == 0;
}

static inline void set_nz_flags_64(u64 value) {
	arm.cpsr_n = value >> 63;
	arm.cpsr_z = value == 0;
}

/* Detect overflow after an addition or subtraction. */
#define ADD_OVERFLOW(left, right, sum) ((s32)(((left) ^ (sum)) & ((right) ^ (sum))) < 0)
#define SUB_OVERFLOW(left, right, sum) ((s32)(((left) ^ (right)) & ((left) ^ (sum))) < 0)

/* Do an addition, setting C/V flags accordingly. */
static u32 add(u32 left, u32 right, int carry, int setcc) {
	u32 sum = left + right + carry;
	if (setcc) {
		if (sum < left) carry = 1;
		if (sum > left) carry = 0;
		arm.cpsr_c = carry;
		arm.cpsr_v = ADD_OVERFLOW(left, right, sum);
	}
	return sum;
}

static int get_shifted_immed(int insn, int setcc) {
	int count = insn >> 7 & 30;
	s32 val = insn & 0xFF;
	val = val >> count | val << (32 - count);
	if (count != 0 && setcc)
		arm.cpsr_c = val < 0;
	return val;
}

static u32 shift(int type, u32 res, u32 count, int setcc) {
	if (count == 0) {
		/* For all types, a count of 0 does nothing and does not affect carry. */
		return res;
	}

	switch (type) {
		default: /* not used, obviously - here to shut up gcc warning */
		case 0: /* LSL */
			if (count >= 32) {
				if (setcc) arm.cpsr_c = (count == 32) ? (res & 1) : 0;
				return 0;
			}
			if (setcc) arm.cpsr_c = res >> (32 - count) & 1;
			return res << count;
		case 1: /* LSR */
			if (count >= 32) {
				if (setcc) arm.cpsr_c = (count == 32) ? (res >> 31) : 0;
				return 0;
			}
			if (setcc) arm.cpsr_c = res >> (count - 1) & 1;
			return res >> count;
		case 2: /* ASR */
			if (count >= 32) {
				count = 31;
				if (setcc) arm.cpsr_c = res >> 31;
			} else {
				if (setcc) arm.cpsr_c = res >> (count - 1) & 1;
			}
			return (s32)res >> count;
		case 3: /* ROR */
			count &= 31;
			res = res >> count | res << (32 - count);
			if (setcc) arm.cpsr_c = res >> 31;
			return res;
	}
}

static int get_shifted_reg(int insn, int setcc) {
	u32 res = get_reg_pc(insn & 15);
	int type = insn >> 5 & 3;
	int count; 

	if (insn & (1 << 4)) {
		if (insn & (1 << 7))
			error("shift by reg, bit 7 set");
		count = get_reg(insn >> 8 & 15) & 0xFF;
	} else {
		count = insn >> 7 & 31;
		if (count == 0) {
			switch (type) {
				case 0: /* LSL #0 */ return res;
				case 1: /* LSR #32 */ count = 32; break;
				case 2: /* ASR #32 */ count = 32; break;
				case 3: /* RRX */ {
					u32 ret = arm.cpsr_c << 31 | res >> 1;
					if (setcc) arm.cpsr_c = res & 1;
					return ret;
				}
			}
		}
	}
	return shift(type, res, count, setcc);
}

void cpu_exception(int type) {
	static const u8 flags[] = {
		MODE_SVC | 0xC0, /* Reset */
		MODE_UND | 0x80, /* Undefined instruction */
		MODE_SVC | 0x80, /* Software interrupt */
		MODE_ABT | 0x80, /* Prefetch abort */
		MODE_ABT | 0x80, /* Data abort */
		0,               /* Reserved */
		MODE_IRQ | 0x80, /* IRQ */
		MODE_FIQ | 0xC0, /* FIQ */
	};

	/* Switch mode, disable interrupts */
	u32 old_cpsr = get_cpsr();
	set_cpsr_full((old_cpsr & ~0x3F) | flags[type]);
	set_spsr_full(old_cpsr);

	/* Branch-and-link to exception handler */
	arm.reg[14] = arm.reg[15];
	arm.reg[15] = type << 2;
	if (arm.control & 0x2000) /* High vectors */
		arm.reg[15] += 0xFFFF0000;
}

void cpu_interpret_instruction(u32 insn) {
	int exec;
	switch (insn >> 29) {
		case 0:  /* EQ/NE */ exec = arm.cpsr_z; break;
		case 1:  /* CS/CC */ exec = arm.cpsr_c; break;
		case 2:  /* MI/PL */ exec = arm.cpsr_n; break;
		case 3:  /* VS/VC */ exec = arm.cpsr_v; break;
		case 4:  /* HI/LS */ exec = !arm.cpsr_z && arm.cpsr_c; break;
		case 5:  /* GE/LT */ exec = arm.cpsr_n == arm.cpsr_v; break;
		case 6:  /* GT/LE */ exec = !arm.cpsr_z && arm.cpsr_n == arm.cpsr_v; break;
		default: /* AL/-- */ exec = 1;
			if (insn & (1 << 28)) {
				if ((insn & 0xFD70F000) == 0xF550F000) {
					/* PLD: Preload to cache (implemented as no-op) */
				} else if ((insn & 0xFE000000) == 0xFA000000) {
					/* BLX: Branch, link, and exchange T bit */
					arm.reg[14] = arm.reg[15];
					arm.reg[15] += 4 + ((s32)insn << 8 >> 6) + (insn >> 23 & 2);
					arm.cpsr_low28 |= 0x20; /* Enter THUMB mode */
				} else {
					error("Invalid condition code");
				}
				return;
			}
	}
	if (!(exec ^ (insn >> 28 & 1)))
		return;

	if ((insn & 0xE000090) == 0x0000090) {
		int type = insn >> 5 & 3;
		if (type == 0) {
			if ((insn & 0xFC000F0) == 0x0000090) {
				/* MUL, MLA: 32x32 to 32 multiplications */
				u32 res = get_reg(insn & 15)
				        * get_reg(insn >> 8 & 15);
				if (insn & 0x0200000)
					res += get_reg(insn >> 12 & 15);

				set_reg(insn >> 16 & 15, res);
				if (insn & 0x0100000) set_nz_flags(res);
			} else if ((insn & 0xF8000F0) == 0x0800090) {
				/* UMULL, UMLAL, SMULL, SMLAL: 32x32 to 64 multiplications */
				u32 left   = get_reg(insn & 15);
				u32 right  = get_reg(insn >> 8 & 15);
				u32 reg_lo = insn >> 12 & 15;
				u32 reg_hi = insn >> 16 & 15;

				if (reg_lo == reg_hi)
					error("RdLo and RdHi cannot be same for 64-bit multiply");

				u64 res;
				if (insn & 0x0400000) res = (s64)(s32)left * (s32)right;
				else                  res = (u64)left * right;
				if (insn & 0x0200000) {
					/* Accumulate */
					res += (u64)get_reg(reg_hi) << 32 | get_reg(reg_lo);
				}

				set_reg(reg_lo, res);
				set_reg(reg_hi, res >> 32);
				if (insn & 0x0100000) set_nz_flags_64(res);
			} else if ((insn & 0xFB00FF0) == 0x1000090) {
				/* SWP, SWPB */
				u32 addr = get_reg(insn >> 16 & 15);
				u32 ld, st = get_reg(insn & 15);
				if (insn & 0x0400000) {
					ld = read_byte(addr); write_byte(addr, st);
				} else {
					ld = read_word_ldr(addr); write_word(addr, st);
				}
				set_reg(insn >> 12 & 15, ld);
			} else {
				goto bad_insn;
			}
		} else {
			/* Load/store halfword, signed byte/halfword, or doubleword */
			int base_reg = insn >> 16 & 15;
			int data_reg = insn >> 12 & 15;
			int offset = (insn & (1 << 22))
				? (insn & 0x0F) | (insn >> 4 & 0xF0)
				: get_reg(insn & 15);
			bool writeback;
			u32 addr = get_reg_pc(base_reg);

			if (!(insn & (1 << 23))) // Subtracted offset
				offset = -offset;

			if (insn & (1 << 24)) { // Offset or pre-indexed addressing
				addr += offset;
				offset = 0;
				writeback = insn & (1 << 21);
			} else {
				if (insn & (1 << 21))
					error("T-type memory access not implemented");
				writeback = true;
			}

			if (insn & (1 << 20)) {
				u32 data;
				if (base_reg == data_reg && writeback)
					error("Load instruction modifies base register twice");
				if      (type == 1) data =      read_half(addr); /* LDRH  */
				else if (type == 2) data = (s8) read_byte(addr); /* LDRSB */
				else                data = (s16)read_half(addr); /* LDRSH */
				set_reg(data_reg, data);
			} else if (type == 1) { /* STRH */
				write_half(addr, get_reg(data_reg));
			} else {
				if (data_reg & 1) error("LDRD/STRD with odd-numbered data register");
				if (type == 2) { /* LDRD */
					if ((base_reg & ~1) == data_reg && writeback)
						error("Load instruction modifies base register twice");
					u32 low  = read_word(addr);
					u32 high = read_word(addr + 4);
					set_reg(data_reg,     low);
					set_reg(data_reg + 1, high);
				} else { /* STRD */
					write_word(addr,     get_reg(data_reg));
					write_word(addr + 4, get_reg(data_reg + 1));
				}
			}
			if (writeback)
				set_reg(base_reg, addr + offset);
		}
	} else if ((insn & 0xD900000) == 0x1000000) {
		/* Miscellaneous */
		if ((insn & 0xFFFFFD0) == 0x12FFF10) {
			/* B(L)X: Branch(, link,) and exchange T bit */
			u32 target = get_reg_pc(insn & 15);
			if (insn & 0x20)
				arm.reg[14] = arm.reg[15];
			set_reg_pc_bx(15, target);
		} else if ((insn & 0xFBF0FFF) == 0x10F0000) {
			/* MRS: Move reg <- status */
			set_reg(insn >> 12 & 15, insn & 0x0400000 ? get_spsr() : get_cpsr());
		} else if ((insn & 0xFB0FFF0) == 0x120F000 ||
		           (insn & 0xFB0F000) == 0x320F000) {
			/* MSR: Move status <- reg/imm */
			u32 val, mask = 0;
			if (insn & 0x2000000)
				val = get_shifted_immed(insn, 0);
			else
				val = get_reg(insn & 15);
			if (insn & 0x0080000) mask |= 0xFF000000;
			if (insn & 0x0040000) mask |= 0x00FF0000;
			if (insn & 0x0020000) mask |= 0x0000FF00;
			if (insn & 0x0010000) mask |= 0x000000FF;
			if (insn & 0x0400000)
				set_spsr(val, mask);
			else
				set_cpsr(val, mask);
		} else if ((insn & 0xF900090) == 0x1000080) {
			s32 left = get_reg(insn & 15);
			s16 right = get_reg(insn >> 8 & 15) >> (insn & 0x40 ? 16 : 0);
			s32 product;
			int type = insn >> 21 & 3;

			if (type == 1) {
				/* SMULW<y>, SMLAW<y>: Signed 32x16 to 48 multiply, uses only top 32 bits */
				product = (s64)left * right >> 16;
				if (!(insn & 0x20))
					goto accumulate;
			} else {
				/* SMUL<x><y>, SMLA<x><y>, SMLAL<x><y>: Signed 16x16 to 32 multiply */
				product = (s16)(left >> (insn & 0x20 ? 16 : 0)) * right;
			}
			if (type == 2) {
				/* SMLAL<x><y>: 64-bit accumulate */
				u32 reg_lo = insn >> 12 & 15;
				u32 reg_hi = insn >> 16 & 15;
				s64 sum;
				if (reg_lo == reg_hi)
					error("RdLo and RdHi cannot be same for 64-bit accumulate");
				sum = product + ((u64)get_reg(reg_hi) << 32 | get_reg(reg_lo));
				set_reg(reg_lo, sum);
				set_reg(reg_hi, sum >> 32);
			} else if (type == 0) accumulate: {
				/* SMLA<x><y>, SMLAW<y>: 32-bit accumulate */
				s32 acc = get_reg(insn >> 12 & 15);
				s32 sum = product + acc;
				/* Set Q flag on overflow */
				arm.cpsr_low28 |= ADD_OVERFLOW(product, acc, sum) << 27;
				set_reg(insn >> 16 & 15, sum);
			} else {
				/* SMUL<x><y>, SMULW<y>: No accumulate */
				set_reg(insn >> 16 & 15, product);
			}
		} else if ((insn & 0xF900FF0) == 0x1000050) {
			/* QADD, QSUB, QDADD, QDSUB: Saturated arithmetic */
			s32 left  = get_reg(insn       & 15);
			s32 right = get_reg(insn >> 16 & 15);
			s32 res, overflow;
			if (insn & 0x400000) {
				/* Doubled right operand */
				res = right << 1;
				if (ADD_OVERFLOW(right, right, res)) {
					/* Overflow, set Q flag and saturate */
					arm.cpsr_low28 |= 1 << 27;
					res = (res < 0) ? 0x7FFFFFFF : 0x80000000;
				}
				right = res;
			}
			if (!(insn & 0x200000)) {
				res = left + right;
				overflow = ADD_OVERFLOW(left, right, res);
			} else {
				res = left - right;
				overflow = SUB_OVERFLOW(left, right, res);
			}
			if (overflow) {
				/* Set Q flag and saturate */
				arm.cpsr_low28 |= 1 << 27;
				res = (res < 0) ? 0x7FFFFFFF : 0x80000000;
			}
			set_reg(insn >> 12 & 15, res);
		} else if ((insn & 0xFFF0FF0) == 0x16F0F10) {
			/* CLZ: Count leading zeros */
			s32 value = get_reg(insn & 15);
			u32 zeros;
			for (zeros = 0; zeros < 32 && value >= 0; zeros++)
				value <<= 1;
			set_reg(insn >> 12 & 15, zeros);
		} else if ((insn & 0xFFF000F0) == 0xE1200070) {
			printf("Software breakpoint at %08x (%04x)\n",
				arm.reg[15], (insn >> 4 & 0xFFF0) | (insn & 0xF));
			debugger(DBG_EXEC_BREAKPOINT, 0);
		} else {
			goto bad_insn;
		}
	} else if ((insn & 0xC000000) == 0) {
		/* Data processing instructions */
		u32 left, right, res;
		int setcc = insn >> 20 & 1;
		int opcode = insn >> 21 & 15;
		int dest_reg = insn >> 12 & 15;

		u8 c = arm.cpsr_c;

		left = get_reg_pc(insn >> 16 & 15);
		if (insn & (1 << 25))
			right = get_shifted_immed(insn, setcc);
		else
			right = get_shifted_reg(insn, setcc);

		switch (opcode) {
			default: /* not used, obviously - here to shut up gcc warning */
			case 0:  /* AND */ res = left & right; break;
			case 1:  /* EOR */ res = left ^ right; break;
			case 2:  /* SUB */ res = add( left, ~right, 1, setcc); break;
			case 3:  /* RSB */ res = add(~left,  right, 1, setcc); break;
			case 4:  /* ADD */ res = add( left,  right, 0, setcc); break;
			case 5:  /* ADC */ res = add( left,  right, c, setcc); break;
			case 6:  /* SBC */ res = add( left, ~right, c, setcc); break;
			case 7:  /* RSC */ res = add(~left,  right, c, setcc); break;
			case 8:  /* TST */ res = left & right; break;
			case 9:  /* TEQ */ res = left ^ right; break;
			case 10: /* CMP */ res = add( left, ~right, 1, setcc); break;
			case 11: /* CMN */ res = add( left,  right, 0, setcc); break;
			case 12: /* ORR */ res = left | right; break;
			case 13: /* MOV */ res = right; break;
			case 14: /* BIC */ res = left & ~right; break;
			case 15: /* MVN */ res = ~right; break;
		}

		if ((opcode & 12) == 8) {
			if (dest_reg != 0)
				error("Compare instruction has nonzero destination reg");
		} else {
			set_reg_pc(dest_reg, res);
		}

		if (setcc) {
			set_nz_flags(res);
			if (dest_reg == 15) set_cpsr_full(get_spsr());
		}
	} else if ((insn & 0xC000000) == 0x4000000) {
		/* LDR(B), STR(B): Byte/word memory access */
		int base_reg = insn >> 16 & 15;
		int data_reg = insn >> 12 & 15;

		u32 offset;
		if (insn & (1 << 25)) {
			if (insn & (1 << 4))
				error("Cannot shift memory offset by register");
			offset = get_shifted_reg(insn, 0);
		} else {
			offset = insn & 0xFFF;
		}

		bool writeback;
		u32 addr = get_reg_pc(base_reg);

		if (!(insn & (1 << 23))) // Subtracted offset
			offset = -offset;

		if (insn & (1 << 24)) { // Offset or pre-indexed addressing
			addr += offset;
			offset = 0;
			writeback = insn & (1 << 21);
		} else {
			if (insn & (1 << 21))
				error("T-type memory access not implemented");
			writeback = true;
		}

		if (insn & (1 << 20)) {
			if (data_reg == base_reg && writeback)
				error("Load instruction modifies base register twice");
			if (insn & (1 << 22)) set_reg_pc_bx(data_reg, read_byte(addr));
			else                  set_reg_pc_bx(data_reg, read_word_ldr(addr));
		} else {
			if (insn & (1 << 22)) write_byte(addr, get_reg_pc_store(data_reg));
			else                  write_word(addr, get_reg_pc_store(data_reg));
		}
		if (writeback)
			set_reg(base_reg, addr + offset);
	} else if ((insn & 0xE000000) == 0x8000000) {
		/* LDM, STM: Load/store multiple */
		int base_reg = insn >> 16 & 15;
		u32 addr = get_reg(base_reg);
		u32 new_base = addr;
		int i, count = 0;
		for (i = 0; i < 16; i++)
			count += (insn >> i & 1);

		if (insn & (1 << 23)) { /* Increasing */
			if (insn & (1 << 21)) // Writeback
				new_base += count * 4;
			if (insn & (1 << 24)) // Preincrement
				addr += 4;
		} else { /* Decreasing */
			addr -= count * 4;
			if (insn & (1 << 21)) // Writeback
				new_base = addr;
			if (!(insn & (1 << 24))) // Postdecrement
				addr += 4;
		}

		for (i = 0; i < 15; i++) {
			if (insn >> i & 1) {
				u32 *reg_ptr = &arm.reg[i];
				if (insn & (1 << 22) && ~insn & ((1 << 20) | (1 << 15))) {
					/* User-mode registers */
					int mode = arm.cpsr_low28 & 0x1F;
					if (i >= 13) {
						if (mode != MODE_USR && mode != MODE_SYS) reg_ptr = &arm.r13_usr[i - 13];
					} else if (i >= 8) {
						if (mode == MODE_FIQ) reg_ptr = &arm.r8_usr[i - 8];
					}
				}
				if (insn & (1 << 20)) { // Load
					if (reg_ptr == &arm.reg[base_reg]) {
						if (insn & (1 << 21)) // Writeback
							error("Load instruction modifies base register twice");
						reg_ptr = &new_base;
					}
					*reg_ptr = read_word(addr);
				} else { // Store
					write_word(addr, *reg_ptr);
				}
				addr += 4;
			}
		}
		if (insn & (1 << 15)) {
			if (insn & (1 << 20)) // Load
				set_reg_pc_bx(15, read_word(addr));
			else // Store
				write_word(addr, get_reg_pc_store(15));
		}
		arm.reg[base_reg] = new_base;
		if ((~insn & (1 << 22 | 1 << 20 | 1 << 15)) == 0)
			set_cpsr_full(get_spsr());
	} else if ((insn & 0xE000000) == 0xA000000) {
		/* B, BL: Branch, branch-and-link */
		if (insn & (1 << 24))
			arm.reg[14] = arm.reg[15];
		arm.reg[15] += 4 + ((s32)insn << 8 >> 6);
	} else if ((insn & 0xF100F10) == 0xE000F10) {
		/* MCR p15 */
		u32 value = get_reg(insn >> 12 & 15);
		switch (insn & 0xEF00EF) {
			case 0x010000: { /* MCR p15, 0, <Rd>, c1, c0, 0: Control Register */
				u32 change = value ^ arm.control;
				if ((value & 0xFFFF8CF8) != 0x00050078)
					error("Bad or unimplemented control register value: %x\n", value);
				arm.control = value;
				if (change & 1) // MMU is being turned on or off
					addr_cache_flush();
				break;
			}
			case 0x020000: /* MCR p15, 0, <Rd>, c2, c0, 0: Translation Table Base Register */
				arm.translation_table_base = value & ~0x3FFF;
				addr_cache_flush();
				break;
			case 0x030000: /* MCR p15, 0, <Rd>, c3, c0, 0: Domain Access Control Register */
				arm.domain_access_control = value;
				addr_cache_flush();
				break;
			case 0x050000: /* MCR p15, 0, <Rd>, c5, c0, 0: Data Fault Status Register */
				arm.data_fault_status = value;
				break;
			case 0x050020: /* MCR p15, 0, <Rd>, c5, c0, 1: Instruction Fault Status Register */
				arm.instruction_fault_status = value;
				break;
			case 0x060000: /* MCR p15, 0, <Rd>, c6, c0, 0: Fault Address Register */
				arm.fault_address = value;
				break;
			case 0x070080: /* MCR p15, 0, <Rd>, c7, c0, 4: Wait for interrupt */
				cycle_count_delta = 0;
				if (arm.interrupts == 0) {
					arm.reg[15] -= 4;
					cpu_events |= EVENT_WAITING;
					//is_halting = 10;
				}
				break;
			case 0x080025: /* MCR p15, 0, <Rd>, c8, c5, 1: Invalidate instruction TLB entry */
			case 0x080026: /* MCR p15, 0, <Rd>, c8, c6, 1: Invalidate data TLB entry */
			case 0x080007: /* MCR p15, 0, <Rd>, c8, c7, 0: Invalidate TLB */
				addr_cache_flush();
				break;
			case 0x070005: /* MCR p15, 0, <Rd>, c7, c5, 0: Invalidate ICache */
			case 0x070025: /* MCR p15, 0, <Rd>, c7, c5, 1: Invalidate ICache line */
			case 0x070007: /* MCR p15, 0, <Rd>, c7, c7, 0: Invalidate ICache and DCache */
			case 0x07002A: /* MCR p15, 0, <Rd>, c7, c10, 1: Clean DCache line */
			case 0x07008A: /* MCR p15, 0, <Rd>, c7, c10, 4: Drain write buffer */
			case 0x0F0000: /* MCR p15, 0, <Rd>, c15, c0, 0: Debug Override Register */
				// Ignore
				break;
			default:
				warn("Unknown coprocessor instruction MCR %08X", insn);
				break;
		}
	} else if ((insn & 0xF100F10) == 0xE100F10) {
		/* MRC p15 */
		u32 value;
		switch (insn & 0xEF00EF) {
			case 0x000000: /* MRC p15, 0, <Rd>, c0, c0, 0: ID Code Register */
				value = 0x41069264; /* ARM926EJ-S revision 4 */
				break;
			case 0x000010: /* MRC p15, 0, <Rd>, c0, c0, 1: Cache Type Register */
				value = 0x1D112152; /* ICache: 16KB 4-way 8 word, DCache: 8KB 4-way 8 word */
				break;
			case 0x000020: /* MRC p15, 0, <Rd>, c0, c0, 2: TCM Status Register */
				value = 0;
				break;
			case 0x010000: /* MRC p15, 0, <Rd>, c1, c0, 0: Control Register */
				value = arm.control;
				break;
			case 0x020000: /* MRC p15, 0, <Rd>, c2, c0, 0: Translation Table Base Register */
				value = arm.translation_table_base;
				break;
			case 0x030000: /* MRC p15, 0, <Rd>, c3, c0, 0: Domain Access Control Register */
				value = arm.domain_access_control;
				break;
			case 0x050000: /* MRC p15, 0, <Rd>, c5, c0, 0: Data Fault Status Register */
				value = arm.data_fault_status;
				break;
			case 0x050020: /* MRC p15, 0, <Rd>, c5, c0, 1: Instruction Fault Status Register */
				value = arm.instruction_fault_status;
				break;
			case 0x060000: /* MRC p15, 0, <Rd>, c6, c0, 0: Fault Address Register */
				value = arm.fault_address;
				break;
			case 0x07006A: /* MRC p15, 0, <Rd>, c7, c10, 3: Test and clean DCache */
				value = 1 << 30;
				break;
			case 0x07006E: /* MRC p15, 0, <Rd>, c7, c14, 3: Test, clean, and invalidate DCache */
				value = 1 << 30;
				break;
			case 0x0F0000: /* MRC p15, 0, <Rd>, c15, c0, 0: Debug Override Register */
				// Unimplemented
				value = 0;
				break;
			default:
				warn("Unknown coprocessor instruction MRC %08X", insn);
				value = 0;
				break;
		}
		if ((insn >> 12 & 15) == 15) {
			arm.cpsr_n = value >> 31 & 1;
			arm.cpsr_z = value >> 30 & 1;
			arm.cpsr_c = value >> 29 & 1;
			arm.cpsr_v = value >> 28 & 1;
		} else {
			arm.reg[insn >> 12 & 15] = value;
		}
	} else if ((insn & 0xF000000) == 0xF000000) {
		/* SWI - Software interrupt */
		cpu_exception(EX_SWI);
	} else {
bad_insn:
		error("Unrecognized instruction %08x\n", insn);
	}
}

static inline void *get_pc_ptr(u32 align) {
again:;
	u32 pc = arm.reg[15];
	void *ptr = &addr_cache[(pc >> 10) << 1][pc];
	if ((u32)ptr & (AC_NOT_PTR | (align - 1))) {
		if (pc & (align - 1)) {
			// Handle misaligned PC by truncating low bits; gpsp-nspire 
			arm.reg[15] = pc & -align;
			goto again;
		}
		ptr = addr_cache_miss(pc, false, prefetch_abort);
		if (!ptr)
			error("Bad PC: %08x\n", pc);
	}
	return ptr;
}

void cpu_arm_loop() {
	while (cycle_count_delta < 0 && !(arm.cpsr_low28 & 0x20)) {
		u32 *insnp = get_pc_ptr(4);
		u32 *flags = &RAM_FLAGS(insnp);

		if (cpu_events != 0) {
			if (cpu_events & ~EVENT_DEBUG_STEP)
				break;
			goto enter_debugger;
		}

		if (*flags & RF_CODE_TRANSLATED) {
			translation_enter();
			continue;
		}

		if (*flags & (RF_EXEC_BREAKPOINT | RF_EXEC_DEBUG_NEXT | RF_ARMLOADER_CB | RF_EXEC_HACK)) {
			if (*flags & RF_ARMLOADER_CB) {
				*flags &= ~RF_ARMLOADER_CB;
				armloader_cb();
			}
			if (*flags & (RF_EXEC_BREAKPOINT | RF_EXEC_DEBUG_NEXT)) {
				if (*flags & RF_EXEC_BREAKPOINT)
					printf("Hit breakpoint at %08X. Entering debugger.\n",  arm.reg[15]);
enter_debugger:
				debugger(DBG_EXEC_BREAKPOINT, 0);
			}
			if (*flags & RF_EXEC_HACK)
				if (exec_hack())
					continue;
		} else {
			if (do_translate && !(*flags & (RF_CODE_NO_TRANSLATE))) {
				translate(arm.reg[15], insnp);
				continue;
			}
		}
		arm.reg[15] += 4;
		cycle_count_delta++;
		cpu_interpret_instruction(*insnp);
	}
}

void cpu_thumb_loop() {
	while (cycle_count_delta < 0) {
		u16 *insnp = get_pc_ptr(2);
		u16 insn = *insnp;

		if (cpu_events != 0) {
			if (cpu_events & ~EVENT_DEBUG_STEP)
				break;
			goto enter_debugger;
		}

		u32 flags = RAM_FLAGS((u32)insnp & ~3);
		if (flags & (RF_EXEC_BREAKPOINT | RF_EXEC_DEBUG_NEXT)) {
			if (flags & RF_EXEC_BREAKPOINT)
				printf("Hit breakpoint at %08X. Entering debugger.\n", arm.reg[15]);
enter_debugger:
			debugger(DBG_EXEC_BREAKPOINT, 0);
		}

		arm.reg[15] += 2;
		cycle_count_delta++;

#define CASE_x2(base) case base: case base+1
#define CASE_x4(base) CASE_x2(base): CASE_x2(base+2)
#define CASE_x8(base) CASE_x4(base): CASE_x4(base+4)
#define REG0 arm.reg[insn & 7]
#define REG3 arm.reg[insn >> 3 & 7]
#define REG6 arm.reg[insn >> 6 & 7]
#define REG8 arm.reg[insn >> 8 & 7]
		switch (insn >> 8) {
			CASE_x8(0x00): /* LSL Rd, Rm, #imm */
			CASE_x8(0x08): /* LSR Rd, Rm, #imm */
			CASE_x8(0x10): /* ASR Rd, Rm, #imm */
				set_nz_flags(REG0 = shift(insn >> 11, REG3, insn >> 6 & 31, true));
				break;
			CASE_x2(0x18): /* ADD Rd, Rn, Rm */ set_nz_flags(REG0 = add(REG3, REG6, 0, true)); break;
			CASE_x2(0x1A): /* SUB Rd, Rn, Rm */ set_nz_flags(REG0 = add(REG3, ~REG6, 1, true)); break;
			CASE_x2(0x1C): /* ADD Rd, Rn, #imm */ set_nz_flags(REG0 = add(REG3, insn >> 6 & 7, 0, true)); break;
			CASE_x2(0x1E): /* SUB Rd, Rn, #imm */ set_nz_flags(REG0 = add(REG3, ~(insn >> 6 & 7), 1, true)); break;
			CASE_x8(0x20): /* MOV Rd, #imm */ set_nz_flags(REG8 = insn & 0xFF); break;
			CASE_x8(0x28): /* CMP Rn, #imm */ set_nz_flags(add(REG8, ~(insn & 0xFF), 1, true)); break;
			CASE_x8(0x30): /* ADD Rd, #imm */ set_nz_flags(REG8 = add(REG8, insn & 0xFF, 0, true)); break;
			CASE_x8(0x38): /* SUB Rd, #imm */ set_nz_flags(REG8 = add(REG8, ~(insn & 0xFF), 1, true)); break;
			CASE_x4(0x40): {
				u32 *dst = &REG0;
				u32 res;
				u32 src = REG3;
				switch (insn >> 6 & 15) {
					default:
					case 0x0: /* AND */ res = *dst &= src; break;
					case 0x1: /* EOR */ res = *dst ^= src; break;
					case 0x2: /* LSL */ res = *dst = shift(0, *dst, src & 0xFF, true); break;
					case 0x3: /* LSR */ res = *dst = shift(1, *dst, src & 0xFF, true); break;
					case 0x4: /* ASR */ res = *dst = shift(2, *dst, src & 0xFF, true); break;
					case 0x5: /* ADC */ res = *dst = add(*dst, src, arm.cpsr_c, true); break;
					case 0x6: /* SBC */ res = *dst = add(*dst, ~src, arm.cpsr_c, true); break;
					case 0x7: /* ROR */ res = *dst = shift(3, *dst, src & 0xFF, true); break;
					case 0x8: /* TST */ res = *dst & src; break;
					case 0x9: /* NEG */ res = *dst = add(0, ~src, 1, true); break;
					case 0xA: /* CMP */ res = add(*dst, ~src, 1, true); break;
					case 0xB: /* CMN */ res = add(*dst, src, 0, true); break;
					case 0xC: /* ORR */ res = *dst |= src; break;
					case 0xD: /* MUL */ res = *dst *= src; break;
					case 0xE: /* BIC */ res = *dst &= ~src; break;
					case 0xF: /* MVN */ res = *dst = ~src; break;
				}
				set_nz_flags(res);
				break;
			}
			case 0x44: { /* ADD Rd, Rm (high registers allowed) */
				u32 left = (insn >> 4 & 8) | (insn & 7), right = insn >> 3 & 15;
				set_reg_pc(left, get_reg_pc_thumb(left) + get_reg_pc_thumb(right));
				break;
			}
			case 0x45: { /* CMP Rn, Rm (high registers allowed) */
				u32 left = (insn >> 4 & 8) | (insn & 7), right = insn >> 3 & 15;
				set_nz_flags(add(get_reg(left), ~get_reg_pc_thumb(right), 1, true));
				break;
			}
			case 0x46: { /* MOV Rd, Rm (high registers allowed) */
				u32 left = (insn >> 4 & 8) | (insn & 7), right = insn >> 3 & 15;
				set_reg_pc(left, get_reg_pc_thumb(right));
				break;
			}
			case 0x47: { /* BX/BLX Rm (high register allowed) */
				u32 target = get_reg_pc_thumb(insn >> 3 & 15);
				if (insn & 0x80)
					arm.reg[14] = arm.reg[15] + 1;
				arm.reg[15] = target & ~1;
				if (!(target & 1)) {
					arm.cpsr_low28 &= ~0x20; /* Exit THUMB mode */
					return;
				}
				break;
			}
			CASE_x8(0x48): /* LDR reg, [PC, #imm] */ REG8 = read_word_ldr(((arm.reg[15] + 2) & -4) + ((insn & 0xFF) << 2)); break;
			CASE_x2(0x50): /* STR   Rd, [Rn, Rm] */ write_word(REG3 + REG6, REG0); break;
			CASE_x2(0x52): /* STRH  Rd, [Rn, Rm] */ write_half(REG3 + REG6, REG0); break;
			CASE_x2(0x54): /* STRB  Rd, [Rn, Rm] */ write_byte(REG3 + REG6, REG0); break;
			CASE_x2(0x56): /* LDRSB Rd, [Rn, Rm] */ REG0 = (s8)read_byte(REG3 + REG6); break;
			CASE_x2(0x58): /* LDR   Rd, [Rn, Rm] */ REG0 = read_word_ldr(REG3 + REG6); break;
			CASE_x2(0x5A): /* LDRH  Rd, [Rn, Rm] */ REG0 = read_half(REG3 + REG6); break;
			CASE_x2(0x5C): /* LDRB  Rd, [Rn, Rm] */ REG0 = read_byte(REG3 + REG6); break;
			CASE_x2(0x5E): /* LDRSH Rd, [Rn, Rm] */ REG0 = (s16)read_half(REG3 + REG6); break;
			CASE_x8(0x60): /* STR  Rd, [Rn, #imm] */ write_word(REG3 + (insn >> 4 & 124), REG0); break;
			CASE_x8(0x68): /* LDR  Rd, [Rn, #imm] */ REG0 = read_word_ldr(REG3 + (insn >> 4 & 124)); break;
			CASE_x8(0x70): /* STRB Rd, [Rn, #imm] */ write_byte(REG3 + (insn >> 6 & 31), REG0); break;
			CASE_x8(0x78): /* LDRB Rd, [Rn, #imm] */ REG0 = read_byte(REG3 + (insn >> 6 & 31)); break;
			CASE_x8(0x80): /* STRH Rd, [Rn, #imm] */ write_half(REG3 + (insn >> 5 & 62), REG0); break;
			CASE_x8(0x88): /* LDRH Rd, [Rn, #imm] */ REG0 = read_half(REG3 + (insn >> 5 & 62)); break;
			CASE_x8(0x90): /* STR Rd, [SP, #imm] */ write_word(arm.reg[13] + ((insn & 0xFF) << 2), REG8); break;
			CASE_x8(0x98): /* LDR Rd, [SP, #imm] */ REG8 = read_word_ldr(arm.reg[13] + ((insn & 0xFF) << 2)); break;
			CASE_x8(0xA0): /* ADD Rd, PC, #imm */ REG8 = ((arm.reg[15] + 2) & -4) + ((insn & 0xFF) << 2); break;
			CASE_x8(0xA8): /* ADD Rd, SP, #imm */ REG8 = arm.reg[13] + ((insn & 0xFF) << 2); break;
			case 0xB0: /* ADD/SUB SP, #imm */
				arm.reg[13] += ((insn & 0x80) ? -(insn & 0x7F) : (insn & 0x7F)) << 2;
				break;

			CASE_x2(0xB4): { /* PUSH {reglist[,LR]} */
				int i;
				u32 addr = arm.reg[13];
				for (i = 8; i >= 0; i--)
					addr -= (insn >> i & 1) * 4;
				u32 sp = addr;
				for (i = 0; i < 8; i++)
					if (insn >> i & 1)
						write_word(addr, arm.reg[i]), addr += 4;
				if (insn & 0x100)
					write_word(addr, arm.reg[14]);
				arm.reg[13] = sp;
				break;
			}

			CASE_x2(0xBC): { /* POP {reglist[,PC]} */
				int i;
				u32 addr = arm.reg[13];
				for (i = 0; i < 8; i++)
					if (insn >> i & 1)
						arm.reg[i] = read_word(addr), addr += 4;
				if (insn & 0x100) {
					u32 target = read_word(addr); addr += 4;
					arm.reg[15] = target & ~1;
					if (!(target & 1)) {
						arm.cpsr_low28 &= ~0x20;
						arm.reg[13] = addr;
						return;
					}
				}
				arm.reg[13] = addr;
				break;
			}
			case 0xBE:
				printf("Software breakpoint at %08x (%02x)\n", arm.reg[15], insn & 0xFF);
				debugger(DBG_EXEC_BREAKPOINT, 0);
				break;

			CASE_x8(0xC0): { /* STMIA Rn!, {reglist} */
				int i;
				u32 addr = REG8;
				for (i = 0; i < 8; i++)
					if (insn >> i & 1)
						write_word(addr, arm.reg[i]), addr += 4;
				REG8 = addr;
				break;
			}
			CASE_x8(0xC8): { /* LDMIA Rn!, {reglist} */
				int i;
				u32 addr = REG8;
				u32 tmp = 0; // value not used, just suppressing uninitialized variable warning
				for (i = 0; i < 8; i++) {
					if (insn >> i & 1) {
						if (i == (insn >> 8 & 7))
							tmp = read_word(addr);
						else
							arm.reg[i] = read_word(addr);
						addr += 4;
					}
				}
				// must set address register last so it is unchanged on exception
				REG8 = addr;
				if (insn >> (insn >> 8 & 7) & 1)
					REG8 = tmp;
				break;
			}
#define BRANCH_IF(cond) if (cond) arm.reg[15] += 2 + ((s8)insn << 1); break;
			case 0xD0: /* BEQ */ BRANCH_IF(arm.cpsr_z)
			case 0xD1: /* BNE */ BRANCH_IF(!arm.cpsr_z)
			case 0xD2: /* BCS */ BRANCH_IF(arm.cpsr_c)
			case 0xD3: /* BCC */ BRANCH_IF(!arm.cpsr_c)
			case 0xD4: /* BMI */ BRANCH_IF(arm.cpsr_n)
			case 0xD5: /* BPL */ BRANCH_IF(!arm.cpsr_n)
			case 0xD6: /* BVS */ BRANCH_IF(arm.cpsr_v)
			case 0xD7: /* BVC */ BRANCH_IF(!arm.cpsr_v)
			case 0xD8: /* BHI */ BRANCH_IF(arm.cpsr_c > arm.cpsr_z)
			case 0xD9: /* BLS */ BRANCH_IF(arm.cpsr_c <= arm.cpsr_z)
			case 0xDA: /* BGE */ BRANCH_IF(arm.cpsr_n == arm.cpsr_v)
			case 0xDB: /* BLT */ BRANCH_IF(arm.cpsr_n != arm.cpsr_v)
			case 0xDC: /* BGT */ BRANCH_IF(!arm.cpsr_z && arm.cpsr_n == arm.cpsr_v)
			case 0xDD: /* BLE */ BRANCH_IF(arm.cpsr_z || arm.cpsr_n != arm.cpsr_v)

			case 0xDF: /* SWI */
				cpu_exception(EX_SWI);
				return; /* Exits THUMB mode */

			CASE_x8(0xE0): /* B */ arm.reg[15] += 2 + ((s32)insn << 21 >> 20); break;
			CASE_x8(0xE8): { /* Second half of BLX */
				u32 target = (arm.reg[14] + ((insn & 0x7FF) << 1)) & ~3;
				arm.reg[14] = arm.reg[15] + 1;
				arm.reg[15] = target;
				arm.cpsr_low28 &= ~0x20; /* Exit THUMB mode */
				return;
			}
			CASE_x8(0xF0): /* First half of BL/BLX */
				arm.reg[14] = arm.reg[15] + 2 + ((s32)insn << 21 >> 9);
				break;
			CASE_x8(0xF8): { /* Second half of BL */
				u32 target = arm.reg[14] + ((insn & 0x7FF) << 1);
				arm.reg[14] = arm.reg[15] + 1;
				arm.reg[15] = target;
				break;
			}
			default:
				error("Unknown instruction: %04X\n", insn);
				break;
		}
	}
}

#if 0
void *cpu_save_state(size_t *size) {
	(void)size;
	return NULL;
}

void cpu_reload_state(void *state) {
	(void)state;
}
#endif
