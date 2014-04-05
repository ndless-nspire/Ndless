#include <syscall-list.h>
#include <syscall.h>

extern "C" {

unsigned char *keypad_type()
{
	return syscall<e_keypad_type | __SYSCALLS_ISVAR, unsigned char*>();
}

void *calc_cmd()
{
	return syscall<e_calc_cmd | __SYSCALLS_ISVAR, void*>();
}

int nl_ndless_rev()
{
	return syscall<e_nl_ndless_rev | __SYSCALLS_ISEXT, int>();
}

int nl_hwtype()
{
	return syscall<e_nl_hwtype | __SYSCALLS_ISEXT, int>();
}

int luaL_error()
{
	return syscall<e_luaL_error | __SYSCALLS_ISVAR, int>();
}

extern int _start;

void nl_relocdata(void *ptr, int size)
{
	return syscall<e_nl_relocdatab | __SYSCALLS_ISEXT, void>(ptr, size, &_start);
}

int nl_loaded_by_3rd_party_loader()
{
	return syscall<e_nl_loaded_by_3rd_party_loader, int>();
}

}
