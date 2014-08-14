DEBUG = FALSE

GCC = nspire-gcc
AS  = nspire-as
GXX = nspire-g++
LD  = nspire-ld
GENZEHN = genzehn
LUNA = ../../tools/luna/luna

GCCFLAGS = -Wall -W -marm
LDFLAGS =
ZEHNFLAGS = --name "luaextdemo.luax"

ifeq ($(DEBUG),FALSE)
	GCCFLAGS += -Os
else
	GCCFLAGS += -O0 -g
endif

OBJS = $(patsubst %.c, %.o, $(shell find . -name \*.c))
OBJS += $(patsubst %.cpp, %.o, $(shell find . -name \*.cpp))
OBJS += $(patsubst %.S, %.o, $(shell find . -name \*.S))
EXE = luaextdemo.luax.tns
DISTDIR = .
vpath %.tns $(DISTDIR)
vpath %.tns.elf $(DISTDIR)

all: $(EXE) runluaextdemo.tns

runluaextdemo.tns: runluaextdemo.lua
	$(LUNA) $< $@

%.o: %.c
	$(GCC) $(GCCFLAGS) -c $<

%.o: %.cpp
	$(GXX) $(GCCFLAGS) -c $<
	
%.o: %.S
	$(AS) -c $<

$(EXE).elf: $(OBJS)
	mkdir -p $(DISTDIR)
	$(LD) $^ -o $(DISTDIR)/$@ $(LDFLAGS)

$(EXE): $(EXE).elf
	$(GENZEHN) --input $(DISTDIR)/$^ --output $(DISTDIR)/$@ $(ZEHNFLAGS)

clean:
	rm -f *.o $(DISTDIR)/$(EXE) $(DISTDIR)/$(EXE).elf runluaextdemo.tns
