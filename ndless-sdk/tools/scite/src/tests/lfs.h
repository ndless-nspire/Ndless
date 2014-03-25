/*
** LuaFileSystem
** Copyright Kepler Project 2004-2006 (http://www.keplerproject.org/luafilesystem)
**
** $Id: lfs.h,v 1.3 2006/03/10 23:37:32 carregal Exp $
*/

/* Define 'chdir' for systems that do not implement it */
#ifdef NO_CHDIR
#define chdir(p)	(-1)
#define chdir_error	"Function 'chdir' not provided by system"
#else
#define chdir_error	strerror(errno)
#endif

int luaopen_lfs (lua_State *L);
