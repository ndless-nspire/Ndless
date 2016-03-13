SUBDIRS = src

all: $(patsubst %, build-%, $(SUBDIRS))
clean: $(patsubst %, clean-%, $(SUBDIRS))

.PHONY: all clean

build-%: %
	+$(MAKE) -C $<

clean-%: %
	+$(MAKE) -C $< clean
