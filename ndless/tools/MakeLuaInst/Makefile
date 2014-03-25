include ../../../Makefile.include

CC=gcc
CFLAGS = -W -Wall

all: MakeLuaInst$(EXEEXT)

MakeLuaInst$(EXEEXT): MakeLuaInst.c
	$(CC) $(CFLAGS) $< -o $@

clean:
	 rm -f MakeLuaInst$(EXEEXT)
