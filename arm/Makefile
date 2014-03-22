SUBDIRS := tests
AS := nspire-as
GCC := nspire-gcc
GCCFLAGS := -Os -Wall -W -Wno-strict-aliasing
GCCFLAGS_INIT := $(GCCFLAGS)
LD := nspire-ld
LDFLAGS := 
OBJCOPY := "$(shell (which arm-elf-objcopy arm-none-eabi-objcopy arm-linux-gnueabi-objcopy | head -1) 2>/dev/null)"
DISTDIR := ../calcbin
vpath %.tns $(DISTDIR)

.DEFAULT_GOAL := all

all: ndless_installer.tns static ndless_resources_3.6.tns subdirs
res: ndless_resources_3.6.tns

%.o: %.c
	$(GCC) $(GCCFLAGS) -c $<

%.o: %.S
	$(AS) $(GCCFLAGS) -c $<

%.elf: %.o
	$(LD) $(LDFLAGS) $^ -o $@

static:
	@mkdir -p $(DISTDIR)
	@cp ndless.cfg.tns $(DISTDIR)

OS_VERSIONS="3.6.0"
MODELS="ncas cas ncascx cascx cmc cascmc"

# Build with the light and stage1 switches (temporarily added to $GCCFLAGS)
# Thumb mode is actually not used anymore in this version of Ndless, because the installer is not size-constrainted
ints_light_thumb.o: ints.c
	$(GCC) $(GCCFLAGS) -c $< -o $@
syscalls_light_thumb.o: syscalls.c
	$(GCC) $(GCCFLAGS) -c $< -o $@
utils_light_thumb.o: utils.c
	$(GCC) $(GCCFLAGS) -c $< -o $@
# Build some libndls functions used by stage1 that depends on syscalls (the SWI number is different in light mode)
file_each_light_thumb.o: ../libndls/file_each.c
	$(GCC) $(GCCFLAGS) -c $< -o $@
locate_light_thumb.o: ../libndls/locate.c
	$(GCC) $(GCCFLAGS) -c $< -o $@

# Explicit dependencies strangely required for the target to avoid being rebuilt when not really needed
stage0.o: stage0.S
stage1.o: stage1.c

# Required for $$*. Caution, applies to all the following targets.
.SECONDEXPANSION:

ndless_installer.elf: GCCFLAGS+= -D _NDLS_LIGHT -D STAGE1

SYSCALLS_OBJS_LIGHT:=syscalls-light_ncas-3.6.0.o syscalls-light_cas-3.6.0.o syscalls-light_ncascx-3.6.0.o syscalls-light_cascx-3.6.0.o
SYSCALLS_OBJS:=syscalls_ncas-3.6.0.o syscalls_cas-3.6.0.o syscalls_ncascx-3.6.0.o syscalls_cascx-3.6.0.o

ndless_installer.elf: stage1.o ints_light_thumb.o syscalls_light_thumb.o utils_light_thumb.o locate_light_thumb.o file_each_light_thumb.o $(SYSCALLS_OBJS_LIGHT)
	$(LD) --light-startup-no-header $(LDFLAGS) $^ -o $@

ndless_installer.bin: ndless_installer.elf
	$(OBJCOPY) -O binary $< $@

stage0.bin: stage0.o
	$(OBJCOPY) -O binary $< $@

ndless_installer.lua: ndless_installer.tpl.lua
ndless_installer.lua: ndless_installer.bin stage0.bin
	EscapeInst $< $(<:.bin=-escaped.bin)
	cat stage0.bin $(<:.bin=-escaped.bin) > $(<:.bin=-escaped.bin.tmp)
	mv $(<:.bin=-escaped.bin.tmp) $(<:.bin=-escaped.bin)
	MakeLuaInst $(<:.bin=-escaped.bin) $(<:.bin=-escaped.lua.tmp)
	@# skip the UTF-8 BOM marker
	tail --bytes=+4 ndless_installer.tpl.lua > ndless_installer.tpl.nobom.lua.tmp
	cat ndless_version.lua ndless_installer.tpl.nobom.lua.tmp $(<:.bin=-escaped.lua.tmp) > $@
	rm $(<:.bin=-escaped.lua.tmp) $(<:.bin=-escaped.bin) ndless_installer.tpl.nobom.lua.tmp

ndless_installer.tns: ndless_installer.lua
	@mkdir -p $(DISTDIR)
	luna $< $(DISTDIR)/$@

CORE_OBJS := install.o ploaderhook.o bflt.o ints.o syscalls.o utils.o emu.o luaext.o $(SYSCALLS_OBJS)
RES_OBJS := $(CORE_OBJS)

ndless_core.elf: $(CORE_OBJS)
	$(LD) --light-startup $(LDFLAGS) $^ -o $@

ndless_resources_3.6.tns: ndless_core.elf
	@mkdir -p $(DISTDIR)
	$(OBJCOPY) -O binary $< $(DISTDIR)/$@

subdirs:
	@for i in $(SUBDIRS); do \
	echo "make all in $$i..."; \
  (cd $$i; make all) || exit 1; done

clean: cleanbin cleanapp cleansubdirs
cleanapp:
	rm -rf $(DISTDIR)/ndless_installer.tns $(DISTDIR)/ndless_resources_3.6.tns $(DISTDIR)/ndless.cfg.tns
cleaninst:
	rm -rf ndless_installer.elf $(INST_OBJS)
cleanres:
	rm -rf ndless_core.elf $(RES_OBJS)

cleanbin:
	rm -rf *.o *.elf stage0.bin ndless_installer.bin ndless_installer.lua *.tmp

cleansubdirs:
	@for i in $(SUBDIRS); do \
	echo "make all in $$i..."; \
  (cd $$i; make clean) || exit 1; done
