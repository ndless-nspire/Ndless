GCC := nspire-gcc
GPP := nspire-g++
AS := nspire-as
LD := "$(shell (which arm-elf-ld arm-none-eabi-ld arm-linux-gnueabi-ld | head -1) 2>/dev/null)"
OBJCOPY := "$(shell (which arm-elf-objcopy arm-none-eabi-objcopy arm-linux-gnueabi-objcopy | head -1) 2>/dev/null)"

GCCFLAGS := -Os -Wall -Wextra -nostdlib -fPIE -DSTAGE1 -flto -fno-fat-lto-objects
GXXFLAGS := $(GCCFLAGS) -std=c++11 -fno-exceptions -fno-rtti
LFLAGS := -nostdlib
DISTDIR := ../../calcbin

all: $(DISTDIR)/ndless_installer_5.2.0-5.3.0.tns $(DISTDIR)/ndless_installer_4.5.3-4.5.4.tns

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

ndless_installer.elf: stage0.o
	$(LD) $(LFLAGS) $^ -o $@

Problem1_mid.xml: ndless_installer.bin
	../tools/LuaBin/luabin ndless_installer.bin - installer > $@

# Those can't be built simultaneously due to using "Problem1.xml" as filename
$(DISTDIR)/ndless_installer_5.2.0-5.3.0.tns: $(DISTDIR)/ndless_installer_4.5.3-4.5.4.tns

$(DISTDIR)/ndless_installer_%.tns: Problem1_top.xml Problem1_mid.xml Problem1_bot.xml
	mkdir -p $(DISTDIR)
	cat Problem1_top.xml Problem1_mid.xml Problem1_bot.xml > Problem1.xml
	../../../ndless-sdk/tools/luna/luna Problem1.xml $@
	rm Problem1.xml

test: $(DISTDIR)/ndless_installer_5.2.0-5.3.0.tns
	firebird-send $^ ndless

clean:
	rm -f Problem1.xml Problem1_mid.xml *.elf *.o *.bin $(DISTDIR)/ndless_installer_5.2.0.tns $(DISTDIR)/ndless_installer_4.5.3.tns

.PHONY: test clean
