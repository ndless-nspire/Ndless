AS := nspire-as
GCC := nspire-gcc
LD := "$(shell (which arm-elf-gcc arm-none-eabi-gcc arm-linux-gnueabi-gcc | head -1) 2>/dev/null)"
OBJCOPY := "$(shell (which arm-elf-objcopy arm-none-eabi-objcopy arm-linux-gnueabi-objcopy | head -1) 2>/dev/null)"

GCCFLAGS := -Os -Wall -W -Wno-strict-aliasing -fpic
LDFLAGS := -Tldscript -nostartfiles -L../../../ndless-sdk/lib -nostdlib
DISTDIR := ../../calcbin
vpath %.tns $(DISTDIR)

all: ndless_resources_3.6.tns

%.o: %.c
	$(GCC) $(GCCFLAGS) -c $<

%.o: %.S
	$(AS) $(GCCFLAGS) -c $<

%.elf: %.o
	$(LD) $(LDFLAGS) $^ -o $@

RES_OBJS := install.o ploaderhook.o bflt.o ints.o syscalls.o utils.o emu.o luaext.o

ndless_resources_3.6.tns: $(RES_OBJS) crt0.o
	@mkdir -p $(DISTDIR)
	$(LD) $(LDFLAGS) $(RES_OBJS) -o ndless_resources.elf
	$(OBJCOPY) -O binary ndless_resources.elf $(DISTDIR)/$@

subdirs:
	@for i in $(SUBDIRS); do \
	echo "make all in $$i..."; \
  (cd $$i; make all) || exit 1; done

clean:
	rm -rf ndless_resources.elf ndless_resources_3.6.tns $(RES_OBJS)

cleansubdirs:
	@for i in $(SUBDIRS); do \
	echo "make all in $$i..."; \
  (cd $$i; make clean) || exit 1; done
