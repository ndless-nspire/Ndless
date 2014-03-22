#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "libiberty.h"

#include "stubs.h"

#ifndef HAVE_DCGETTEXT
const char *dcgettext(const char *domain, const char *msg, int category)
{
  return msg;
}
#endif /* !HAVE_DCGETTEXT */

#ifndef HAVE_LIBINTL_DGETTEXT
const char *libintl_dgettext(const char *domain, const char *msg)
{
  return msg;
}
#endif /* !HAVE_LIBINTL_DGETTEXT */

#ifndef HAVE_GETLINE
/* Read a line from IN.  LINE points to a malloc'd buffer that is extended as
   necessary.  ALLOC points to the allocated length of LINE.  Returns
   the length of the string read (including any trailing \n) */

ssize_t getline(char **line, size_t *alloc, FILE *in)
{
	size_t len = 0;

	if (!*alloc) {
		*alloc = 200;
		*line = xmalloc(*alloc);
	}

	while (1) {
		if (!fgets(*line + len, *alloc - len, in))
			return 0;
		len += strlen(*line + len);
		if (len && (*line)[len - 1] == '\n')
			return len;

		*alloc *= 2;
		*line = xrealloc(*line, *alloc);
	}
}
#endif

/* fatal error & exit */
void fatal(const char *format, ...)
{
	va_list args;

	va_start(args, format);
	fprintf(stderr, "%s: ", elf2flt_progname);
	vfprintf(stderr, format, args);
	fprintf(stderr, "\n");
	va_end(args);
	exit(1);
}

/* fatal error, perror & exit */
void fatal_perror(const char *format, ...)
{
	int e = errno;
	va_list args;

	va_start(args, format);
	fprintf(stderr, "%s: ", elf2flt_progname);
	vfprintf(stderr, format, args);
	fprintf(stderr, ": %s\n", strerror(e));
	va_end(args);
	exit(1);
}

/* open a file or fail */
FILE *xfopen(const char *path, const char *mode)
{
	FILE *ret = fopen(path, mode);
	if (!ret)
		fatal_perror("Unable to open '%s'", path);
	return ret;
}

/* Append a string SRC to an options array DST */
void append_option(options_t *dst, const char *src)
{
	if (dst->alloc == dst->num) {
		size_t a = (dst->num + 2) * 2;
		void *o = xmalloc(sizeof(*dst->options) * a);

		memcpy(o, dst->options, sizeof(*dst->options) * dst->num);
		free(dst->options);
		dst->options = o;
		dst->alloc = a;
	}

	dst->options[dst->num] = src;
	dst->num++;
}

/* Split and append a string SRC to an options array DST */
void append_option_str(options_t *dst, const char *src, const char *delim)
{
	char *tok_src = xstrdup(src);
	char *tok = strtok(tok_src, delim);
	while (tok) {
		append_option(dst, tok);
		tok = strtok(NULL, delim);
	}
	/* don't free tok_src since options_t now points to it */
}

/* Append an options array SRC to another options array DST */
void append_options(options_t *dst, const options_t *src)
{
	if (dst->alloc < dst->num + src->num) {
		size_t a = (dst->num + src->num + 2) * 2;
		void *o = xmalloc(sizeof(*dst->options) * a);

		memcpy(o, dst->options, sizeof(*dst->options) * dst->num);
		free(dst->options);
		dst->options = o;
		dst->alloc = a;
	}

	memcpy(&dst->options[dst->num], &src->options[0],
		sizeof(*dst->options) * src->num);
	dst->num += src->num;
}
