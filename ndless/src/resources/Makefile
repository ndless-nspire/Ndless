DEBUG = FALSE

GCC = nspire-gcc
AS  = nspire-as
GXX = nspire-g++
LD  = nspire-ld
GENZEHN = genzehn

GCCFLAGS = -Wall -Wextra -W -marm
LDFLAGS = -Wl,-e,main,--gc-sections
ZEHNFLAGS = --name "ndless_resources" --include-bss --uses-lcd-blit true --version 2018

ifeq ($(DEBUG),FALSE)
	GCCFLAGS += -Os
else
	GCCFLAGS += -O0 -g
endif

OBJS = $(patsubst %.c, %.o, $(shell find . -name \*.c))
OBJS += $(patsubst %.cpp, %.o, $(shell find . -name \*.cpp))
OBJS += $(patsubst %.S, %.o, $(shell find . -name \*.S))
ZEHN = ndless_resources_zehn.tns
EXE = ../../calcbin/ndless_resources.tns

all: $(EXE)

%.o: %.c
	$(GCC) $(GCCFLAGS) -std=gnu11 -c $<

%.o: %.cpp
	$(GXX) $(GCCFLAGS) -std=c++11 -fno-exceptions -fno-rtti -c $<
	
%.o: %.S
	$(AS) -c $<

$(ZEHN).elf: $(OBJS)
	$(LD) $^ -o $@ $(LDFLAGS)

$(ZEHN): $(ZEHN).elf
	$(GENZEHN) --input $^ --output $@ $(ZEHNFLAGS)

$(EXE): $(ZEHN)
	make-prg $^ $@

test: $(EXE)
	firebird-send $^ ndless

clean:
	rm -f *.o $(ZEHN) $(ZEHN).elf $(EXE)

.PHONY: all test clean
