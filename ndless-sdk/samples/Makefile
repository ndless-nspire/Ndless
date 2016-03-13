SUBDIRS = colors helloworld-sdl helloworld-cpp link-sdl luaext particles ngc newlib newlib-c++ zehn
# freetype depends on the xxd command
LINUX_SUBDIRS = freetype
OS ?= `uname -s`
ifneq ($(OS),Windows_NT)
	SUBDIRS += $(LINUX_SUBDIRS)
endif

all: $(patsubst %, build-%, $(SUBDIRS))
clean: $(patsubst %, clean-%, $(SUBDIRS))

.PHONY: all clean

build-%: %
	+$(MAKE) -C $<

clean-%: %
	+$(MAKE) -C $< clean
