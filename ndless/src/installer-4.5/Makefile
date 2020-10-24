GCC := nspire-gcc
GPP := nspire-g++
AS := nspire-as
LD := "$(shell (which arm-elf-ld arm-none-eabi-ld arm-linux-gnueabi-ld | head -1) 2>/dev/null)"
OBJCOPY := "$(shell (which arm-elf-objcopy arm-none-eabi-objcopy arm-linux-gnueabi-objcopy | head -1) 2>/dev/null)"

BASE64 := base64 -w0
ifneq ($(shell base64 -w0 >/dev/null 2>&1 </dev/null; echo $$?),0)
	BASE64 := base64
endif

GCCFLAGS := -Os -Wall -Wextra -nostdlib -fPIE -DSTAGE1 -D NDLESS_450
GXXFLAGS := $(GCCFLAGS) -std=c++11 -fno-exceptions -fno-rtti
LFLAGS := -nostdlib -Tldscript
DISTDIR := ../../calcbin

all: $(DISTDIR)/ndless_installer_4.5.0.tns

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

payload: ndless_installer.bin
	(../tools/MakeChunkDispatch/MakeChunkDispatch 0x1800e7f4 0x12480000; cat $^) | $(BASE64) > $@ || rm $@

ndless_installer.elf: stage0.o stage1.o utils.o
	$(LD) $(LFLAGS) $^ -o $@

Problem1.xml: Problem1_top.xml payload Problem1_mid.xml Problem1_bot.xml
	cat Problem1_top.xml Problem1_mid.xml payload Problem1_bot.xml > $@

$(DISTDIR)/ndless_installer_4.5.0.tns: Problem1.xml
	mkdir -p $(DISTDIR)
	../../../ndless-sdk/tools/luna/luna Problem1.xml $@

test: $(DISTDIR)/ndless_installer_4.5.0.tns
	firebird-send $^ ndless

clean:
	rm -f Problem1.xml payload *.elf *.o *.bin $(DISTDIR)/ndless_installer_4.5.0.tns

.PHONY: all test clean
