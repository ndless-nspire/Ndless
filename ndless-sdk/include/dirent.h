#ifndef DIRENT_H
#define DIRENT_H

#ifdef __cpluspls
extern "C" {
#include <cstdio>
#else
#include <stdio.h>
#endif

#include <syscall-decls.h>
#include <nucleus.h>

typedef NUC_DIR DIR;

//This typedef isn't possible, so use a macro
//typedef struct nuc_dirent struct dirent;
#define dirent nuc_dirent

static DIR* opendir(const char *dir) { return nuc_opendir(dir); }
static struct dirent *readdir(DIR *dir) { return nuc_readdir(dir); }
static int closedir(DIR *dir) { return nuc_closedir(dir); }

#ifdef __cpluspls
}
#endif

#endif // !DIRENT_H
