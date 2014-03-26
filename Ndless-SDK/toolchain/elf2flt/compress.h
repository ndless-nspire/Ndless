/*
 * Helper functions to handle compression via zlib
 *
 * Copyright (C) 2007-2008 Julian Brown
 * Copyright (C) 2008 Mike Frysinger
 *
 * Licensed under the GPL-2 or later.
 */

#ifndef __ELF2FLT_COMPRESS_H__
#define __ELF2FLT_COMPRESS_H__

#include <zlib.h>

typedef enum
{
  INVALID,
  UNCOMPRESSED,
  COMPRESSED
} stream_type;

/* Tagged union holding either a regular FILE* handle or a zlib gzFile
   handle.  */
typedef struct
{
  stream_type type;
  const char *mode;
  union
    {
      FILE *filep;
      gzFile gzfilep;
    } u;
} stream;

int fopen_stream_u(stream *fp, const char *path, const char *mode);
size_t fread_stream(void *ptr, size_t size, size_t nmemb, stream *str);
size_t fwrite_stream(const void *ptr, size_t size, size_t nmemb, stream *str);
int fclose_stream(stream *str);
int ferror_stream(stream *str);
int fseek_stream(stream *str, long offset, int whence);
void reopen_stream_compressed(stream *str);
void transfer(stream *ifp, stream *ofp, int count);

#endif
