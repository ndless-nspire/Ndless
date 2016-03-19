# Check for submodules
ifneq ($(words $(wildcard ndless-sdk/thirdparty/nspire-io/Makefile) \
               $(wildcard ndless-sdk/thirdparty/zlib/configure) \
               $(wildcard ndless-sdk/thirdparty/freetype2/Makefile)),3)
        $(error Run `git submodule init' and `git submodule update' to checkout the submodules)
endif

SUBDIRS = ndless-sdk ndless

all: $(patsubst %, build-%, $(SUBDIRS))
clean: $(patsubst %, clean-%, $(SUBDIRS))

build-ndless: build-ndless-sdk

.PHONY: all clean

build-%: %
	$(MAKE) -C $<

clean-%: %
	$(MAKE) -C $< clean
