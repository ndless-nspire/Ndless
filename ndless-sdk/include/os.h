/* This file shouldn't be used anymore, just kept for compatibility */

#ifndef OS_H
#define OS_H

#ifdef __cplusplus
extern "C" {
#endif

extern char _start;
#define __base _start
#define STRINGIFYMAGIC(x) #x
#define STRINGIFY(x) STRINGIFYMAGIC(x)

#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <errno.h>
#include <math.h>
#include <libndls.h>
#include <keys.h>
#include <hook.h>
#include <nucleus.h>
#include <lauxlib.h>
#include <ngc.h>
#include <syscall-decls.h>

#ifdef __cplusplus
}
#endif

#endif // !OS_H
