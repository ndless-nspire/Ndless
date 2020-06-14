GCC = nspire-gcc
AR := "$(shell (which arm-elf-ar arm-none-eabi-ar arm-linux-gnueabi-ar | head -1) 2>/dev/null)"
CHOST := $(shell (echo $(shell basename $(AR)) | sed 's/-ar$$//'))
LIBDIR = ../lib
INCDIR = ../include

NSPIREIO_A = $(LIBDIR)/libnspireio.a
NSPIREIO_H = $(INCDIR)/nspireio2.h \
	$(patsubst nspire-io/include/nspireio/%, $(INCDIR)/nspireio/%, $(wildcard nspire-io/include/nspireio/*))

ZLIB_A = $(LIBDIR)/libz.a
ZLIB_H = $(INCDIR)/zlib.h $(INCDIR)/zconf.h
ZLIB_CFLAGS = -O3 -c

FREETYPE_A = $(LIBDIR)/libfreetype.a
FREETYPE_H := \
	$(patsubst freetype2/include/%.h,$(INCDIR)/freetype2/%.h, \
	$(wildcard freetype2/include/*.h) \
	$(wildcard freetype2/include/freetype/*.h) \
	$(wildcard freetype2/include/freetype/config/*.h))
FREETYPE_CFLAGS = -O2 -Wall -Wextra -DFT_CONFIG_OPTION_SYSTEM_ZLIB
FREETYPE_CONFIG_MK = freetype2/config.mk

all: nspireio zlib freetype

nspireio:
	$(MAKE) -C nspire-io lib
	$(MAKE) $(NSPIREIO_A) $(NSPIREIO_H)

$(NSPIREIO_A): nspire-io/lib/libnspireio.a

$(NSPIREIO_H): $(INCDIR)/%: nspire-io/include/% | $(INCDIR)/nspireio

zlib:
	cd zlib && ($(MAKE) libz.a || (CC=$(GCC) CHOST=$(CHOST) CFLAGS="$(ZLIB_CFLAGS)" ./configure --static && $(MAKE) libz.a))
	$(MAKE) $(ZLIB_A) $(ZLIB_H)

$(ZLIB_A): zlib/libz.a

$(ZLIB_H): $(INCDIR)/%.h: zlib/%.h

freetype: $(FREETYPE_CONFIG_MK) zlib
	$(MAKE) -C freetype2 CC=$(GCC) ANSIFLAGS="$(FREETYPE_CFLAGS)" AR=$(AR) SYSTEM_ZLIB=yes library
	$(MAKE) $(FREETYPE_A) $(FREETYPE_H)

$(FREETYPE_CONFIG_MK):
	$(MAKE) -C freetype2 CC=$(GCC) setup ansi

$(FREETYPE_A): freetype2/objs/libfreetype.a

$(INCDIR)/freetype2/freetype/config/ftmodule.h: freetype2/objs/ftmodule.h

$(FREETYPE_H): $(INCDIR)/freetype2/%.h: freetype2/include/%.h | $(INCDIR)/freetype2/freetype/config

%:
	mkdir -p $@

$(NSPIREIO_A) $(NSPIREIO_H) $(ZLIB_A) $(ZLIB_H) $(FREETYPE_A) $(FREETYPE_H):
	cp $< $@

clean:
	-$(MAKE) -C nspire-io clean
	rm -f zlib/libz.a # zlib's Makefile in git (before configure) has no clean target
	-$(MAKE) -C zlib clean
	-$(MAKE) -C freetype2 clean
	rm -rf $(NSPIREIO_A) $(INCDIR)/nspireio2.h $(INCDIR)/nspireio $(ZLIB_A) $(ZLIB_H) $(FREETYPE_A) $(INCDIR)/freetype2

.PHONY: all clean nspireio zlib freetype
