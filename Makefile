# Check for submodules
ifneq ($(words $(wildcard ndless-sdk/thirdparty/nspire-io/Makefile) \
               $(wildcard ndless-sdk/thirdparty/zlib/configure) \
               $(wildcard ndless-sdk/tools/luna/Makefile) \
               $(wildcard ndless-sdk/thirdparty/freetype2/Makefile)),4)
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

dist: all
	rm -rf dist
	mkdir -p dist/ndless/samples
	cp Mozilla-Public-License-v1.1.html README.md dist/ndless/
	cp ndless/calcbin/* dist/ndless/
	rm dist/ndless/downgradefix_3.9*.tns dist/ndless/ndless_installer_3.9.0_classic.tns
	cp ndless-sdk/samples/*/*.tns dist/ndless/samples/
	rm dist/ndless/samples/freetype_demo.tns
	cd dist && 7z a ndless.zip ndless
