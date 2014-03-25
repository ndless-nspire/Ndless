OBJ = armloader.o asmcode.o casplus.o cpu.o des.o debug.o emu.o flash.o gdbstub.o gui.o interrupt.o keypad.o lcd.o link.o memory.o misc.o mmu.o os-win32.o resource.o schedule.o serial.o sha256.o snippets.o translate.o usb.o usblink.o

FLAGS = -W -Wall -m32

CC ?= gcc
LD ?= ld
WINDRES ?= windres
OBJCOPY ?= objcopy

all : nspire_emu.exe

emu.exe : $(OBJ)
	$(CC) $(FLAGS) $(OBJ) -o $@ -lgdi32 -lcomdlg32 -lwinmm -lws2_32

nspire_emu.exe : $(OBJ)
	$(CC) $(FLAGS) $(OBJ) -o $@ -lgdi32 -lcomdlg32 -lwinmm -lws2_32 -s -Wl,--nxcompat

cpu.o : cpu.c
	$(CC) $(FLAGS) -O3 -c $< -o $@

resource.o : resource.rc id.h
	$(WINDRES) -Fpe-i386 $< -o $@

sha256.o : sha256.c
	$(CC) $(FLAGS) -O3 -c $< -o $@

asmcode.o : asmcode.S
	$(CC) $(FLAGS) -c $< -o $@

armsnippets.o: armsnippets.S
	arm-none-eabi-gcc -c -mcpu=arm7tdmi $< -o $@

snippets.o: armsnippets.o
	arm-none-eabi-objcopy -O binary $< snippets.bin
	$(LD) -r -b binary -o snippets.o snippets.bin
	rm snippets.bin
	$(OBJCOPY) -Fpe-i386 --rename-section .data=.rodata,alloc,load,readonly,data,contents snippets.o snippets.o

%.o : %.c
	$(CC) $(FLAGS) -Os -c $< -o $@

clean : 
	rm -f *.o nspire_emu.exe emu.exe
