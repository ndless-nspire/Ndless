UNAME := $(shell uname)
SUBDIRS = EscapeInstaller LuaBin MakeLuaInst MakeHotRebootPatches MakeSyscalls MakeQnAInst XORInstaller MakeChunkDispatch

all: $(patsubst %, build-%, $(SUBDIRS))
clean: $(patsubst %, clean-%, $(SUBDIRS))

.PHONY: all clean

build-%: %
	+$(MAKE) -C $<

clean-%: %
	+$(MAKE) -C $< clean
