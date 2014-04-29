# To compile for TI-Nspire, replace the top-level Makefile in the FreeType source
# with this one and run `make'.

CC = nspire-gcc
AR = arm-none-eabi-ar
CFLAGS = -pedantic -ansi -marm -Wall -Os -I include -I include/config -DFT_CONFIG_OPTION_SYSTEM_ZLIB "-DFT_CONFIG_CONFIG_H=<ftconfig.h>" -DFT2_BUILD_LIBRARY "-DFT_CONFIG_MODULES_H=<ftmodule.h>"

LIB = libfreetype.a

SRC = autofit/autofit.c \
      bdf/bdf.c \
      cff/cff.c \
      base/ftbase.c \
      base/ftbbox.c \
      base/ftbdf.c \
      base/ftbitmap.c \
      bzip2/ftbzip2.c \
      cache/ftcache.c \
      base/ftcid.c \
      base/ftdebug.c \
      base/ftfstype.c \
      base/ftgasp.c \
      base/ftglyph.c \
      base/ftgxval.c \
      gzip/ftgzip.c \
      base/ftinit.c \
      base/ftlcdfil.c \
      lzw/ftlzw.c \
      base/ftmm.c \
      base/ftotval.c \
      base/ftpatent.c \
      base/ftpfr.c \
      base/ftstroke.c \
      base/ftsynth.c \
      base/ftsystem.c \
      base/fttype1.c \
      base/ftwinfnt.c \
      base/ftxf86.c \
      pcf/pcf.c \
      pfr/pfr.c \
      psaux/psaux.c \
      pshinter/pshinter.c \
      psnames/psnames.c \
      raster/raster.c \
      sfnt/sfnt.c \
      smooth/smooth.c \
      truetype/truetype.c \
      cid/type1cid.c \
      type1/type1.c \
      type42/type42.c \
      winfonts/winfnt.c \

OBJS = $(foreach file,$(SRC),objs/$(basename $(notdir $(file))).o)

all: $(LIB)

$(LIB): $(OBJS)
	$(AR) rcs $(LIB) $^

objs/%.o: src/autofit/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

objs/%.o: src/base/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

objs/%.o: src/bdf/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

objs/%.o: src/bzip2/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

objs/%.o: src/cache/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

objs/%.o: src/cff/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

objs/%.o: src/cid/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

objs/%.o: src/gzip/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

objs/%.o: src/lzw/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

objs/%.o: src/pcf/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

objs/%.o: src/pfr/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

objs/%.o: src/psaux/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

objs/%.o: src/pshinter/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

objs/%.o: src/psnames/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

objs/%.o: src/raster/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

objs/%.o: src/sfnt/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

objs/%.o: src/smooth/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

objs/%.o: src/truetype/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

objs/%.o: src/type1/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

objs/%.o: src/type42/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

objs/%.o: src/winfonts/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f $(OBJS) $(LIB)

.PHONY: all clean
