include ../../../Makefile.include

CC=gcc
CFLAGS = -W -Wall

all: EscapeInst$(EXEEXT)

EscapeInst$(EXEEXT): EscapeInstaller.c
	$(CC) $(CFLAGS) $< -o $@

clean:
	 rm -f EscapeInst$(EXEEXT)
