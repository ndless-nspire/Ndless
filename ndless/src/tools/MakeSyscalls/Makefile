ADDRFILE := ../../../../ndless-sdk/include/syscall-addrs.h
IDCFOLDER := idc

all: $(ADDRFILE)

.PHONY: clean

$(ADDRFILE): mkSyscalls.php $(shell find "$(IDCFOLDER)" -name \*.idc)
	php ./mkSyscalls.php "$(IDCFOLDER)" "$@"

clean:
	rm -f ../../../../ndless-sdk/include/syscall-addrs.h
