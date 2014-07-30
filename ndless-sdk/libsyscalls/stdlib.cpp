// Basic syscalls and some runtime functionalities

#include <stdint.h>
#include <stdio.h>
#include <stddef.h>
#include <sys/fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/times.h>
#include <limits.h>
#include <nucleus.h>
#include <libndls.h>

#include <typeinfo>

// errno is a macro which calls a newlib function, which would create a circular dependency,
// so errno needs to be addressed directly
#include <errno.h>
#undef errno
extern int errno;

// Syscall enum
#include <syscall-list.h>
#include "syscall.h"

extern "C" {

// The only macro, I swear
#define GETFD(f) \
	do { if(file >= MAX_OPEN_FILES) \
		return errno_set(EBADF); \
	f = openfiles[file]; \
	if(f == 0) \
		return errno_set(EBADF); \
} while(0);
  
constexpr int MAX_OPEN_FILES = 20;

// Used to map newlib FILE* to our NUCFILE*
static NUC_FILE* openfiles[MAX_OPEN_FILES];
static void* saved_screen_buffer; //In case the program changes the buffer

// Called at startup (even before c++ constructors are run)
void initialise_monitor_handles()
{
	saved_screen_buffer = SCREEN_BASE_ADDRESS;
	openfiles[0] = syscall<e_stdin | __SYSCALLS_ISVAR, NUC_FILE*>();
	openfiles[1] = syscall<e_stdout | __SYSCALLS_ISVAR, NUC_FILE*>();
	openfiles[2] = syscall<e_stderr | __SYSCALLS_ISVAR, NUC_FILE*>();
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

// Programs linked to newlib use malloc, but newlib itself uses _malloc_r...
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
  
int _puts(const char *s)
{
	return syscall<e_puts, int>(s);
}

void  __crt0_exit(int ret); // Declared in crt0.S

void _exit(int ret)
{
	__crt0_exit(ret);
	
	__builtin_unreachable();
}

std::type_info* __cxa_current_exception_type() __attribute__((weak));
char* __attribute((weak)) __cxa_demangle(const char *, int, int, int*);

static bool aborting = false;
void abort()
{
	// To prevent an endless loop: _show_msgbox could abort() if e.g. malloc fails
	if(!aborting)
	{
		aborting = true;

		if(has_colors)
			lcd_incolor();
		else
			lcd_ingray();
		SCREEN_BASE_ADDRESS = saved_screen_buffer;

		if(&__cxa_demangle == 0)
			goto nocpp;

		if(std::type_info *t = __cxa_current_exception_type())
		{
			int status = -1;
			char *dem = __cxa_demangle(t->name(), 0, 0, &status);
			if(status == 0)
			{
				_show_msgbox("Exception", dem, 0);
				free(dem);
			}
			else
				_show_msgbox("Exception", t->name(), 0);
		}

		nocpp:
		_show_msgbox("Ndless", "The application crashed", 0);
	}

	_exit(-1);

	__builtin_unreachable();
}

int _stat(const char *path, struct stat *st)
{
	struct nuc_stat nuc_st;
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
	NUC_FILE *f;
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
	NUC_FILE *f;
	GETFD(f);

	int ret = syscall<e_fwrite, int>(ptr, 1, len, f);
  
	if(ret == 0)
		return errno_update(-1);
  
	return ret;
}

int _lseek(int file, int ptr, int dir)
{
	NUC_FILE *f;
	GETFD(f);
  
	if(syscall<e_fseek, int>(f, ptr, dir) == -1)
		return errno_update(-1);
	
	return syscall<e_ftell, int>(f);
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
		NUC_FILE *f = syscall<e_fopen, NUC_FILE*>(path, static_cast<const char*>("a"));
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

	openfiles[file] = syscall<e_fopen, NUC_FILE*>(path, mode);
	if(openfiles[file] == 0)
		return errno_update(-1);
  
	return file;
}

int _close(int file)
{
	//NEVER close std*, that would make them unusuable!
	if(file < 3)
		return errno_set(EIO);

	NUC_FILE *f;
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

int mkdir(const char *path, mode_t mode)
{
	return errno_check(syscall<e_mkdir, int>(path, mode));
}

int rmdir(const char *path)
{
	return errno_check(syscall<e_rmdir, int>(path));
}

int chdir(const char *path)
{
	return errno_check(syscall<e_NU_Set_Current_Dir, int>(path) ? 0 : -1);
}

char *getwd(char *buf)
{
	syscall<e_NU_Current_Dir, int>("A:\\", buf);
	return buf;
}

char *get_current_dir_name()
{
	char *buf = reinterpret_cast<char*>(malloc(PATH_MAX));
	return getwd(buf);
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

void *_malloc_r(struct _reent *, size_t size)
{
	return syscall<e_malloc, void*>(size);
}

void _free_r(struct _reent *, void *mem)
{
	return syscall<e_free, void>(mem);
}

void *_realloc_r(struct _reent *, void *mem, size_t size)
{
	return syscall<e_realloc, void*>(mem, size);
}

void *_calloc_r(struct _reent *, size_t nmemb, size_t size)
{
	return syscall<e_calloc, void*>(nmemb, size);
}

// Miscellaneous
void *__dso_handle __attribute__((weak));
}
