DEBUG = FALSE
GCC = nspire-gcc
GXX = nspire-g++
LD-BFLT = nspire-ld-bflt
LD = nspire-ld
OBJCOPY := "$(shell which arm-elf-objcopy 2>/dev/null)"
ifeq (${OBJCOPY},"")
	OBJCOPY := arm-none-eabi-objcopy
endif
GCCFLAGS = -Wall -W -marm
LDFLAGS = 
ifeq ($(DEBUG),FALSE)
	GCCFLAGS += -Os
else
	GCCFLAGS += -O0 -g
	LDFLAGS += --debug
endif
EXE = ndless_tests.test.tns ndless_keys.tns ndless_tpad.tns ndless_tests.luax.tns ndless_luatests.tns ndless_popup_tests.tns ndless_docbrowser_tests.tns ndless_cpp_tests.tns ndless_ngc_tests.tns
DISTDIR = ../../calcbin/tests
vpath %.tns $(DISTDIR)
SUBDIRS = navnet

all: distdir $(EXE) static subdirs

subdirs:
	@for i in $(SUBDIRS); do \
	echo "make all in $$i..."; \
  (cd $$i; make all) || exit 1; done

distdir:
	@mkdir -p $(DISTDIR)

%.o: %.c
	$(GCC) $(GCCFLAGS) -c $<

%.o: %.cpp
	$(GXX) $(GCCFLAGS) -c $<

%.tns: %.lua
	luna $< $(DISTDIR)/$@

%.tns: %.o
	$(LD-BFLT) $(LDFLAGS) $^ -o  $(DISTDIR)/$@

ndless_ngc_tests.tns: ndless_ngc_tests.o assert.o
	$(LD-BFLT) $(LDFLAGS) $^ -o  $(DISTDIR)/$@
ifeq ($(DEBUG),FALSE)
	@rm -f $(DISTDIR)/*.gdb
endif

ndless_cpp_tests.tns: ndless_cpp_tests.o assert.o
	$(LD-BFLT) --cpp $(LDFLAGS) $^ -o  $(DISTDIR)/$@
ifeq ($(DEBUG),FALSE)
	@rm -f $(DISTDIR)/*.gdb
endif

ndless_tests.test.tns: ndless_tests.o assert.o
	$(LD-BFLT) $(LDFLAGS) $^ -o  $(DISTDIR)/$@
ifeq ($(DEBUG),FALSE)
	@rm -f $(DISTDIR)/*.gdb
endif

ndless_tests.luax.tns: ndless_tests.luax.o assert.o
	$(LD-BFLT) $(LDFLAGS) $^ -o  $(DISTDIR)/$@
ifeq ($(DEBUG),FALSE)
	@rm -f $(DISTDIR)/*.gdb
endif

static:
	@cp ReadMe.txt $(DISTDIR)
	@cp ndless.cfg.tns $(DISTDIR)

cleanstatic:
	rm -f $(DISTDIR)/ReadMe.txt $(DISTDIR)/ndless.cfg.tns

clean: cleanstatic
	@for i in $(SUBDIRS); do \
	echo "Clearing in $$i..."; \
	(cd $$i; make clean) || exit 1; done
	rm -f *.o *.elf ${DISTDIR}/*.gdb
	-(cd $(DISTDIR) && rm -f $(EXE))

