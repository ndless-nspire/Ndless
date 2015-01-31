CC:=gcc
CFLAGS:=-W -Wall -DUSE_FILE32API -Wno-unused-parameter
LDFLAGS:= -lssl -lz -lcrypto
VPATH := minizip-1.1
ifeq ($(USER),root)
	PREFIX ?= /usr/bin
else
	PREFIX ?= ~/bin
endif

BIN := luna$(EXEEXT)

all: $(BIN)

$(BIN): luna.o zip.o ioapi.o
	gcc -o $@ $^ $(LDFLAGS)

install: $(BIN)
	mkdir -p $(PREFIX)
	install $(BIN) $(PREFIX)

dist: clean all
	mkdir -p dist/src
	rm -f *.o
	find . -maxdepth 1 ! -name '$(BIN)' -a ! -name dist -a ! -name . -exec cp -r {} dist/src \;
	cp $(BIN) *.dll *.txt dist

clean:
	rm -rf *.o $(BIN) dist
