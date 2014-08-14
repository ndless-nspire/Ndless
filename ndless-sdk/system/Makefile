# Must be built on host. Must not be built for release.

AS = nspire-as

all: crt0.o crti.o crtn.o
	
%.o: %.S
	$(AS) $(GCCFLAGS) -c $<

clean:
	rm -f *.o
