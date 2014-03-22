GCC = nspire-gcc
LD = nspire-ld-bflt
GCCFLAGS = -Os -nostdlib -Wall -W -marm
LDFLAGS = -nostdlib
EXE = luaextdemo.luax.tns
LUATNS = runluaextdemo.tns
OBJS = $(patsubst %.c,%.o,$(wildcard *.c))
DISTDIR = .
vpath %.tns $(DISTDIR)

all: $(EXE) $(LUATNS)

%.o: %.c
	$(GCC) $(GCCFLAGS) -c $<

$(EXE): $(OBJS)
	mkdir -p $(DISTDIR)
	$(LD) $(LDFLAGS) $^ -o $(DISTDIR)/$@

$(LUATNS): $(LUATNS:.tns=.lua)
	luna $^ $(DISTDIR)/$@

clean:
	rm -f *.o *.elf
	rm -f $(DISTDIR)/$(EXE) $(DISTDIR)/$(LUATNS)
