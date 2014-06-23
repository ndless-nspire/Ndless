#include <algorithm>
#include <cstdio>
#include <cstdint>

#include <libndls.h>
#include <syscall-decls.h>
#include <zehn.h>

#include "ndless.h"

extern "C" int zehn_load(NUC_FILE *file, void **mem_ptr, int (**entry)(int,char*[]))
{
	Zehn_header header;

	if(nuc_fread(&header, sizeof(header), 1, file) != 1)
		return 1;

	if(header.signature != ZEHN_SIGNATURE || header.version != ZEHN_VERSION || header.file_size > header.alloc_size)
	{
		puts("[Zehn] This Zehn file is not supported!");
		return 1;
	}

	if(emu_debug_alloc_ptr)
	{
		if(emu_debug_alloc_size < header.alloc_size + 4)
		{
			puts("[Zehn] emu_debug_alloc_size too small!");
			*mem_ptr = malloc(header.alloc_size + 4);
		}
		else
			*mem_ptr = emu_debug_alloc_ptr;
	}
	else
		*mem_ptr = malloc(header.alloc_size + 4);

	uint8_t *alloc = reinterpret_cast<uint8_t*>(*mem_ptr);
	if(!alloc)
	{
		puts("[Zehn] Memory allocation failed!");
		return 1;
	}

	// Align to 4-bytes
	uint8_t* base = reinterpret_cast<uint8_t*>((reinterpret_cast<uint32_t>(alloc) + 4) & ~3);
	nuc_fseek(file, 0, SEEK_SET);
	if(nuc_fread(base, header.file_size, 1, file) != 1)
	{
		puts("[Zehn] File read failed!");
		free(alloc);
		return 1;
	}

	nuc_fclose(file);

	// Fill rest with zeros (.bss and other NOBITS sections)
	std::fill(base + header.file_size, base + header.alloc_size, 0);

	Zehn_reloc *reloc_table = reinterpret_cast<Zehn_reloc*>(base + sizeof(Zehn_header));
	Zehn_flag *flag_table = reinterpret_cast<Zehn_flag*>(reinterpret_cast<uint8_t*>(reloc_table) + sizeof(Zehn_reloc) * header.reloc_count);
	uint8_t *extra_data = reinterpret_cast<uint8_t*>(flag_table) + sizeof(Zehn_flag) * header.flag_count;
	uint8_t *exec_data = extra_data + header.extra_size;

	if(exec_data >= base + header.file_size)
	{
		puts("[Zehn] Inconsistencies in Zehn header detected!");
		free(*mem_ptr);
		return 1;
	}
	
	// Iterate through each flag
	for(unsigned int i = 0; i < header.flag_count; ++i, ++flag_table)
	{
		switch(flag_table->type)
		{
		case Zehn_flag_type::EXECUTABLE_NAME:
		case Zehn_flag_type::EXECUTABLE_NOTICE:
		case Zehn_flag_type::EXECUTABLE_AUTHOR:
		case Zehn_flag_type::EXECUTABLE_VERSION:
		case Zehn_flag_type::NDLESS_VERSION_MIN:
		case Zehn_flag_type::NDLESS_REVISION_MIN:
		case Zehn_flag_type::NDLESS_VERSION_MAX:
		case Zehn_flag_type::NDLESS_REVISION_MAX:
		case Zehn_flag_type::RUNS_ON_COLOR:
		case Zehn_flag_type::RUNS_ON_CLICKPAD:
		case Zehn_flag_type::RUNS_ON_TOUCHPAD:
		case Zehn_flag_type::RUNS_ON_32MB:
		default:
			break;
		}
	}

	// Iterate through the reloc table
	for(unsigned int i = 0; i < header.reloc_count; ++i, ++reloc_table)
	{
		if(exec_data + reloc_table->offset >= base + header.alloc_size)
		{
			puts("[Zehn] Wrong reloc in Zehn file!");
			free(*mem_ptr);
			return 1;
		}

		uint32_t *place = reinterpret_cast<uint32_t*>(exec_data + reloc_table->offset);
		switch(reloc_table->type)
		{
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
		default:
			printf("[Zehn] Unsupported reloc %d!\n", reloc_table->type);
			free(*mem_ptr);
			return 1;
		}
	}

	*entry = reinterpret_cast<int (*)(int,char*[])>(exec_data + header.entry_offset);

	return 0;
}
