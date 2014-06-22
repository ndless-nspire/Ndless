#include <algorithm>
#include <cstdint>

#include <syscall-list.h>
#include <syscall.h>

#include <zehn.h>

//Defined in ldscript, points at the end of the loader
//and therefore at the start of the zehn file
extern uint8_t zehn_start;

typedef int (*Entry)(int,char**);

int main(int argc, char **argv)
{
	uint32_t base;

	//Get the offset the loader has been loaded at
	asm volatile(	"label1:\n"
			"sub %[base], pc, #8\n"
			"ldr r1, =label1\n"
			"sub %[base], %[base], r1" : [base] "=r" (base) :: "r1");

	const Zehn_header *header = reinterpret_cast<const Zehn_header*>(&zehn_start + base + 16);

	if(header->signature != ZEHN_SIGNATURE || header->version != ZEHN_VERSION || header->file_size > header->alloc_size)
		return 1;

	uint8_t *mallocd = nullptr;
	//We mustn't use any syscalls if used for loading ndless_resources, where --include-bss is used,
	//so this step will be skipped
	if(header->file_size != header->alloc_size)
	{
		mallocd = syscall<e_malloc, uint8_t*>(header->alloc_size + 4);
		if(!mallocd)
			return 1;

		//4-byte alignment
		uint8_t *new_storage = reinterpret_cast<uint8_t*>(reinterpret_cast<uint32_t>(mallocd) & ~3);
		const uint8_t *old_storage = reinterpret_cast<const uint8_t*>(header);
		syscall<e_memcpy, void*>(new_storage, old_storage, header->file_size);
		header = reinterpret_cast<const Zehn_header*>(new_storage);
	}
	
	const Zehn_reloc *reloc_table = reinterpret_cast<const Zehn_reloc*>(reinterpret_cast<const uint8_t*>(header) + sizeof(Zehn_header));
	//This loader doesn't parse the flag table
	const uint8_t *flag_table = reinterpret_cast<const uint8_t*>(reloc_table) + sizeof(Zehn_reloc) * header->reloc_count;
	uint8_t *exec_data = const_cast<uint8_t*>(flag_table + sizeof(Zehn_flag) * header->flag_count + header->extra_size);

	for(unsigned int i = 0; i < header->reloc_count; ++i, ++reloc_table)
	{
		uint32_t* place = reinterpret_cast<uint32_t*>(exec_data + reloc_table->offset);
		switch(reloc_table->type)
		{
		case Zehn_reloc_type::ADD_BASE:
			*place += reinterpret_cast<uint32_t>(exec_data);
			break;
		case Zehn_reloc_type::ADD_BASE_GOT:
			while(*place != 0xFFFFFFFF)
				*place++ += reinterpret_cast<uint32_t>(exec_data);
			break;
		default: //Unknown, abort!
			return 1;
		}
	}

	//Everything relocated, jump to entry point!
	Entry entry = reinterpret_cast<Entry>(exec_data + header->entry_offset);

	int ret = entry(argc, argv);

	if(mallocd)
		syscall<e_free, void>(mallocd);

	return ret;
}
