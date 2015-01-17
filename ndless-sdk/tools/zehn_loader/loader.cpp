#include <algorithm>
#include <cstdint>

#include <syscall-list.h>
#include <syscall.h>

#include <zehn.h>

#ifdef ENABLE_ZLIB
#include <zlib.h>

//These stubs are used by zlib
extern "C" 
{
void *malloc(size_t s) { return syscall<e_malloc, void*>(s); }
void free(void *s) { return syscall<e_free, void>(s); }
void *memcpy(void *dest, const void *src, size_t n) { return syscall<e_memcpy, void*>(dest, src, n); }
}
#endif

//Defined in ldscript, points at the end of the loader
//and therefore at the start of the appended zehn file
extern uint8_t zehn_start;

typedef int (*Entry)(int,char**);

int main(int, char**) __attribute__((section(".start")));
int main(int argc, char **argv)
{
	const Zehn_header *header;

	//Get the offset the loader has been loaded at
	asm volatile(	"label1:\n"
			"sub %[header], pc, #8\n"
			"ldr r1, =label1\n"
			"sub %[header], %[header], r1\n"
			"ldr r1, =zehn_start\n"
			"add %[header], %[header], r1\n" : [header] "=r" (header) :: "r1");

	header = reinterpret_cast<const Zehn_header*>(__builtin_assume_aligned(header, 4));

	if(header->signature != ZEHN_SIGNATURE || header->version != ZEHN_VERSION || header->file_size > header->alloc_size)
		return 1;

	uint8_t *mallocd = nullptr;
	const uint8_t *old_storage = nullptr;
	//We mustn't use any syscalls if used for loading ndless_resources, where --include-bss is used,
	//so this step will be skipped
	if(header->alloc_size != header->file_size)
	{
		mallocd = syscall<e_calloc, uint8_t*>(1, header->alloc_size);
		if(!mallocd)
			return 1;

		old_storage = reinterpret_cast<const uint8_t*>(header);
		syscall<e_memcpy, void*>(mallocd, old_storage, header->file_size);
		header = reinterpret_cast<const Zehn_header*>(mallocd);
	}
	
	const Zehn_reloc *reloc_table = reinterpret_cast<const Zehn_reloc*>(reinterpret_cast<const uint8_t*>(header) + sizeof(Zehn_header));
	//This loader doesn't parse the flag table
	const uint8_t *flag_table = reinterpret_cast<const uint8_t*>(reloc_table) + sizeof(Zehn_reloc) * header->reloc_count;
	uint8_t *exec_data = const_cast<uint8_t*>(flag_table + sizeof(Zehn_flag) * header->flag_count + header->extra_size);

	#ifdef ENABLE_ZLIB
	if(reloc_table[0].type == Zehn_reloc_type::FILE_COMPRESSED)
	{
		if(mallocd == nullptr || old_storage == nullptr || reloc_table[0].offset != static_cast<int>(Zehn_compress_type::ZLIB))
		{
			syscall<e_free, void>(mallocd);
			return 1;
		}
		
		size_t offset_to_exec_data = exec_data - reinterpret_cast<const uint8_t*>(header);
		uLongf uncomp_size = header->alloc_size - offset_to_exec_data;
		int res = uncompress(mallocd + offset_to_exec_data, &uncomp_size, old_storage + offset_to_exec_data, header->file_size - offset_to_exec_data);
		if(res != Z_OK)
		{
			syscall<e_free, void>(mallocd);
			return 1;
		}				
	}
	#endif

	for(unsigned int i = 0; i < header->reloc_count; ++i, ++reloc_table)
	{
		uint32_t* place = reinterpret_cast<uint32_t*>(exec_data + reloc_table->offset);
		switch(reloc_table->type)
		{
		#ifdef ENABLE_ZLIB
		case Zehn_reloc_type::FILE_COMPRESSED:
			break;
		#endif
		case Zehn_reloc_type::ADD_BASE:
			*place += reinterpret_cast<uint32_t>(exec_data);
			break;
		case Zehn_reloc_type::ADD_BASE_GOT:
			while(*place != 0xFFFFFFFF)
				*place++ += reinterpret_cast<uint32_t>(exec_data);
			break;
		case Zehn_reloc_type::SET_ZERO:
			*place = 0;
			break;
		default: //Unknown, abort!
			if(mallocd != nullptr)
				syscall<e_free, void>(mallocd);

			return 1;
		}
	}

	//Everything relocated, jump to entry point!
	Entry entry = reinterpret_cast<Entry>(exec_data + header->entry_offset);

	int ret = entry(argc, argv);

	if(mallocd != nullptr)
		syscall<e_free, void>(mallocd);

	return ret;
}
