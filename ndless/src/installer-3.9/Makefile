GCC := nspire-gcc
GPP := nspire-g++
AS := nspire-as
LD := "$(shell (which arm-elf-ld arm-none-eabi-ld arm-linux-gnueabi-ld | head -1) 2>/dev/null)"
OBJCOPY := "$(shell (which arm-elf-objcopy arm-none-eabi-objcopy arm-linux-gnueabi-objcopy | head -1) 2>/dev/null)"

GCCFLAGS := -Os -Wall -Wextra -nostdlib -fPIE -DSTAGE1
GPPFLAGS := $(GCCFLAGS) -std=c++11 -fno-exceptions -fno-rtti
LDFLAGS := -nostdlib -Tldscript
DISTDIR := ../../calcbin
vpath %.tns $(DISTDIR)

all: ndless_installer_3.9.tns ndless_installer_3.9.1.tns

%.o: %.c
	$(GCC) $(GCCFLAGS) -c $< -o $@
	
%.o: %.cpp
	$(GPP) $(GPPFLAGS) -c $< -o $@

%.o: %.S
	$(AS) $(GCCFLAGS) -c $< -o $@

%_3.9.o: %.cpp
	$(GPP) $(GPPFLAGS) -c $< -o $@ -DNDLESS_39=39

%_3.9.1.o: %.cpp
	$(GPP) $(GPPFLAGS) -c $< -o $@ -DNDLESS_39=391

%_3.9.o: %.c
	$(GCC) $(GCCFLAGS) -c $< -o $@ -DNDLESS_39=39

%_3.9.1.o: %.c
	$(GCC) $(GCCFLAGS) -c $< -o $@ -DNDLESS_39=391

ndless_installer_%.elf: stage2_%.o utils_%.o | stage1.o
	$(LD) $(LDFLAGS) $^ -o $@

%.bin: %.elf
	$(OBJCOPY) -O binary $< $@

stage0.bin: stage0.o
	$(OBJCOPY) -O binary $< $@

ndless_installer_3.9.tns: ndless_installer_3.9.bin stage0.bin
	../tools/XORInstaller/XORInstaller $< $(<:.bin=-xord.bin)
	cat stage0.bin $(<:.bin=-xord.bin) > $(<:.bin=-escaped.bin)
	rm $(<:.bin=-xord.bin)
	../tools/MakeQnAInst/MakeQnAInst $(<:.bin=-escaped.bin) Problem1.xml
	rm $(<:.bin=-escaped.bin)
	@mkdir -p $(DISTDIR)
	../../../ndless-sdk/tools/luna/luna Problem1.xml $(DISTDIR)/$@
	rm Problem1.xml

ndless_installer_3.9.1.tns: ndless_installer_3.9.1.bin stage0.bin
	../tools/XORInstaller/XORInstaller $< $(<:.bin=-xord.bin)
	cat stage0.bin $(<:.bin=-xord.bin) > $(<:.bin=-escaped.bin)
	rm $(<:.bin=-xord.bin)
	../tools/MakeQnAInst/MakeQnAInst $(<:.bin=-escaped.bin) Problem1.xml --391
	rm $(<:.bin=-escaped.bin)
	@mkdir -p $(DISTDIR)
	../../../ndless-sdk/tools/luna/luna Problem1.xml $(DISTDIR)/$@
	rm Problem1.xml

clean:
	rm -f *.o *.elf *.bin Problem1.xml
