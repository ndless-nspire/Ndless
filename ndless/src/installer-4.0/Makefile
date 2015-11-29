GCC := nspire-gcc
GPP := nspire-g++
AS := nspire-as
LD := "$(shell (which arm-elf-ld arm-none-eabi-ld arm-linux-gnueabi-ld | head -1) 2>/dev/null)"
OBJCOPY := "$(shell (which arm-elf-objcopy arm-none-eabi-objcopy arm-linux-gnueabi-objcopy | head -1) 2>/dev/null)"

CXXFLAGS := -std=c++11
GCCFLAGS := -Os -Wall -Wextra -nostdlib -fPIE -DSTAGE1 -D NDLESS_403
GXXFLAGS := $(GCCFLAGS) -std=c++11 -fno-exceptions -fno-rtti
LFLAGS := -nostdlib -Tldscript
DISTDIR := ../../calcbin
vpath %.tns $(DISTDIR)

all: ndless_installer_4.0.3_cascx.tns

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

ndless_installer.elf: stage1.o utils.o | stage0.o
	$(LD) $(LFLAGS) $^ -o $@

Problem1_mid.xml: ndless_installer.bin | luabin
	./luabin $^ $@

Problem1.xml: Problem1_top.xml Problem1_mid.xml Problem1_bot.xml
	cat $^ > $@

ndless_installer_4.0.3_%.tns: Problem2_%.xml | Document.xml Problem1.xml
	ln -sf $< Problem2.xml
	mkdir -p $(DISTDIR)
	../../../ndless-sdk/tools/luna/luna Document.xml Problem1.xml Problem2.xml $(DISTDIR)/$@

test: ndless_installer_4.0.3_cascx.tns
	firebird-send $^ ndless

clean:
	rm -f luabin Problem1.xml Problem2.xml Problem1_mid.xml *.elf *.o *.bin $(DISTDIR)/ndless_installer_4.0.3_cascx.tns

.PHONY: test clean
