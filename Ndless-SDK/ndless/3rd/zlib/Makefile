# To compile for TI-Nspire, replace the top-level Makefile in the zlib source
# with this one and run `make'.

CC = nspire-gcc
AR = arm-none-eabi-ar
CFLAGS = -marm -Os -DHAVE_HIDDEN

LIB = libz.a
OBJS = $(patsubst %.c,%.o,$(wildcard *.c))

all: $(LIB)

$(LIB): $(OBJS)
	$(AR) rcs $(LIB) $^

clean:
	rm -f $(OBJS) $(LIB)

.PHONY: all clean
