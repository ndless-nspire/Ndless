AS = nspire-as
AR := "$(shell (which arm-elf-ar arm-none-eabi-ar arm-linux-gnueabi-ar | head -1) 2>/dev/null)"
GCC = nspire-gcc
GCCFLAGS = -Os -nostdlib
LD = nspire-ld
LDFLAGS = -nostdlib
OBJCOPY := "$(shell (which arm-elf-objcopy arm-none-eabi-objcopy arm-linux-gnueabi-objcopy | head -1) 2>/dev/null)"
LIB = libndls.a
DISTDIR = ../lib
vpath %.a $(DISTDIR)
OBJS = $(patsubst %.c,%.o,$(wildcard *.c))

all: static $(LIB)

%.o: %.c
	$(GCC) $(GCCFLAGS) -c $<

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
