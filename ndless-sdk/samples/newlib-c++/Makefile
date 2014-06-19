DEBUG = FALSE
GCC = nspire-zehn-gcc
AS = nspire-as
GXX =nspire-zehn-g++
LD = nspire-zehn-ld
GCCFLAGS = -Wall -W -marm -fno-exceptions -fno-rtti
LDFLAGS =
ifeq ($(DEBUG),FALSE)
	GCCFLAGS += -Os
else
	GCCFLAGS += -O0 -g
	LDFLAGS += --debug
endif
CPPOBJS = $(patsubst %.cpp,%.o,$(wildcard *.cpp))
COBJS = $(patsubst %.c,%.o,$(wildcard *.c)) 
ASMOBJS = $(patsubst %.S,%.o,$(wildcard *.S))
OBJS = $(CPPOBJS) $(COBJS) $(ASMOBJS)
EXE = newlibcpp.tns

all: $(EXE)

%.o: %.c
	$(GCC) $(GCCFLAGS) -c $<

%.o: %.cpp
	$(GXX) $(GCCFLAGS) -c $<
	
%.o: %.S
	$(AS) -c $<

$(EXE): $(OBJS)
	$(LD) $^ -o $@.elf $(LDFLAGS)
	genzehn --input $@.elf --output $@

clean:
	rm -f *.o *.elf *.tns
