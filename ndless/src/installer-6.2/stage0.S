.text
_start: .global _start
.org 0 @ Actually not, but this is PIC

push {r4-r12, lr}
sub	sp, sp, #0x40

@ status = 1
mov r0, #1
str r0, result

@ r10 = pointer to osdata struct
adr	r10, osdata
mov	r0, #0x10000000
ldr	r1, [r0, #0x20] @ r1 = reset vector

osloop:
ldr	r2, [r10, #0] @ r2 = expected reset vector
cmp	r2, r1
beq	osfound
cmp	r2, #0
beq	return
add	r10, r10, #(nextos-osdata)
b osloop

osfound: @ r10 points to the right OS now

@ status = 2 
mov r0, #2
str r0, result

adr	r0, respath
mov	r1, sp
mov	lr, pc
ldr	pc, [r10, #(os_stat-osdata)] @ call stat
cmp	r0, #0
bne	return
ldr	r4, [sp, #0x14] @ r4 = stat.st_size
mov	r0, r4
mov	lr, pc
ldr	pc, [r10, #(os_malloc-osdata)] @ call malloc
movs	r5, r0 @ r5 = pointer to alloc'd area
beq	return
@ TODO: Align?
adr	r0, respath
adr	r1, oflags
mov	lr, pc
ldr	pc, [r10, #(os_fopen-osdata)] @ call fopen
movs	r6, r0 @ r6 = FILE*
beq	return

@ status = 3
mov r0, #3
str r0, result

mov	r0, r5
mov	r1, r4
mov	r2, #1
mov	r3, r6
mov	lr, pc
ldr	pc, [r10, #(os_fread-osdata)] @ call fread
@ No error handling here...
mov	r0, r6
mov	lr, pc
ldr	pc, [r10, #(os_fclose-osdata)] @ call fclose

@ Flush the caches
0: mrc p15, 0, r15, c7, c10, 3
bne 0b
mov r0, #0
mcr p15, 0, r0, c7, c7, 0

@ Finally, call ndless_resources
mov	r0, #0
adr	r1, endos
mov	lr, pc
add	pc, r5, #4 @ sizeof("PRG")

return:
add	sp, sp, #0x40
pop {r4-r12, pc}

osdata:
.word 0x103B18E0 @ 4.5.5.79 CX
os_stat:
.word 0x104418D0 @ stat
os_malloc:
.word 0x10433D68 @ malloc
os_fopen:
.word 0x10439658 @ fopen
os_fread:
.word 0x104397FC @ fread
os_fclose:
.word 0x10438E78 @ fclose
nextos:

.word 0x103B1F80 @ 4.5.5.79 CX CAS
.word 0x10441FB8 @ stat
.word 0x10434408 @ malloc
.word 0x10439CF8 @ fopen
.word 0x10439E9C @ fread
.word 0x10439518 @ fclose

.word 0x10429E10 @ 6.2.0.333 CX II
.word 0x10493508 @ stat
.word 0x1009A244 @ malloc
.word 0x104234EC @ fopen
.word 0x10423690 @ fread
.word 0x10422F6C @ fclose

.word 0x1042A580 @ 6.2.0 CX II-T
.word 0x10493c78 @ stat
.word 0x1009a3f0 @ malloc
.word 0x10423c64 @ fopen
.word 0x10423e08 @ fread
.word 0x104236e4 @ fclose

.word 0x1042AE10 @ 6.2.0.333 CX II CAS
.word 0x10494508 @ stat
.word 0x10099E84 @ malloc
.word 0x104244F4 @ fopen
.word 0x10424698 @ fread
.word 0x10423F74 @ fclose

@ If this gets too big for a column, there is overlap
@ and this needs to divert execution to the lcd mirror!

endos:
.word 0x0

respath:
.asciz "ndless/ndless_resources.tns"

oflags:
.asciz "rb"

@ result variable is periodically read by the installer through a hardcoded offset.
@ will be used to determine the success

.align 2
result:
.word 0x0
