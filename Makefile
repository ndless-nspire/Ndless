# Check for submodules
ifneq ($(words $(wildcard ndless-sdk/thirdparty/nspire-io/Makefile) \
               $(wildcard ndless-sdk/thirdparty/zlib/configure) \
               $(wildcard ndless-sdk/thirdparty/freetype2/Makefile)),3)
        $(error Run `git submodule init' and `git submodule update' to checkout the submodules)
endif

SUBDIRS = ndless-sdk ndless

all:
	@for i in $(SUBDIRS); do \
	echo "make all in $$i..."; \
	(cd $$i; make all) || exit 1; done
  
clean:
	@for i in $(SUBDIRS); do \
	echo "Clearing in $$i..."; \
	(cd $$i; make clean) || exit 1; done
