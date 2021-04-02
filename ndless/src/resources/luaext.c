/****************************************************************************
 * Lua extensions support
 *
 * The contents of this file are subject to the Mozilla Public
 * License Version 1.1 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 *
 * The Original Code is Ndless code.
 *
 * The Initial Developer of the Original Code is Olivier ARMAND
 * <olivier.calc@gmail.com>.
 * Portions created by the Initial Developer are Copyright (C) 2012-2014
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s): 
 ****************************************************************************/

#include "ndless.h"
#include <lauxlib.h>

// array of modules's memory blocks
#define LUAEXT_MAX_MODULES 30
static void *loaded[LUAEXT_MAX_MODULES];
static unsigned loaded_next_index = 0;


static int require_file_each_cb(const char *path, void *context) {
	if (strcmp(strrchr(path, '/') + 1, (char*)context) || ld_exec(path, loaded + loaded_next_index))
		return 0;
 	loaded_next_index++; // found and loaded
	return 1;
}

static int require(lua_State *L) {
	char modulepath[FILENAME_MAX];
	const char *name = luaL_checkstring(L, 1);
	if (strlen(name) >= 30) goto require_not_found;
	if (loaded_next_index >= LUAEXT_MAX_MODULES) {
		luaL_error(L, "cannot load module " LUA_QS ": too many modules loaded", name);
		return 1;
	}
	sprintf(modulepath, "%s.luax.tns", name);
	if (!file_each(get_documents_dir(), require_file_each_cb, modulepath)) {
require_not_found:
		luaL_error(L, "module " LUA_QS " not found", name);
		return 1;
	}
  return 1;
}

static int ndless_uninstall(__attribute__((unused)) lua_State *L) {
	ins_uninstall();
	return 1;
}

static const luaL_reg baselib[] = {
	{"nrequire", require},
	{NULL, NULL}
};

static const luaL_reg ndlesslib[] = {
	{"uninst", ndless_uninstall},
	{NULL, NULL}
};

// At the end of luaL_openlibs
// OS-specific
static unsigned const interp_startup_addrs[NDLESS_MAX_OSID+1] =
					       {0x101003CC, 0x101009F0, 0x100FFEE0, 0x1010052C, 0x100FC700, 0x100FCD4C,
						0x10125F30, 0x10126558, 0x10125974, 0x10125FCC,
						0x1012C3E4, 0x1012C510, 0x0, 0x0,
						0x0, 0x0, 0x1012C5A8, 0x1012C704,
						0x1012E1C0, 0x1012E344,
						0x101333BC, 0x10133540,
						0x10137B18, 0x10137CCC,
						0x1013CC44, 0x1013CE10,
						0x1013FABC, 0x1013FC70,
						0x10141830, 0x10141A50,
						0x101420E0, 0x1014241C,
						0x10142838, 0x10142B7C,
						0x10178748, 0x101788F4, 0x10178E38,
						0x10142D40, 0x101430F4,
						0x1017BBCC, 0x1017BE74, 0x1017C40C};

// At the beginning of lua_close
// OS-specific
static unsigned const interp_shutdown_addrs[NDLESS_MAX_OSID+1] =
					       {0x106D14B0, 0x106B59A4, 0x106B249C, 0x106B2C38, 0x106AA5B4, 0x106AAD50,
						0x10825B10, 0x1080A35C, 0x108072FC, 0x10807DB8,
						0x1083391C, 0x10817C2C, 0x0, 0x0,
						0x0, 0x0, 0x10815638, 0x10815BB8,
						0x10824770, 0x10824D2C,
						0x10828F28, 0x108294E0,
						0x1084E6D8, 0x1084ECB4,
						0x108575A8, 0x10857B5C,
						0x10866090, 0x1086666C,
						0x10871420, 0x10871A6C,
						0x10872178, 0x108728E4,
						0x10872BB4, 0x10873370,
						0x108A6D1C, 0x108A73EC, 0x108A8104,
						0x10873B2C, 0x108742E4,
						0x108AE9D8, 0x108AF1B4, 0x108AFEF4};

void lua_install_hooks(void) {
	if(interp_startup_addrs[ut_os_version_index] != 0)
		HOOK_INSTALL(interp_startup_addrs[ut_os_version_index], lua_interp_startup);
	if(interp_shutdown_addrs[ut_os_version_index] != 0)
		HOOK_INSTALL(interp_shutdown_addrs[ut_os_version_index], lua_interp_shutdown);
}

static lua_State *luastate = NULL;

lua_State *luaext_getstate(void) {
	return luastate;
}

HOOK_DEFINE(lua_interp_startup) {
	// reg number: OS-specific
	luastate = (lua_State*)HOOK_SAVED_REGS(lua_interp_startup)[6];
	luaL_register(luastate, "_G", baselib);
	luaL_register(luastate, "ndless", ndlesslib);
	HOOK_RESTORE_RETURN(lua_interp_startup);
}

HOOK_DEFINE(lua_interp_shutdown) {
	unsigned i;
	for (i = 0; i < loaded_next_index; i++) {
		ld_free(loaded[i]);
	}
	loaded_next_index = 0;
	luastate = NULL;
	HOOK_RESTORE_RETURN(lua_interp_shutdown);
}
