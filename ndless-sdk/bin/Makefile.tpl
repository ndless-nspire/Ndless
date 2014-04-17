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
CPPOBJS = $(patsubst %.cpp,%.o,$(wildcard *.cpp))
COBJS = $(patsubst %.c,%.o,$(wildcard *.c)) 
ASMOBJS = $(patsubst %.S,%.o,$(wildcard *.S))
OBJS = $(CPPOBJS) $(COBJS) $(ASMOBJS)
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
