GXX := "$(shell (which arm-elf-g++ arm-none-eabi-g++ arm-linux-gnueabi-g++ | head -1) 2>/dev/null)"
OBJCOPY := "$(shell (which arm-elf-objcopy arm-none-eabi-objcopy arm-linux-gnueabi-objcopy | head -1) 2>/dev/null)"
CHOST := $(shell (echo $(shell basename $(GXX)) | sed 's/-g++$$//'))

GXXFLAGS := -g -Os -Wall -Wextra -march=armv5te -fPIE -std=c++11 -fno-rtti -fno-exceptions -Wl,-Tldscript -Wl,--gc-sections -nostdlib -nostartfiles -ffreestanding -I ../../include
ZLIB_CFLAGS := -Os -fPIE -ffunction-sections -fdata-sections -DNO_GZIP -ffreestanding -c

all: zehn_loader.tns zehn_loader_compressed.tns

zehn_loader_compressed.tns.elf: loader.cpp zlib/libz.a
	$(GXX) $(GXXFLAGS) $^ -o $@ -DENABLE_ZLIB -lgcc

zehn_loader.tns.elf: loader.cpp
	$(GXX) $(GXXFLAGS) $^ -o $@

zehn_loade%.tns: zehn_loade%.tns.elf
	$(OBJCOPY) -O binary $^ $@

zlib/Makefile: ../../thirdparty/zlib/configure
	mkdir -p zlib
	cd zlib && CC=nspire-gcc CHOST=$(CHOST) CFLAGS="$(ZLIB_CFLAGS)" ../$^ --static

zlib/libz.a: zlib/Makefile
	$(MAKE) -C zlib libz.a

clean:
	rm -f zehn_loader*.tns*
	-$(MAKE) -C zlib clean
	rm -f zlib/Makefile
