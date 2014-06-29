_start: .global _start
	push {r0-r12,lr}

	@ If already run, return directly
	ldrb r1, already_run
	subs r1, r1, #1
	popeq {r0-r12,pc}
	mov r1, #1
	str r1, already_run

	adr r6, escaped_start
	ldrh r2, [r6], #2 @ XOR key
	sub r2, r2, #0x100
	ldrh r1, [r6], #2 @ Installer size
	sub r1, r1, #0x100
	mov r4, r6

xor_loop:
	ldrb r5, [r4], #1
	sub r4, r4, #1
	eor r5, r5, r2
	strb r5, [r4], #1
	subs r1, r1, #1
	bne xor_loop
	blx r6
	pop {r0-r12,pc}

already_run:
	.long 0x02020202

escaped_start:
	@ concatenated here by the Makefile. Contains the installer size, XOR key, then the installer.
	
