UNAME := $(shell uname)
SUBDIRS = EscapeInstaller MakeLuaInst

all:
ifneq ($(findstring CYGWIN,$(UNAME)),)
	@echo Error: Building with Cygwin creates dependencies to cygwin1.dll. Use MSYS.
	@false
endif

	@for i in $(SUBDIRS); do \
	echo "make all in $$i..."; \
	(cd $$i; make all) || exit 1; done
  
clean:
	@for i in $(SUBDIRS); do \
	echo "Clearing in $$i..."; \
	(cd $$i; make clean) || exit 1; done
	