include ../../Makefile.include

CC=gcc
CFLAGS = -W -Wall
vpath $(VPATH_EXEEXT) ../../Ndless-SDK/ndless/bin

all: init MakeHotRebootPtch$(EXEEXT)

init:
	@mkdir -p ../../Ndless-SDK/ndless/bin

MakeHotRebootPtch$(EXEEXT): main.c
	$(CC) $(CFLAGS) $< -o ../../Ndless-SDK/ndless/bin/$@

clean:
	 rm -f ../../Ndless-SDK/ndless/bin/MakeHotRebootPtch$(EXEEXT)
