SUBDIRS = tools resources installer-3.6 installer-3.9 downgrade-3.9 installer-4.0 installer-4.2 installer-4.4 installer-3.9-classic-new

all: $(patsubst %, build-%, $(SUBDIRS))
clean: $(patsubst %, clean-%, $(SUBDIRS))

.PHONY: all clean

build-tools: tools
	$(MAKE) -C $<

build-%: % build-tools
	$(MAKE) -C $<

clean-%: %
	$(MAKE) -C $< clean
