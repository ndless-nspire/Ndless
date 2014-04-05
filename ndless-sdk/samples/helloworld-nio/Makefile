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
EXE = helloworld.tns
OBJS = $(patsubst %.c,%.o,$(wildcard *.c))
DISTDIR = .
vpath %.tns $(DISTDIR)

all: $(EXE)

%.o: %.c
	$(GCC) $(GCCFLAGS) -c $<

$(EXE): $(OBJS)
	mkdir -p $(DISTDIR)
	$(LD) $(LDFLAGS) $^ -o $(DISTDIR)/$@

clean:
	rm -f *.o *.elf *.gdb
	rm -f $(DISTDIR)/$(EXE)
