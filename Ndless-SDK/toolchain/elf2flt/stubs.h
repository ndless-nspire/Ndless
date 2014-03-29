/* macros for conversion between host and (internet) network byte order */
#ifndef WIN32
# include <netinet/in.h> /* Consts and structs defined by the internet system */
# define BINARY_FILE_OPTS
#else
# include <winsock2.h>
# define BINARY_FILE_OPTS "b"
#endif

#ifndef __WIN32
# include <sys/wait.h>
#endif
#ifndef WIFSIGNALED
# define WIFSIGNALED(S) (((S) & 0xff) != 0 && ((S) & 0xff) != 0x7f)
#endif
#ifndef WTERMSIG
# define WTERMSIG(S) ((S) & 0x7f)
#endif
#ifndef WIFEXITED
# define WIFEXITED(S) (((S) & 0xff) == 0)
#endif
#ifndef WEXITSTATUS
# define WEXITSTATUS(S) (((S) & 0xff00) >> 8)
#endif
#ifndef WCOREDUMP
# define WCOREDUMP(S) ((S) & WCOREFLG)
#endif
#ifndef WCOREFLG
# define WCOREFLG 0200
#endif
#ifndef HAVE_STRSIGNAL
# define strsignal(sig) "SIG???"
#endif

#define streq(str1, str2) (strcmp(str1, str2) == 0)
#define streqn(str1, str2) (strncmp(str1, str2, strlen(str2)) == 0)

#ifndef DEBUG
# define DEBUG -1
#endif
#define _debug(lvl, fmt, args...) \
	do { \
		if (lvl <= DEBUG) { \
			fprintf(stderr, "%s:%i: " fmt, __func__, __LINE__ , ## args); \
			fflush(stderr); \
		} \
	} while (0)
#define debug2(...) _debug(2, __VA_ARGS__)
#define debug1(...) _debug(1, __VA_ARGS__)
#define debug0(...) _debug(0, __VA_ARGS__)
#define debug(...)  debug0(__VA_ARGS__)

#ifndef HAVE_GETLINE
ssize_t getline(char **line, size_t *alloc, FILE *in);
#endif

extern const char *elf2flt_progname;

void fatal(const char *, ...);
void fatal_perror(const char *, ...);

FILE *xfopen(const char *path, const char *mode);

/* Structure to hold a list of options */
typedef struct
{
  const char **options;
  size_t num;
  size_t alloc;
} options_t;
/* Initialize an options structure */
#define init_options(DST) ((DST)->options = NULL, (DST)->num = (DST)->alloc = 0)
void append_options(options_t *dst, const options_t *src);
void append_option(options_t *dst, const char *src);
void append_option_str(options_t *dst, const char *src, const char *delim);
