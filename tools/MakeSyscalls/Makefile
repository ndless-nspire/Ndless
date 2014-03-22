include ../../Makefile.config

# OS-specific
OS_VERSIONS=ncas-3.6.0 cas-3.6.0 ncascx-3.6.0 cascx-3.6.0

all: idb2idc syscalls syscalls_light

idb2idc:
	(cd $(IDC_FILES_DIR) && ./idb2idc.sh)

syscalls:
	./mksyscalls.sh $(IDC_FILES_DIR) ../../Ndless-SDK/ndless/include/syscalls.h $(OS_VERSIONS)

syscalls_light:
	./mksyscalls.sh $(IDC_FILES_DIR) ../../Ndless-SDK/ndless/include/syscalls-light.h $(OS_VERSIONS)

clean:
