all: syscalls

.PHONY: syscalls clean

syscalls:
	php ./mkSyscalls.php idc ../../../../ndless-sdk/include/syscall-addrs.h

clean:
	rm -f ../../../../ndless-sdk/include/syscall-addrs.h
