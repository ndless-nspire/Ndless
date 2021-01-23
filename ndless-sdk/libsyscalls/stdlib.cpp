// Basic syscalls and some runtime functionalities

#include <stdint.h>
#include <stdio.h>
#include <stddef.h>
#include <sys/fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/times.h>
#include <sys/reent.h>
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

namespace __gnu_cxx {
	extern __attribute__((weak)) void __freeres();
}

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

#ifdef USE_NSPIREIO
	#include <nspireio/nspireio.h>

	static nio_console csl;
#endif

// Called at startup (even before c++ constructors are run)
void initialise_monitor_handles()
{
	saved_screen_buffer = REAL_SCREEN_BASE_ADDRESS;
	openfiles[0] = syscall<e_stdin | __SYSCALLS_ISVAR, NUC_FILE*>();
	openfiles[1] = syscall<e_stdout | __SYSCALLS_ISVAR, NUC_FILE*>();
	openfiles[2] = syscall<e_stderr | __SYSCALLS_ISVAR, NUC_FILE*>();

	// Initialization as early as possible, in case c++ constructors output something
	#ifdef USE_NSPIREIO
	        nio_init(&csl,NIO_MAX_COLS,NIO_MAX_ROWS,0,0,NIO_COLOR_BLACK,NIO_COLOR_WHITE,TRUE);
	        nio_set_default(&csl);
		nio_fflush(&csl);
	#endif
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

// Workaround: The malloc syscall doesn't always return a correctly aligned (8 bytes) pointer!
void *malloc(size_t size)
{
	// Yes, this is valid. malloc may return nullptr if size is null.
	if(!size)
		return nullptr;

	// Add 8 bytes for alignment
	uint8_t *alloc_ptr = reinterpret_cast<uint8_t*>(syscall<e_malloc, void*>(size + 8));

	if(!alloc_ptr)
	{
		errno = ENOMEM;
		return nullptr;
	}

	/* Memory layout:
	   [padding|sz_of_padding|.........]
            ^                    ^
            alloc_ptr            aligned_ptr */

	uint8_t *aligned_ptr = reinterpret_cast<uint8_t*>((reinterpret_cast<uint32_t>(alloc_ptr) + 8) & ~7);

	*(aligned_ptr - 1) = reinterpret_cast<uint32_t>(aligned_ptr) - reinterpret_cast<uint32_t>(alloc_ptr);

	return reinterpret_cast<void*>(aligned_ptr);
}

void free(void *mem)
{
	if(mem)
		return syscall<e_free, void>(reinterpret_cast<void*>(reinterpret_cast<uint32_t>(mem) - *(reinterpret_cast<uint8_t*>(mem) - 1)));
}

void *realloc(void *mem, size_t size)
{
	if(!mem)
		return malloc(size);

	if(!size)
	{
		free(mem);
		return nullptr;
	}

	uint8_t old_alignment = *(reinterpret_cast<uint8_t*>(mem) - 1);
	uint8_t *old_ptr = reinterpret_cast<uint8_t*>(reinterpret_cast<uint32_t>(mem) - old_alignment);
	uint8_t *new_ptr = reinterpret_cast<uint8_t*>(syscall<e_realloc, void*>(old_ptr, size + 8));
	if(!new_ptr)
		return nullptr;

	uint8_t *aligned_ptr = reinterpret_cast<uint8_t*>((reinterpret_cast<uint32_t>(new_ptr) + 8) & ~7);
	uint8_t new_alignment = reinterpret_cast<uint32_t>(aligned_ptr) - reinterpret_cast<uint32_t>(new_ptr);

	if(old_alignment != new_alignment)
		memmove(new_ptr + new_alignment, new_ptr + old_alignment, size);

	*(aligned_ptr - 1) = new_alignment;

	return reinterpret_cast<void*>(aligned_ptr);
}

void *calloc(size_t nmemb, size_t size)
{
	if(nmemb == 0 || size == 0)
		return nullptr;

	// Check for overflow!
	uint64_t of_size = nmemb * size; 
	uint32_t of_size32 = static_cast<uint32_t>(of_size);
	if(of_size != of_size32)
		return nullptr;

	void *ptr = malloc(of_size32);
	if(!ptr)
		return nullptr; // malloc sets ENOMEM for us

	return syscall<e_memset, void*>(ptr, 0, of_size32);
}
  
int _puts(const char *s)
{
#ifdef USE_NSPIREIO
	return nio_puts(s);
#else
	return syscall<e_puts, int>(s);
#endif
}

void  __crt0_exit(int ret); // Declared in crt0.S

void _exit(int ret)
{
	#ifdef USE_NSPIREIO
		// This function is called right before jumping back to the system
		// (by returning from main() or manually through exit). This makes
		// it the right place for deinititalizing nspireio, as after this
		// nothing has access to csl anymore and newlib itself won't flush
		// its buffers either.
		nio_free(&csl);
	#endif

	// Free memory allocated by libstdc++
	if(__gnu_cxx::__freeres)
		__gnu_cxx::__freeres();

	// Newlib doesn't reclaim data from the statically allocated reent
	// itself, so do it here. It needs a bit of "convincing".
	// See https://sourceware.org/pipermail/newlib/2020/018173.html
	struct _reent *global_reent = _impure_ptr;
	_impure_ptr = nullptr;
	_reclaim_reent(global_reent);

	__crt0_exit(ret);
	
	__builtin_unreachable();
}

std::type_info* __cxa_current_exception_type() __attribute__((weak));
char* __attribute((weak)) __cxa_demangle(const char *, int, int, int*);

/* Depending on whether the new screen API is being used,
 * abort() uses either lcd_init or the old API to switch back to the OS mode. */
bool __attribute((weak)) lcd_init(scr_type_t);
void lcd_incolor();
void lcd_ingray();

static bool aborting = false;
void abort()
{
	// To prevent an endless loop: _show_msgbox could abort() if e.g. malloc fails
	if(!aborting)
	{
		aborting = true;

		if(lcd_init)
			lcd_init(SCR_TYPE_INVALID);
		else
		{
			if(has_colors)
				lcd_incolor();
			else
				lcd_ingray();
			REAL_SCREEN_BASE_ADDRESS = saved_screen_buffer;
		}

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

int _execve(const char *filename, const char **argv, const char **envp)
{
	unsigned int argc = 0;
	const char **argv_cnt  = argv;
	while(*argv_cnt++)
		++argc;

	if(argc == 0 || argc == 1)
		return syscall<e_nl_exec, int>(filename, 0, nullptr);
	else
		return syscall<e_nl_exec, int>(filename, argc - 1, argv + 1);
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
#ifdef USE_NSPIREIO
	if(file == 0)
	{
		if(!nio_fgets(ptr, len - 1, &csl))
			*ptr = 0;

		strcat(ptr, "\n");
		return strlen(ptr);
	}
#endif
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
#ifdef USE_NSPIREIO
	if(file == 1 || file == 2)
	{
		int len2 = len;
		while(len2--)
			nio_putchar(*ptr++);

		return len;
	}
#endif

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
	return malloc(size);
}

void _free_r(struct _reent *, void *mem)
{
	return free(mem);
}

void *_realloc_r(struct _reent *, void *mem, size_t size)
{
	return realloc(mem, size);
}

void *_calloc_r(struct _reent *, size_t nmemb, size_t size)
{
	return calloc(nmemb, size);
}

clock_t _times(struct tms *ptms)
{
	return 0;
}

// Miscellaneous
void *__dso_handle __attribute__((weak));
void __sync_synchronize(){}
}
