GXX := "$(shell (which arm-elf-g++ arm-none-eabi-g++ arm-linux-gnueabi-g++ | head -1) 2>/dev/null)"
OBJCOPY := "$(shell (which arm-elf-objcopy arm-none-eabi-objcopy arm-linux-gnueabi-objcopy | head -1) 2>/dev/null)"

GXXFLAGS := -Os -Wall -Wextra -march=armv5te -fPIE -std=c++11 -fno-rtti -fno-exceptions -Wl,-Tldscript -nostdlib -nostartfiles -I ../../include

all: zehn_loader.tns

zehn_loader.tns.elf: loader.cpp
	$(GXX) $(GXXFLAGS) $^ -o $@

zehn_loader.tns: zehn_loader.tns.elf
	$(OBJCOPY) -O binary $^ $@

clean:
	rm -f zehn_loader.tns*
