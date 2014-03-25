#include <os.h>

main: .global main
	@ this can be used to set a breakpoint
	@bkpt
	push {r3, lr}
	bl lcd_ingray
	bl clrscr
	adr r0, str
	@ call syscalls this way
	syscall(strlen)
	mov r3, #0
	ldr r1, =0xC0000010 @ screen address
	ldr r1,[r1]
draw_line:
	@ in grayscale mode, each 4-byte word represents 8 pixels
	mov r2, #SCREEN_WIDTH/8
draw4b:
	str r3, [r1], #4
	subs r2, #1
	bne draw4b
	@ skip a line
	add r1, #SCREEN_WIDTH/2
	subs r0, #1
	bne draw_line
	@ call libndls functions with bl
	bl wait_key_pressed
	mov  r0, #0
	pop  {r3, pc}

@ dummy str to show syscalls
str: .asciz "1234567890123456789"
