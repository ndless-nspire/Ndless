include ../../../Makefile.config

# OS-specific
OS_VERSIONS=ncas-3.6.0 cas-3.6.0 ncascx-3.6.0 cascx-3.6.0

all: idb2idc syscalls

idb2idc:
	(cd $(IDC_FILES_DIR) && ./idb2idc.sh)

syscalls:
	./mksyscalls.sh $(IDC_FILES_DIR) ../../ndless/include/syscalls.h $(OS_VERSIONS)

clean:
