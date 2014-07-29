#include <syscall-list.h>
#include <syscall.h>

#include <lua.h>

typedef void** Gc;

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

Gc gui_gc_global_GC()
{
	return *syscall<e_gui_gc_global_GC_ptr | __SYSCALLS_ISVAR, Gc*>();
}

lua_State* nl_lua_getstate()
{
	return syscall<e_nl_lua_getstate | __SYSCALLS_ISEXT, lua_State*>();
}

extern int _start;

//For backwards-compatibility
int _syscallvar_savedlr;

/* This is only needed for old PRG programs which can't be built anymore with this SDK.
   As the old os.h had an inline function for this, it's not required anymore.

void nl_relocdata(void *ptr, int size)
{
	return syscall<e_nl_relocdatab | __SYSCALLS_ISEXT, void>(ptr, size, &_start);
}*/

int nl_hwsubtype()
{
	return syscall<e_nl_hwsubtype | __SYSCALLS_ISEXT, int>();
}

int nl_loaded_by_3rd_party_loader()
{
	return syscall<e_nl_loaded_by_3rd_party_loader, int>();
}

}
