GCC = nspire-gcc
AR := "$(shell (which arm-elf-ar arm-none-eabi-ar arm-linux-gnueabi-ar | head -1) 2>/dev/null)"
CHOST := $(shell (basename $(AR) | head -c -4))
LIBDIR = ../lib
INCDIR = ../include

ZLIB_A = $(LIBDIR)/libz.a
ZLIB_H = $(INCDIR)/zlib.h $(INCDIR)/zconf.h

FREETYPE_A = $(LIBDIR)/libfreetype.a
FREETYPE_H := \
	$(patsubst freetype2/include/%.h,$(INCDIR)/freetype2/%.h, \
	$(wildcard freetype2/include/*.h) \
	$(wildcard freetype2/include/freetype/*.h) \
	$(wildcard freetype2/include/freetype/config/*.h))
FREETYPE_CFLAGS = -O2 -Wall -Wextra -DFT_CONFIG_OPTION_SYSTEM_ZLIB -c
FREETYPE_CONFIG_MK = freetype2/config.mk

all: zlib $(ZLIB_A) $(ZLIB_H) freetype $(FREETYPE_A) $(FREETYPE_H)

zlib:
	cd zlib && (make libz.a || (CC=$(GCC) CHOST=$(CHOST) ./configure --static && make libz.a))

$(ZLIB_A): zlib/libz.a

$(ZLIB_H): $(INCDIR)/%.h: zlib/%.h

freetype: $(FREETYPE_CONFIG_MK) $(ZLIB_H)
	make -C freetype2 CC=$(GCC) CFLAGS="$(FREETYPE_CFLAGS)" AR=$(AR) SYSTEM_ZLIB=yes library

$(FREETYPE_CONFIG_MK):
	make -C freetype2 CC=$(GCC) setup ansi

$(FREETYPE_A): freetype2/objs/libfreetype.a

$(INCDIR)/freetype2/freetype/config/ftmodule.h: freetype2/objs/ftmodule.h

$(FREETYPE_H): $(INCDIR)/freetype2/%.h: freetype2/include/%.h | $(INCDIR)/freetype2/freetype/config

$(INCDIR)/freetype2/freetype/config:
	mkdir -p $@

$(ZLIB_A) $(ZLIB_H) $(FREETYPE_A) $(FREETYPE_H):
	cp $< $@

clean:
	-make -C zlib clean
	-make -C freetype2 clean
	rm -rf $(ZLIB_A) $(ZLIB_H) $(FREETYPE_A) $(INCDIR)/freetype2

.PHONY: all clean zlib freetype
