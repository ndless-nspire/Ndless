CC:=gcc
CFLAGS:=-W -Wall
LDFLAGS:= -lssl -lz
DISTDIR := ../ndless/bin
VPATH := minizip-1.1 $(DISTDIR)

OS ?= `uname -s`
ifeq ($(OS),Windows_NT)
  EXEEXT = .exe
else
	CFLAGS := $(CFLAGS)
	LDFLAGS:= $(LDFLAGS) -lcrypto
endif

all: luna$(EXEEXT)

luna$(EXEEXT): luna.o zip.o ioapi.o
	gcc -o $(DISTDIR)/$@ $^ $(LDFLAGS)

dist: clean all
	mkdir -p dist/src
	rm -f *.o
	find . -maxdepth 1 ! -name 'luna$(EXEEXT)' -a ! -name dist -a ! -name . -exec cp -r {} dist/src \;
	cp luna$(EXEEXT) *.dll *.txt dist

clean:
	rm -rf *.o $(DISTDIR)/luna$(EXEEXT) dist

