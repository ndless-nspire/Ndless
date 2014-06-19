DEBUG = FALSE
GCC = nspire-zehn-gcc
GXX = nspire-zehn-g++
LD = nspire-zehn-ld

GCCFLAGS = -Wall -Wextra -marm -fno-rtti

CPPOBJS = $(patsubst %.cpp,%.o,$(wildcard *.cpp))
COBJS = $(patsubst %.c,%.o,$(wildcard *.c)) 
OBJS = $(CPPOBJS) $(COBJS)

EXE = zehn.tns

all: $(EXE)

%.o: %.c
	$(GCC) $(GCCFLAGS) -c $<

%.o: %.cpp
	$(GXX) $(GCCFLAGS) -c $<
	
$(EXE): $(OBJS)
	$(LD) $^ -o $(EXE).elf
	genzehn --input $(EXE).elf --output $(EXE) --name "Test" --author "Author" --notice "This is an arbitrarily long text" --ndless-max 31

clean:
	rm -f *.o $(EXE) $(EXE).elf
