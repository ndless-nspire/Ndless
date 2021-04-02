.text
_start: .global _start
.org 0 @ Actually not, but this is PIC
.rep 1152
b begin
.endr

begin:
push {r4-r12, lr}
sub	sp, sp, #0x40

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
.word 0x1040F3B0 @ 5.2.0.771 CX II CAS
os_stat:
.word 0x10484188 @ stat
os_malloc:
.word 0x10475F98 @ malloc
os_fopen:
.word 0x1047BDEC @ fopen
os_fread:
.word 0x1047BF90 @ fread
os_fclose:
.word 0x1047B86C @ fclose
nextos:

.word 0x1040EAE0 @ 5.2.0.771 non-CAS CX II-T
.word 0x104838B8 @ stat
.word 0x104756C8 @ malloc
.word 0x1047B51C @ fopen
.word 0x1047B6C0 @ fread
.word 0x1047AF9C @ fclose

.word 0x1040E4D0 @ 5.2.0.771 non-CAS CX II
.word 0x104832A8 @ stat
.word 0x104750B8 @ malloc
.word 0x1047AF0C @ fopen
.word 0x1047B0B0 @ fread
.word 0x1047A98C @ fclose

.word 0x103B3740 @ 4.5.3.14 CAS CX
.word 0x10443778 @ stat
.word 0x10435BC8 @ malloc
.word 0x1043B4B8 @ fopen
.word 0x1043B65C @ fread
.word 0x1043ACD8 @ fclose

.word 0x103B3020 @ 4.5.3.14 non-CAS CX
.word 0x10443010 @ stat
.word 0x104354A8 @ malloc
.word 0x1043AD98 @ fopen
.word 0x1043AF3C @ fread
.word 0x1043A5B8 @ fclose

.word 0x10417DA0 @ 5.3.0.564 CAS CX II
.word 0x1048CB78 @ stat
.word 0x1047E988 @ malloc
.word 0x104847DC @ fopen
.word 0x10484980 @ fread
.word 0x1048425C @ fclose

.word 0x10417460 @ 5.3.0.564 non-CAS CX II-T
.word 0x1048C238 @ stat
.word 0x1047E048 @ malloc
.word 0x10483E9C @ fopen
.word 0x10484040 @ fread
.word 0x1048391C @ fclose

.word 0x10416CC0 @ 5.3.0.564 non-CAS CX II
.word 0x1048BA98 @ stat
.word 0x1047D8A8 @ malloc
.word 0x104836FC @ fopen
.word 0x104838A0 @ fread
.word 0x1048317C @ fclose

.word 0x103B4130 @ 4.5.4.48 CAS CX
.word 0x10444168 @ stat
.word 0x104365B8 @ malloc
.word 0x1043BEA8 @ fopen
.word 0x1043C04C @ fread
.word 0x1043B6C8 @ fclose

.word 0x103B3A10 @ 4.5.4.48 non-CAS CX
.word 0x10443A00 @ stat
.word 0x10435E98 @ malloc
.word 0x1043B788 @ fopen
.word 0x1043B92C @ fread
.word 0x1043AFA8 @ fclose

endos:
.word 0x0

respath:
.asciz "ndless/ndless_resources.tns"

oflags:
.asciz "rb"
