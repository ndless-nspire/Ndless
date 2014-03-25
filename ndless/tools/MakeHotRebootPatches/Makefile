include ../../../Makefile.include

CC=gcc
CFLAGS = -W -Wall

all: MakeHotRebootPtch$(EXEEXT)

MakeHotRebootPatch$(EXEEXT): main.c
	$(CC) $(CFLAGS) $< -o $@

clean:
	 rm -f MakeHotRebootPtch$(EXEEXT)
