include ../../../Makefile.config

all: syscalls

syscalls:
	php ./mkSyscalls.php $(IDC_FILES_DIR) ../../include/syscall-addrs.h

clean:
	rm -f ../../../ndless-sdk/include/syscall-addrs.h
