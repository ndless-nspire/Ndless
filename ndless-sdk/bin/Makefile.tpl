DEBUG = FALSE
GCC = nspire-gcc
AS = nspire-as
GXX=nspire-g++
LD = nspire-ld
GCCFLAGS = -Wall -W -marm
LDFLAGS =
ifeq ($(DEBUG),FALSE)
	GCCFLAGS += -Os
else
	GCCFLAGS += -O0 -g
	LDFLAGS += --debug
endif
OBJS = $(patsubst %.c, %.o, $(shell find . -name \*.c))
OBJS += $(patsubst %.cpp, %.o, $(shell find . -name \*.cpp))
OBJS += $(patsubst %.S, %.o, $(shell find . -name \*.S))
EXE = @@EXENAME@@.tns
DISTDIR = .
vpath %.tns $(DISTDIR)

all: $(EXE)

%.o: %.c
	$(GCC) $(GCCFLAGS) -c $<

%.o: %.cpp
	$(GXX) $(GCCFLAGS) -c $<
	
%.o: %.S
	$(AS) -c $<

$(EXE): $(OBJS)
	mkdir -p $(DISTDIR)
	$(LD) $^ -o $(DISTDIR)/$@ $(LDFLAGS)
ifeq ($(DEBUG),FALSE)
	@rm -f $(DISTDIR)/*.gdb
endif

clean:
	rm -f *.o *.elf $(DISTDIR)/*.gdb $(DISTDIR)/$(EXE)
