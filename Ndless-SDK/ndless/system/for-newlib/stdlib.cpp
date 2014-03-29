/* Basic syscalls */

#include <stdint.h>
#include <stdio.h>
#include <stddef.h>
#include <sys/fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/times.h>

// errno is a macro which calls a newlib function, which creates a circular dependency.
#include <errno.h>
#undef errno
extern int errno;

// Syscall enums
#include <syscalls.h>
#include "syscall.h"

extern "C" {
  
static inline void bkpt(void) {
#ifdef __thumb__
	asm(".word 0xBE01");
#else
	asm(".long 0xE1212374");
#endif
}

// The only macro, I swear
#define GETFD(f) \
	do { if(file >= MAX_OPEN_FILES) \
		return errno_set(EBADF); \
	f = openfiles[file]; \
	if(f == 0) \
		return errno_set(EBADF); \
} while(0);
  
constexpr int MAX_OPEN_FILES = 20;

typedef void NUCFILE;
// Used to map newlib FILE* to our NUCFILE*
static NUCFILE* openfiles[MAX_OPEN_FILES];

// Called at startup (even before c++ constructors are run)
void initialise_monitor_handles()
{
	openfiles[0] = syscall<e_stdin | __SYSCALLS_ISVAR, NUCFILE*>();
	openfiles[1] = syscall<e_stdout | __SYSCALLS_ISVAR, NUCFILE*>();
	openfiles[2] = syscall<e_stderr | __SYSCALLS_ISVAR, NUCFILE*>();
}

static int newslot()
{
	for(int i = 0; i < MAX_OPEN_FILES; i++)
		if(openfiles[i] == 0)
			return i;
    
	return -1;
}

static int errno_set(int error)
{
	errno = error;
	return -1;
}

static int errno_update(int result)
{
	errno = *syscall<e_errno_addr, int*>();
	return result;
}

static int errno_check(int result)
{
	if(result != -1)
		return result;

	errno = *syscall<e_errno_addr, int*>();
	return -1;
}
  
int _puts(const char *s)
{
	return syscall<e_puts, int>(s);
}

extern volatile int __crt0_savedsp; // Saved in crt0.S

void _exit(int ret)
{
	asm volatile(
		"mov r0, %[ret]\n"
		"mov sp, %[savedsp]\n" // Saved in crt0.S
		"b __crt0exit\n" :: [ret] "r" (ret), [savedsp] "r" (__crt0_savedsp));
	
	__builtin_unreachable();
}

//Doesn't have to be binary compatible to the newlib struct stat
struct nucleus_stat {
	unsigned short st_dev;
	unsigned int st_ino; // 0
	unsigned int st_mode;
	unsigned short st_nlink; // 1
	unsigned short st_uid; // 0
	unsigned short st_gid; // 0
	unsigned short st_rdev; // = st_dev
	unsigned int st_size;
	unsigned int st_atime;
	unsigned int st_mtime;
	unsigned int st_ctime;
};

int _stat(const char *path, struct stat *st)
{
	struct nucleus_stat nuc_st;
	int ret = syscall<e_stat, int>(path, &nuc_st);
	if(ret < 0)
		return errno_update(ret);
  
	st->st_dev = nuc_st.st_dev;
	st->st_ino = nuc_st.st_ino;
	st->st_mode = nuc_st.st_mode;
	st->st_nlink = nuc_st.st_nlink;
	st->st_uid = nuc_st.st_uid;
	st->st_gid = nuc_st.st_gid;
	st->st_rdev = nuc_st.st_rdev;
	st->st_size = nuc_st.st_size;
	st->st_atime = nuc_st.st_atime;
	st->st_mtime = nuc_st.st_mtime;
	st->st_ctime = nuc_st.st_ctime;
  
	return 0;
}

int _fstat(int file, struct stat *st)
{
	return errno_set(ENOSYS);
}

int _read(int file, char *ptr, int len)
{
	NUCFILE *f;
	GETFD(f);

	int ret = syscall<e_fread, int>(ptr, 1, len, f);
	if(ret == 0)
	{
		if (syscall<e_fgetc, int>(f) == EOF && (*((uint32_t *)f + 3) & 0x10))
			return 0;
		else
		{
			syscall<e_ungetc, int>(f);
			return errno_update(-1);
		}
	}
  
	return ret;
}

int _write(int file, char *ptr, int len)
{
	NUCFILE *f;
	GETFD(f);

	int ret = syscall<e_fwrite, int>(ptr, 1, len, f);
  
	if(ret == 0)
		return errno_update(-1);
  
	return ret;
}

int _lseek(int file, int ptr, int dir)
{
	NUCFILE *f;
	GETFD(f);
  
	return errno_check(syscall<e_fseek, int>(f, ptr, dir));
}

int _open(const char *path, int flags)
{
	char mode[4];
	int curmode = 0;
	int file = newslot();
	if(file == -1)
		return errno_set(EMFILE);
  
	if((flags & (O_CREAT | O_EXCL)) == (O_CREAT | O_EXCL))
	{
		struct stat st;
		if(_stat(path, &st))
			return errno_set(EEXIST);
	}
  
	if(flags & O_CREAT)
	{
		NUCFILE *f = syscall<e_fopen, FILE*>(path, static_cast<const char*>("a"));
		if(f == 0)
			return errno_update(0);
    
		syscall<e_fclose, void>(f);
	}
  
	if(flags & O_APPEND)
	{
		mode[curmode++] = 'a';

		if(flags & O_RDWR)
			mode[curmode++] = '+';
	}
	else if(flags & O_WRONLY)
		mode[curmode++] = 'w';
	else if(flags & O_RDWR)
	{
		mode[curmode++] = 'r';
		mode[curmode++] = '+';
	}
	else //if(flags & O_RDONLY)
		mode[curmode++] = 'r';

	//newlib disables O_BINARY on arm by default
	mode[curmode++] = 'b';
  
	mode[curmode] = 0;

	openfiles[file] = syscall<e_fopen, FILE*>(path, mode);
	if(openfiles[file] == 0)
		return errno_update(-1);
  
	return file;
}

int _close(int file)
{
	NUCFILE *f;
	GETFD(f);
  
	openfiles[file] = 0;
  
	return errno_check(syscall<e_fclose, int>(f));
}

int _isatty(int file)
{
	return file < 3;
}

int _unlink(const char *path)
{
	return errno_check(syscall<e_unlink, int>(path));
}

int _link(const char *oldpath, const char *newpath)
{
	return errno_set(ENOSYS);
}

int _rename(const char *oldpath, const char *newpath)
{
	return errno_check(syscall<e_rename, int>(oldpath, newpath));
}

int _gettimeofday(struct timeval *tv, struct timezone *tz)
{
	if(tv)
	{
		tv->tv_sec = *reinterpret_cast<volatile uint32_t*>(0x90090000);
		tv->tv_usec = 0;
	}
	if(tz)
	{
		tz->tz_minuteswest = 0;
		tz->tz_dsttime = 0;
	}

	return 0;
}

int _getpid(void*)
{
	return 1;
}

int _kill(pid_t pid, int sig)
{
	return errno_set(ENOSYS);
}

/* libstdc++ needs this for iostream */
void *__dso_handle;

/* programs linked to newlib use malloc, but newlib itself uses _malloc_r... */
void *malloc(size_t size)
{
	return syscall<e_malloc, void*>(size);
}

void free(void *mem)
{
	return syscall<e_free, void>(mem);
}

void *realloc(void *mem, size_t size)
{
	return syscall<e_realloc, void*>(mem, size);
}

void *calloc(size_t nmemb, size_t size)
{
	return syscall<e_calloc, void*>(nmemb, size);
}

/* The unused void* here are structs used for reentrancy */

void *_malloc_r(void*, size_t size)
{
	return syscall<e_malloc, void*>(size);
}

void _free_r(void*, void *mem)
{
	return syscall<e_free, void>(mem);
}

void *_realloc_r(void*, void *mem, size_t size)
{
	return syscall<e_realloc, void*>(mem, size);
}

void *_calloc_r(void*, size_t nmemb, size_t size)
{
	return syscall<e_calloc, void*>(nmemb, size);
}

}