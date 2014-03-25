CC = gcc
CFLAGS = -Wall -W
LDFLAGS = -lnavnet
EXE = navnetcmd.exe
DISTDIR = .
vpath %.exe $(DISTDIR)
OS ?= `uname -s`

ifeq ($(OS),Windows_NT)
all: $(EXE)

navnetcmd.o: navnetcmd.c
	$(CC) $(CFLAGS) -c $< -o $@

$(EXE): navnetcmd.o
	mkdir -p $(DISTDIR)
	$(CC) $^ -o $(DISTDIR)/$@ $(LDFLAGS)

clean:
	rm -f *.o $(DISTDIR)/$(EXE) 

# OS
else
all:
clean:
endif
