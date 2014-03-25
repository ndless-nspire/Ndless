// arm_state structure offsets
#define ARM_PC 60
#define ARM_CPSR 64
#define ARM_FLAG_C 70
#define ARM_CONTROL 72

// translation structure offsets
#define TRANS_JUMP_TABLE 4
#define TRANS_END_PTR 12

#define RAM_FLAGS (65*1024*1024) // = MEM_MAXSIZE
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

#define WRITE_SPECIAL_FLAGS 64+32+2

// List of locations of addresses which need to be relocated to addr_cache
// (necessary since it's now allocated at runtime)
	.data
.globl	_ac_reloc_start
_ac_reloc_start:

.macro AC_RELOC; 0: .data; .long 0b - 4; .text; .endm

	.text
.globl	_translation_enter
_translation_enter:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%ebx
	pushl	%esi
	pushl	%edi
	movl	%esp, _in_translation_esp

	movl	$_arm, %ebx
	movl	ARM_PC(%ebx), %eax
	jmp	_translation_next

.globl	_translation_next_bx
_translation_next_bx:
	testb	$1, %al
	jne	switch_to_thumb

.globl	_translation_next
_translation_next:
	movl	%eax, ARM_PC(%ebx)

	cmpl	$0, _cycle_count_delta
	jns	return

	cmpl	$0, _cpu_events
	jnz	return

	// eax = VM_MEM_PTR(eax)
	movl	%eax, %ecx
	shrl	$10, %ecx
	addl	0(, %ecx, 8), %eax
	AC_RELOC
	testl	$0x80000003, %eax
	jnz	return
addr_ok:

	movl	RAM_FLAGS(%eax), %edx
	testb	$RF_CODE_TRANSLATED, %dl
	jz	return         // Not translated

	movl	%eax, _in_translation_pc_ptr

	shrl	$RFS_TRANSLATION_INDEX, %edx
	shll	$4, %edx
	addl	$_translation_table, %edx

	// Add one cycle for each instruction from this point to the end
	movl	TRANS_END_PTR(%edx), %ecx
	subl	%eax, %ecx
	shrl	$2, %ecx
	addl	%ecx, _cycle_count_delta

	movl	TRANS_JUMP_TABLE(%edx), %edx
	jmp	*(%edx, %eax)

return:
	andl	$0, _in_translation_esp
	popl	%edi
	popl	%esi
	popl	%ebx
	popl	%ebp
	ret

switch_to_thumb:
	decl	%eax
	movl	%eax, ARM_PC(%ebx)
	orb	$0x20, ARM_CPSR(%ebx)
	jmp	return

	// These shift procedures are called only from translated code,
	// so they may assume that %ebx == _arm
	.align	4
.globl _arm_shift_proc
_arm_shift_proc:
	.long	lsl
	.long	lsr
	.long	asr
	.long	0
	.long	lsl_carry
	.long	lsr_carry
	.long	asr_carry
	.long	ror_carry

	.text
lsl:
	cmpb	$32, %cl
	jae	ls_32
	shll	%cl, %eax
	ret

lsr:
	cmpb	$32, %cl
	jae	ls_32
	shrl	%cl, %eax
	ret
ls_32:
	xorl	%eax, %eax
	ret

asr:
	cmpb	$32, %cl
	jae	asr_32
	sarl	%cl, %eax
	ret
asr_32:
	sarl	$31, %eax
	ret

lsl_carry:
	cmpb	$32, %cl
	jae	lsl_carry_32
	testb	%cl, %cl
	je	lsl_carry_zero
	shll	%cl, %eax
	setc	ARM_FLAG_C(%ebx)
lsl_carry_zero:
	ret
lsl_carry_32:
	jne	ls_carry_33
	shrl	$1, %eax
	setc	ARM_FLAG_C(%ebx)
	xorl	%eax, %eax
	ret

lsr_carry:
	cmpb	$32, %cl
	jae	lsr_carry_32
	testb	%cl, %cl
	je	lsr_carry_zero
	shrl	%cl, %eax
	setc	ARM_FLAG_C(%ebx)
lsr_carry_zero:
	ret
lsr_carry_32:
	jne	ls_carry_33
	shll	$1, %eax
	setc	ARM_FLAG_C(%ebx)
	xorl	%eax, %eax
	ret
ls_carry_33:
	xorl	%eax, %eax
	movb	%al, ARM_FLAG_C(%ebx)
	ret

asr_carry:
	cmpb	$32, %cl
	jae	asr_carry_32
	testb	%cl, %cl
	je	asr_carry_zero
	sarl	%cl, %eax
	setc	ARM_FLAG_C(%ebx)
asr_carry_zero:
	ret
asr_carry_32:
	sarl	$31, %eax
	sets	ARM_FLAG_C(%ebx)
	ret

ror_carry:
	testb	$31, %cl
	jz	ror_carry_mult_32
	rorl	%cl, %eax
	setc	ARM_FLAG_C(%ebx)
ror_carry_zero:
	ret
ror_carry_mult_32:
	testb	%cl, %cl
	je	ror_carry_zero
	testl	%eax, %eax
	sets	ARM_FLAG_C(%ebx)
	ret

// u32 __attribute__((fastcall)) read_byte(u32 addr);
.globl	@read_byte@4
.align	16
@read_byte@4:
	movl	%ecx, %eax
	shrl	$10, %eax
	addl	0(, %eax, 8), %ecx
	AC_RELOC
	js	rb_slow
	movl	%ecx, %edx
	andl	$-4, %edx
	testb	$RF_READ_BREAKPOINT, RAM_FLAGS(%edx)
	jnz	rb_special
rb_fast:
	movzbl	(%ecx), %eax
	ret
rb_special:
	call	read_special
	jmp	rb_fast
rb_slow:
	movl	0(, %eax, 8), %eax
	AC_RELOC
	subl	%eax, %ecx
	shll	$10, %eax
	jc	rb_miss
	addl	%eax, %ecx
	jmp	@mmio_read_byte@4
rb_miss:
	call	read_miss
	jmp	@read_byte@4

// u32 __attribute__((fastcall)) read_half(u32 addr);
.globl	@read_half@4
.align	16
@read_half@4:
	movl	%ecx, %eax
	shrl	$10, %eax
	addl	0(, %eax, 8), %ecx
	AC_RELOC
	testl	$0x80000001, %ecx
	jnz	rh_slow
	movl	%ecx, %edx
	andl	$-4, %edx
	testb	$RF_READ_BREAKPOINT, RAM_FLAGS(%edx)
	jnz	rh_special
rh_fast:
	movzwl	(%ecx), %eax
	ret
rh_special:
	call	read_special
	jmp	rh_fast
rh_slow:
	movl	0(, %eax, 8), %eax
	AC_RELOC
	subl	%eax, %ecx
	testl	$1, %ecx
	jnz	rh_unaligned
	shll	$10, %eax
	jc	rh_miss
	addl	%eax, %ecx
	jmp	@mmio_read_half@4
rh_miss:
	call	read_miss
	jmp	@read_half@4
rh_unaligned:
	call	align_fault
	decl	%ecx
	jmp	@read_half@4

// u32 __attribute__((fastcall)) read_word(u32 addr);
.globl	@read_word@4
.align	16
@read_word@4:
	movl	%ecx, %eax
	shrl	$10, %eax
	addl	0(, %eax, 8), %ecx
	AC_RELOC
	testl	$0x80000003, %ecx
	jnz	rw_slow
	testb	$RF_READ_BREAKPOINT, RAM_FLAGS(%ecx)
	jnz	rw_special
rw_fast:
	movl	(%ecx), %eax
	ret
rw_special:
	call	read_special
	jmp	rw_fast
rw_slow:
	movl	0(, %eax, 8), %eax
	AC_RELOC
	subl	%eax, %ecx
	testl	$3, %ecx
	jnz	rw_unaligned
	shll	$10, %eax
	jc	rw_miss
	addl	%eax, %ecx
	jmp	@mmio_read_word@4
rw_miss:
	call	read_miss
	jmp	@read_word@4
rw_unaligned:
	call	align_fault
	andl	$-4, %ecx
	jmp	@read_word@4

// u32 __attribute__((fastcall)) read_word_ldr(u32 addr);
.globl	@read_word_ldr@4
.align	16
@read_word_ldr@4:
	movl	%ecx, %eax
	shrl	$10, %eax
	addl	0(, %eax, 8), %ecx
	AC_RELOC
	testl	$0x80000003, %ecx
	jnz	rwl_slow
	testb	$RF_READ_BREAKPOINT, RAM_FLAGS(%ecx)
	jnz	rw_special
	movl	(%ecx), %eax
	ret
rwl_slow:
	movl	0(, %eax, 8), %eax
	AC_RELOC
	subl	%eax, %ecx
	testl	$3, %ecx
	jnz	rwl_unaligned
	shll	$10, %eax
	jc	rw_miss
	addl	%eax, %ecx
	jmp	@mmio_read_word@4
rwl_unaligned:
	pushl	%ecx
	call	rw_unaligned
	popl	%ecx
	shll	$3, %ecx  // Unaligned ldr rotates the word so that
	rorl	%cl, %eax // addressed byte ends up in low position
	ret

read_special:
	pushl	%ecx
	pushl	%ecx
	call	_read_action
	popl	%ecx
	popl	%ecx
	ret
read_miss:
	pushl	%ecx
	pushl	$_data_abort
	pushl	$0
	pushl	%ecx
	call	_addr_cache_miss
	addl	$12, %esp
	popl	%ecx
	ret

// void __attribute__((fastcall)) write_byte(u32 addr, u8 value);
.globl	@write_byte@8
.align	16
@write_byte@8:
	movl	%ecx, %eax
	shrl	$10, %eax
	addl	4(, %eax, 8), %ecx
	AC_RELOC
	js	wb_slow
	movl	%ecx, %eax
	andl	$-4, %eax
	testb	$WRITE_SPECIAL_FLAGS, RAM_FLAGS(%eax)
	jnz	wb_special
wb_fast:
	movb	%dl, (%ecx)
	ret
wb_special:
	call	write_special
	jmp	wb_fast
wb_slow:
	movl	4(, %eax, 8), %eax
	AC_RELOC
	subl	%eax, %ecx
	shll	$10, %eax
	jc	wb_miss
	addl	%eax, %ecx
	jmp	@mmio_write_byte@8
wb_miss:
	call	write_miss
	jmp	@write_byte@8

// void __attribute__((fastcall)) write_half(u32 addr, u16 value);
.globl	@write_half@8
.align	16
@write_half@8:
	movl	%ecx, %eax
	shrl	$10, %eax
	addl	4(, %eax, 8), %ecx
	AC_RELOC
	testl	$0x80000001, %ecx
	jnz	wh_slow
	movl	%ecx, %eax
	andl	$-4, %eax
	testb	$WRITE_SPECIAL_FLAGS, RAM_FLAGS(%eax)
	jnz	wh_special
wh_fast:
	movw	%dx, (%ecx)
	ret
wh_special:
	call	write_special
	jmp	wh_fast
wh_slow:
	movl	4(, %eax, 8), %eax
	AC_RELOC
	subl	%eax, %ecx
	testl	$1, %ecx
	jnz	wh_unaligned
	shll	$10, %eax
	jc	wh_miss
	addl	%eax, %ecx
	jmp	@mmio_write_half@8
wh_miss:
	call	write_miss
	jmp	@write_half@8
wh_unaligned:
	call	align_fault
	decl	%ecx
	jmp	@write_half@8

// void __attribute__((fastcall)) write_word(u32 addr, u32 value);
.globl	@write_word@8
.align	16
@write_word@8:
	movl	%ecx, %eax
	shrl	$10, %eax
	addl	4(, %eax, 8), %ecx
	AC_RELOC
	testl	$0x80000003, %ecx
	jnz	ww_slow
	testb	$WRITE_SPECIAL_FLAGS, RAM_FLAGS(%ecx)
	jnz	ww_special
ww_fast:
	movl	%edx, (%ecx)
	ret
ww_special:
	call	write_special
	jmp	ww_fast
ww_slow:
	movl	4(, %eax, 8), %eax
	AC_RELOC
	subl	%eax, %ecx
	testl	$3, %ecx
	jnz	ww_unaligned
	shll	$10, %eax
	jc	ww_miss
	addl	%eax, %ecx
	jmp	@mmio_write_word@8
ww_miss:
	call	write_miss
	jmp	@write_word@8
ww_unaligned:
	call	align_fault
	andl	$-4, %ecx
	jmp	@write_word@8

write_special:
	pushl	%edx
	pushl	%ecx
	pushl	%ecx
	call	_write_action
	popl	%ecx
	popl	%ecx
	popl	%edx
	ret
write_miss:
	pushl	%edx
	pushl	%ecx
	pushl	$_data_abort
	pushl	$1
	pushl	%ecx
	call	_addr_cache_miss
	addl	$12, %esp
	popl	%ecx
	popl	%edx
	ret

align_fault:
	testb	$2, _arm+ARM_CONTROL
	jz	1f
	pushl	$1
	pushl	%ecx
	call	_data_abort
1:	ret

	.data
.globl	_ac_reloc_end
_ac_reloc_end:

// Windows msvcrt.dll setjmp/longjmp does some stuff with SEH unwinding
// that only works with the handlers generated by MSVC++ __try :(
// We only need the basic setjmp/longjmp functionality anyway

	.text
.globl __setjmp
__setjmp:
	popl	%eax            // return address
	movl	(%esp), %ecx    // jmp_buf
	movl	%ebx, 0(%ecx)
	movl	%esp, 4(%ecx)
	movl	%ebp, 8(%ecx)
	movl	%esi, 12(%ecx)
	movl	%edi, 16(%ecx)
	movl	%eax, 20(%ecx)
	pushl	%eax
	xorl	%eax, %eax
	ret
.globl _longjmp
_longjmp:
	popl	%ecx            // return address (useless :P)
	popl	%ecx            // jmp_buf
	popl	%eax            // return value
	//cmpl	$1, %eax        // (0 should become 1 according to ANSI C,
	//adcl	$0, %eax        // but we don't need this feature)
	movl	0(%ecx), %ebx
	movl	4(%ecx), %esp
	movl	8(%ecx), %ebp
	movl	12(%ecx), %esi
	movl	16(%ecx), %edi
	jmp	*20(%ecx)
