SUBDIRS = tools resources installer-3.6 installer-3.9 downgrade-3.9 installer-4.0 installer-4.2

all: $(patsubst %, build-%, $(SUBDIRS))
clean: $(patsubst %, clean-%, $(SUBDIRS))

.PHONY: all clean

build-tools: tools
	+$(MAKE) -C $<

build-%: % build-tools
	+$(MAKE) -C $<

clean-%: %
	+$(MAKE) -C $< clean
