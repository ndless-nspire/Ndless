SUBDIRS = luna _samples
WIN_SUBDIRS = nspire_emu ndless_pc/lib cmd_tools/navnetcmd

OS ?= `uname -s`
ifeq ($(OS),Windows_NT)
	SUBDIRS += $(WIN_SUBDIRS)
endif

all:
	@for i in $(SUBDIRS); do \
	echo "make all in $$i..."; \
	(cd $$i; make all) || exit 1; done
  
clean:
	@for i in $(SUBDIRS); do \
	echo "Clearing in $$i..."; \
	(cd $$i; make clean) || exit 1; done
