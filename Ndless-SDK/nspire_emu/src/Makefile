OBJ = armloader.o asmcode.o casplus.o cpu.o des.o debug.o emu.o flash.o gdbstub.o gui.o interrupt.o keypad.o lcd.o link.o memory.o misc.o mmu.o os-win32.o resource.o schedule.o serial.o sha256.o snippets.o translate.o usb.o usblink.o

FLAGS = -W -Wall -m32
ifneq ($(OS),Windows_NT)
PREFIX=i686-w64-mingw32-
endif
CC = $(PREFIX)gcc
LD = $(PREFIX)ld
WINDRES = $(PREFIX)windres
OBJCOPY = $(PREFIX)objcopy
DISTDIR := ../bin
vpath %.exe $(DISTDIR)

ifneq ($(shell (which $(CC) | head -1) 2>/dev/null),)
all : nspire_emu.exe static
else
all : static
endif

static:
	mkdir -p $(DISTDIR)
	cp *.sh *.bat $(DISTDIR)

nspire_emu.exe : $(OBJ)
	mkdir -p $(DISTDIR)
	$(CC) $(FLAGS) $(OBJ) -o  $(DISTDIR)/$@ -lgdi32 -lcomdlg32 -lwinmm -lws2_32 -s -Wl,--nxcompat

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
	rm -rf *.o  $(DISTDIR)

