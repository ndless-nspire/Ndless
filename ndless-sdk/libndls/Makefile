AS = nspire-as
GCC = nspire-gcc
GXX = nspire-g++
LD = nspire-ld
AR := "$(shell (which arm-elf-ar arm-none-eabi-ar arm-linux-gnueabi-ar | head -1) 2>/dev/null)"

GCCFLAGS = -Os -nostdlib -Wall -Werror -Wextra -ffunction-sections -fdata-sections
GXXFLAGS = $(GCCFLAGS) -fno-rtti -fno-exceptions -std=c++11
LDFLAGS = -nostdlib
LIB = libndls.a
DISTDIR = ../lib
vpath %.a $(DISTDIR)
OBJS = $(patsubst %.c,%.o,$(wildcard *.c)) $(patsubst %.cpp,%.o,$(wildcard *.cpp))

all: static $(LIB)

%.o: %.c
	$(GCC) $(GCCFLAGS) -c $<

%.o: %.cpp
	$(GXX) $(GXXFLAGS) -c $<

%.o: %.S
	$(AS) $(GCCFLAGS) -c $<

%.elf: %.o
	$(LD) $(LDFLAGS) $^ -o $@

# Force ARM mode for functions which uses non-Thumb inline assembly
clear_cache.o idle.o: GCCFLAGS+=-marm

static:
	@mkdir -p $(DISTDIR)
	
$(LIB): $(OBJS)
	$(AR) rcs $(DISTDIR)/$(LIB) $^

clean:
	rm -rf *.o *.elf *.a
	rm -f $(DISTDIR)/$(LIB)
