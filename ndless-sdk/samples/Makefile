SUBDIRS = colors helloworld-sdl helloworld-cpp link-sdl luaext particles ngc newlib newlib-c++ zehn
# freetype depends on the xxd command
LINUX_SUBDIRS = freetype
OS ?= `uname -s`
ifneq ($(OS),Windows_NT)
	SUBDIRS += $(LINUX_SUBDIRS)
endif

all:
	@for i in $(SUBDIRS); do \
	echo "make all in $$i..."; \
  (cd $$i; make all) || exit 1; done

clean:
	@for i in $(SUBDIRS); do \
	echo "Clearing in $$i..."; \
	(cd $$i; make clean) || exit 1; done
