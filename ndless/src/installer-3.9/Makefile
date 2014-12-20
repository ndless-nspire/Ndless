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

all: ndless_installer_3.9.0_classic.tns ndless_installer_3.9.0.tns ndless_installer_3.9.1.tns

%.o: %.c
	$(GCC) $(GCCFLAGS) -c $< -o $@
	
%.o: %.cpp
	$(GPP) $(GPPFLAGS) -c $< -o $@

%.o: %.S
	$(AS) $(GCCFLAGS) -c $< -o $@

%_3.9.0.o: %.cpp
	$(GPP) $(GPPFLAGS) -c $< -o $@ -DNDLESS_39=39

%_3.9.1.o: %.cpp
	$(GPP) $(GPPFLAGS) -c $< -o $@ -DNDLESS_39=391

%_3.9.0.o: %.c
	$(GCC) $(GCCFLAGS) -c $< -o $@ -DNDLESS_39=39

%_3.9.1.o: %.c
	$(GCC) $(GCCFLAGS) -c $< -o $@ -DNDLESS_39=391

ndless_installer_%.elf: stage2_%.o utils_%.o | stage1.o
	$(LD) $(LDFLAGS) $^ -o $@

%.bin: %.elf
	$(OBJCOPY) -O binary $< $@

stage0.bin: stage0.o
	$(OBJCOPY) -O binary $< $@

ndless_installer_%.tns: Problem1_%.xml
	cat Problem1_pre.xml $< Problem1_mid.xml $< Problem1_post.xml > Problem1.xml
	mkdir -p $(DISTDIR)
	../../../ndless-sdk/tools/luna/luna Problem1.xml Document.xml pics/BBF7096DCAF1CD03DE8364E14DB58939.BMP pics/1C86D1B39DEB85D42F438DE2C0C3BF78.BMP $(DISTDIR)/$@
	rm Problem1.xml

ndless_installer_3.9.0_classic.tns: Problem1_3.9.0.xml
	cat Problem1_pre_classic.xml $< Problem1_post.xml > Problem1.xml
	mkdir -p $(DISTDIR)
	../../../ndless-sdk/tools/luna/luna Problem1.xml $(DISTDIR)/$@
	rm Problem1.xml

Problem1_3.9.0.xml: ndless_installer_3.9.0.bin stage0.bin
	../tools/XORInstaller/XORInstaller $< $(<:.bin=-xord.bin)
	cat stage0.bin $(<:.bin=-xord.bin) > $(<:.bin=-escaped.bin)
	rm $(<:.bin=-xord.bin)
	../tools/MakeQnAInst/MakeQnAInst $(<:.bin=-escaped.bin) $@
	rm $(<:.bin=-escaped.bin)

Problem1_3.9.1.xml: ndless_installer_3.9.1.bin stage0.bin
	../tools/XORInstaller/XORInstaller $< $(<:.bin=-xord.bin)
	cat stage0.bin $(<:.bin=-xord.bin) > $(<:.bin=-escaped.bin)
	rm $(<:.bin=-xord.bin)
	../tools/MakeQnAInst/MakeQnAInst $(<:.bin=-escaped.bin) $@ --391
	rm $(<:.bin=-escaped.bin)

clean:
	rm -f *.o *.elf *.bin Problem1_3.9.*.xml
