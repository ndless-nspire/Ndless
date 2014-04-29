DEBUG = FALSE
GCC = nspire-gcc
AS = nspire-as
LD = nspire-ld-bflt
GCCFLAGS = -Wall -W -marm
LDFLAGS =
ifeq ($(DEBUG),FALSE)
	GCCFLAGS += -Os
else
	GCCFLAGS += -O0 -g
endif
OBJS = freetype_demo.o
EXE = freetype_demo.tns
DISTDIR = .
vpath %.tns $(DISTDIR)

all: $(EXE)

gen_font_droid.h: droid/DroidSans.ttf
	xxd -i $< > $@

freetype_demo.o: freetype_demo.c gen_font_droid.h
	$(GCC) $(GCCFLAGS) -c $<

$(EXE): $(OBJS)
	mkdir -p $(DISTDIR)
	$(LD) $^ -o $(DISTDIR)/$@ $(LDFLAGS)
ifeq ($(DEBUG),FALSE)
	@rm -f $(DISTDIR)/$(EXE).gdb
endif

clean:
	rm -f gen_font_droid.h $(OBJS) $(DISTDIR)/$(EXE) $(DISTDIR)/$(EXE).gdb
