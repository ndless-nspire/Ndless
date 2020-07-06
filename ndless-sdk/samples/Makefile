SUBDIRS = colors helloworld-sdl helloworld-cpp link-sdl luaext particles ngc newlib newlib-c++ zehn
# freetype depends on the xxd command
ifneq (, $(shell which xxd 2>/dev/null))
	SUBDIRS += freetype
endif

all: $(patsubst %, build-%, $(SUBDIRS))
clean: $(patsubst %, clean-%, $(SUBDIRS))

.PHONY: all clean

build-%: %
	+$(MAKE) -C $<

clean-%: %
	+$(MAKE) -C $< clean
