CC:=gcc
CFLAGS:=-W -Wall -m32
LDFLAGS:= -lssl -lz -m32
VPATH := minizip-1.1

OS ?= `uname -s`
ifeq ($(OS),Windows_NT)
  EXEEXT = .exe
else
	CFLAGS := $(CFLAGS) -DUSE_FILE32API
	LDFLAGS:= $(LDFLAGS) -lcrypto
endif

all: luna$(EXEEXT)

luna$(EXEEXT): luna.o zip.o ioapi.o
	gcc -o $@ $^ $(LDFLAGS)

dist: clean all
	mkdir -p dist/src
	rm -f *.o
	find . -maxdepth 1 ! -name 'luna$(EXEEXT)' -a ! -name dist -a ! -name . -exec cp -r {} dist/src \;
	cp luna$(EXEEXT) *.dll *.txt dist

clean:
	rm -rf *.o luna$(EXEEXT) dist
