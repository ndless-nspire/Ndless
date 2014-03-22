include ../../Makefile.include

CC=gcc
CFLAGS = -W -Wall
vpath $(VPATH_EXEEXT) ../../Ndless-SDK/ndless/bin

all: init MakeLuaInst$(EXEEXT)

init:
	@mkdir -p ../../Ndless-SDK/ndless/bin

MakeLuaInst$(EXEEXT): MakeLuaInst.c
	$(CC) $(CFLAGS) $< -o ../../Ndless-SDK/ndless/bin/$@

clean:
	 rm -f ../../Ndless-SDK/ndless/bin/MakeLuaInst$(EXEEXT)
