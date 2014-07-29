GCC := nspire-gcc
GPP := nspire-g++
AS := nspire-as
LD := "$(shell (which arm-elf-ld arm-none-eabi-ld arm-linux-gnueabi-ld | head -1) 2>/dev/null)"
OBJCOPY := "$(shell (which arm-elf-objcopy arm-none-eabi-objcopy arm-linux-gnueabi-objcopy | head -1) 2>/dev/null)"

GCCFLAGS := -Os -Wall -W -Wno-strict-aliasing -nostdlib -DSTAGE1 -fPIE
GPPFLAGS := $(GCCFLAGS) -std=c++11 -fno-exceptions -fno-rtti
LDFLAGS := -nostdlib -Tldscript
DISTDIR := ../../calcbin
vpath %.tns $(DISTDIR)

all: ndless_installer.tns

%.o: %.c
	$(GCC) $(GCCFLAGS) -c $<
	
%.o: %.cpp
	$(GPP) $(GPPFLAGS) -c $<

%.o: %.S
	$(AS) $(GCCFLAGS) -c $<

%.elf: %.o
	$(LD) $(LDFLAGS) $^ -o $@

ndless_installer.elf: stage1.o stage2.o
	$(LD) $(LDFLAGS) stage2.o -o $@ ../resources/utils.o

ndless_installer.bin: ndless_installer.elf
	$(OBJCOPY) -O binary $< $@

stage0.bin: stage0.o
	$(OBJCOPY) -O binary $< $@

ndless_installer.lua: ndless_installer.bin stage0.bin
	../tools/EscapeInstaller/EscapeInst $< $(<:.bin=-escaped.bin)
	cat stage0.bin $(<:.bin=-escaped.bin) > $(<:.bin=-escaped.bin.tmp)
	mv $(<:.bin=-escaped.bin.tmp) $(<:.bin=-escaped.bin)
	../tools/MakeLuaInst/MakeLuaInst $(<:.bin=-escaped.bin) $(<:.bin=-escaped.lua.tmp)
	@# skip the UTF-8 BOM marker
	tail --bytes=+4 ndless_installer.lua.tpl > ndless_installer.lua.nobom.tpl.tmp
	cat ndless_version.lua ndless_installer.lua.nobom.tpl.tmp $(<:.bin=-escaped.lua.tmp) > $@
	rm $(<:.bin=-escaped.lua.tmp) $(<:.bin=-escaped.bin) ndless_installer.lua.nobom.tpl.tmp

ndless_installer.tns: ndless_installer.lua
	@mkdir -p $(DISTDIR)
	../../../ndless-sdk/tools/luna/luna $< $(DISTDIR)/$@

clean:
	rm -rf ndless_installer.elf $(INST_OBJS)
	rm -rf *.o *.elf stage0.bin ndless_installer.bin ndless_installer.lua *.tmp
