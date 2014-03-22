/* This is the configuration file for bFLT loader. It isn't used after compiling */

#ifndef _BFLT_CONFIG_H_
#define _BFLT_CONFIG_H_

/* Comment out if you're not planning on loading shared libraries */
#define SHARED_LIB_SUPPORT

#ifdef SHARED_LIB_SUPPORT
/* This is the maximal allowed id value for shared libraries */
/* This value - 1 is also the maximum number of loadable libraries at once */
/* Libraries will be loaded into a cache. The table needed to keep track of
   all the libraries will be (sizeof(shared_lib_t) * (MAX_SHARED_LIB_ID-1)) bytes. */
#define MAX_SHARED_LIB_ID 0xfe

/* Cache shared libraries in memory even after the original executable has been
   freed. This can save subsequent loading times but obviously uses more memory.
   This is only really useful if the loader will be called multiple times.
   You can use bflt_free_all() to clear the cache.

   Comment out if you don't want to cache it */
#define CACHE_LIBS_AFTER_EXEC 1

#endif

/* Verbose level
     3 = Debugging - Prints infomation and errors
     2 = Prints errors only
     1 = Show user readable errors only
     0 = Print nothing and fail silently */
#define VERBOSE_LEVEL 2

#endif
