UNAME := $(shell uname)
SUBDIRS = EscapeInstaller LuaBin MakeLuaInst MakeHotRebootPatches MakeSyscalls MakeQnAInst XORInstaller

all:
	@for i in $(SUBDIRS); do \
	echo "make all in $$i..."; \
	(cd $$i; make all) || exit 1; done
  
clean:
	@for i in $(SUBDIRS); do \
	echo "Clearing in $$i..."; \
	(cd $$i; make clean) || exit 1; done
	
