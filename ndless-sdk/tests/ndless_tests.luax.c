/****************************************************************************
 * Automated test cases for Lua extension API
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

#include <os.h>
#include "ndless_tests.h"

static int dummy_func(__attribute__((unused)) lua_State *L) {
	return 0;
}

static int run(lua_State *L) {
	int i;
	
	assertUIntEquals("lua_gettop", 1, lua_gettop(L));
	assertTrue("lua_checkstack", lua_checkstack(L, 10));
	assertRuns("lua_concat1", lua_concat(L, 1));
	assertStrEquals("lua_concat2", "run", lua_tostring(L, -1));
	// r = string.>rep("a", 3)
	assertRuns("lua_getfield", lua_getglobal(L, "string"));
	assertFalse("lua_getfield.string", lua_isnil(L, -1));
	assertRuns("lua_getfield.rep1", lua_getfield(L, -1, "rep"));
	assertFalse("lua_getfield.rep", lua_isnil(L, -1));
	assertRuns("lua_pushstring", lua_pushstring(L, "a"));
	assertRuns("lua_pushinteger", lua_pushinteger(L, 3));
	assertRuns("lua_call", lua_call(L, 2, 1));
	assertRuns("lua_setfield", lua_setglobal(L, "r"));
	assertRuns("lua_getfield", lua_getglobal(L, "r"));
	assertTrue("lua_isstring", lua_isstring(L, -1));
	assertStrEquals("lua_tostring", "aaa", lua_tostring(L, -1));
	assertStrEquals("lua_tolstring", "aaa", lua_tolstring(L, -1, NULL));
	assertZero("lua_cpcall", lua_cpcall(L, dummy_func, NULL));
	assertRuns("lua_createtable", lua_createtable(L, 0, 0));
	assertTrue("lua_istable", lua_istable(L, -1));
	lua_pushinteger(L, 1); // v
	lua_pushinteger(L, 2); // k
	assertRuns("lua_settable", lua_settable(L, -3));
	assertUIntEquals("lua_objlen", 1, lua_objlen(L, -1));
	assertRuns("lua_pushinteger", lua_pushstring(L, "3"));
	assertRuns("lua_pushinteger", lua_pushstring(L, "3"));
	assertTrue("lua_equal", lua_equal(L, -1, -2));
	assertUIntEquals("lua_tonumber", 3, lua_tonumber(L, -1)); // fails because double format different than the OS's?
	assertUIntEquals("lua_tointeger", 3, lua_tointeger(L, -1));
	assertNonZero("lua_gc", lua_gc(L, LUA_GCCOUNT, 0));
	i = lua_gettop(L);
	assertRuns("lua_pop", lua_pop(L, 1));
	assertIntEquals("lua_pop2", i - 1, lua_gettop(L));
	
	//TODO lua_pcall
	// won't do: lua_dump, lua_error
	return 0;
}

static const luaL_reg lualib[] = {
	{"run", run},
	{NULL, NULL}
};

int main(void) {
	lua_State *L = nl_lua_getstate();
	if (!L) return 0; // not being called as Lua module
	luaL_register(L, "tests", lualib);
	return 0;
}
