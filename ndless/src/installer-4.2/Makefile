GCC := nspire-gcc
GPP := nspire-g++
AS := nspire-as
LD := "$(shell (which arm-elf-ld arm-none-eabi-ld arm-linux-gnueabi-ld | head -1) 2>/dev/null)"
OBJCOPY := "$(shell (which arm-elf-objcopy arm-none-eabi-objcopy arm-linux-gnueabi-objcopy | head -1) 2>/dev/null)"

GCCFLAGS := -Os -Wall -Wextra -nostdlib -fPIE -DSTAGE1 -D NDLESS_420
GXXFLAGS := $(GCCFLAGS) -std=c++11 -fno-exceptions -fno-rtti
LFLAGS := -nostdlib -Tldscript
DISTDIR := ../../calcbin
vpath %.tns $(DISTDIR)

all: ndless_installer_4.2.0_cx.tns ndless_installer_4.2.0_cascx.tns

%.o: %.c
	$(GCC) $(GCCFLAGS) -c $< -o $@
	
%.o: %.cpp
	$(GPP) $(GXXFLAGS) -c $< -o $@

%.o: %.S
	$(AS) $(GCCFLAGS) -c $< -o $@

%.bin: %.elf
	$(OBJCOPY) -O binary $^ $@

%.bin: %.o
	$(OBJCOPY) -O binary $^ $@

ndless_installer.elf: stage0.o stage1.o utils.o
	$(LD) $(LFLAGS) stage1.o utils.o -o $@

Problem1_mid.xml: ndless_installer.bin
	../tools/LuaBin/luabin $^ $@

Problem1.xml: Problem1_top.xml Problem1_mid.xml Problem1_bot.xml
	cat $^ > $@

# Those can't be built simultaneously due to using "Problem2.xml" as filename
ndless_installer_4.2.0_cascx.tns: ndless_installer_4.2.0_cx.tns

ndless_installer_4.2.0_%.tns: Problem2_%.xml Document.xml Problem1.xml
	ln -sf $< Problem2.xml
	mkdir -p $(DISTDIR)
	../../../ndless-sdk/tools/luna/luna Document.xml Problem1.xml Problem2.xml $(DISTDIR)/$@

test: ndless_installer_4.2.0_cascx.tns
	firebird-send $^ ndless

clean:
	rm -f Problem1.xml Problem2.xml Problem1_mid.xml *.elf *.o *.bin $(DISTDIR)/ndless_installer_4.2.0_cx.tns $(DISTDIR)/ndless_installer_4.2.0_cascx.tns

.PHONY: test clean
