# Must be built on host. Must not be built for release.

AS = nspire-as
GCC = nspire-gcc
GXX = nspire-g++
GCCFLAGS = -Os

all: crt0.o crt0light.o crt0lightnoheader.o crt0lightnoheader_thumbentry.o crt0-bflt.o crt0-cpp.o crt0-bflt-cpp.o crtn.o crti.o crt0sym.o cppstub.o for-newlib

%.o: %.c
	$(GCC) $(GCCFLAGS) -c $<

%.o: %.cpp
	$(GXX) $(GCCFLAGS) -c $<
	
%.o: %.S
	$(AS) $(GCCFLAGS) -c $<

crt0light.o: crt0.S
	$(AS) $(GCCFLAGS) -D _NDLS_LIGHT -c $< -o $@

crt0lightnoheader.o: crt0.S
	$(AS) $(GCCFLAGS) -D _NDLS_LIGHT -D NO_PRGM_HEADER -c $< -o $@

crt0lightnoheader_thumbentry.o: crt0.S
	$(AS) $(GCCFLAGS) -D _NDLS_LIGHT -D NO_PRGM_HEADER -D THUMB_ENTRYPOINT -c $< -o $@

crt0-cpp.o: crt0.S
	$(AS) $(GCCFLAGS) -D CRT0_CPP -c $< -o $@

crt0-bflt-cpp.o: crt0-bflt.S
	$(AS) $(GCCFLAGS) -D CRT0_CPP -c $< -o $@

.PHONY: for-newlib

for-newlib:
	cd for-newlib && make

clean:
	rm -f *.o
	cd for-newlib && make clean

