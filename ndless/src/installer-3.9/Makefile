GCC := nspire-gcc
GPP := nspire-g++
AS := nspire-as
LD := "$(shell (which arm-elf-ld arm-none-eabi-ld arm-linux-gnueabi-ld | head -1) 2>/dev/null)"
OBJCOPY := "$(shell (which arm-elf-objcopy arm-none-eabi-objcopy arm-linux-gnueabi-objcopy | head -1) 2>/dev/null)"

GCCFLAGS := -Os -Wall -Wextra -nostdlib -fPIE -DSTAGE1 -DNDLESS_39
GPPFLAGS := $(GCCFLAGS) -std=c++11 -fno-exceptions -fno-rtti
LDFLAGS := -nostdlib -Tldscript
DISTDIR := ../../calcbin
vpath %.tns $(DISTDIR)

all: ndless_installer_3.9.tns ndless_installer_3.9.1.tns

%.o: %.c
	$(GCC) $(GCCFLAGS) -c $<
	
%.o: %.cpp
	$(GPP) $(GPPFLAGS) -c $<

%.o: %.S
	$(AS) $(GCCFLAGS) -c $<

%.elf: %.o
	$(LD) $(LDFLAGS) $^ -o $@

ndless_installer.elf: stage1.o stage2.o utils.o
	$(LD) $(LDFLAGS) stage2.o utils.o -o $@

ndless_installer.bin: ndless_installer.elf
	$(OBJCOPY) -O binary $< $@

stage0.bin: stage0.o
	$(OBJCOPY) -O binary $< $@

ndless_installer_3.9.tns: ndless_installer.bin stage0.bin
	../tools/XORInstaller/XORInstaller $< $(<:.bin=-xord.bin)
	cat stage0.bin $(<:.bin=-xord.bin) > $(<:.bin=-escaped.bin)
	rm $(<:.bin=-xord.bin)
	../tools/MakeQnAInst/MakeQnAInst $(<:.bin=-escaped.bin) Problem1.xml
	rm $(<:.bin=-escaped.bin)
	@mkdir -p $(DISTDIR)
	../../../ndless-sdk/tools/luna/luna Problem1.xml $(DISTDIR)/$@
	rm Problem1.xml

ndless_installer_3.9.1.tns: ndless_installer.bin stage0.bin
	../tools/XORInstaller/XORInstaller $< $(<:.bin=-xord.bin)
	cat stage0.bin $(<:.bin=-xord.bin) > $(<:.bin=-escaped.bin)
	rm $(<:.bin=-xord.bin)
	../tools/MakeQnAInst/MakeQnAInst $(<:.bin=-escaped.bin) Problem1.xml --391
	rm $(<:.bin=-escaped.bin)
	@mkdir -p $(DISTDIR)
	../../../ndless-sdk/tools/luna/luna Problem1.xml $(DISTDIR)/$@
	rm Problem1.xml

clean:
	rm -f ndless_installer.elf ndless_installer.bin
	rm -f *.o *.elf stage0.bin Problem1.xml *.tmp
