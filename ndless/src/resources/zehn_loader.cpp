#include <algorithm>
#include <cstdio>
#include <cstdint>

#include <libndls.h>
#include <syscall-decls.h>
#include <zehn.h>

#include "ndless.h"

// Lighter alternative to std::vector (DON'T ASSIGN)
template <typename T> class Storage
{
public:
	Storage(size_t count) : count(count) { data = reinterpret_cast<T*>(malloc(sizeof(T) * count)); }
	~Storage() { free(data); }

	T* begin() { return data; }
	T* end() { return data + count; }

	T* data;
	size_t count;
};

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

	Storage<Zehn_reloc> relocs(header.reloc_count);
	Storage<Zehn_flag> flags(header.flag_count);
	Storage<uint8_t> extra_data(header.extra_size);

	if(nuc_fread(reinterpret_cast<void*>(relocs.data), sizeof(Zehn_reloc), header.reloc_count, file) != header.reloc_count
		|| nuc_fread(reinterpret_cast<void*>(flags.data), sizeof(Zehn_flag), header.flag_count, file) != header.flag_count
		|| nuc_fread(reinterpret_cast<void*>(extra_data.data), 1, header.extra_size, file) != header.extra_size)
	{
		puts("[Zehn] File read failed!");
		return 1;
	}

	size_t remaining_mem = header.alloc_size - nuc_ftell(file), remaining_file = header.file_size - nuc_ftell(file);

	if(emu_debug_alloc_ptr)
	{
		if(emu_debug_alloc_size < remaining_mem + 4)
		{
			puts("[Zehn] emu_debug_alloc_size too small!");
			*mem_ptr = malloc(remaining_mem + 4);
		}
		else
			*mem_ptr = emu_debug_alloc_ptr;
	}
	else
		*mem_ptr = malloc(remaining_mem + 4);

	uint8_t *alloc = reinterpret_cast<uint8_t*>(*mem_ptr);
	if(!alloc)
	{
		puts("[Zehn] Memory allocation failed!");
		return 1;
	}

	// Align to 4-bytes
	uint8_t* base = ((reinterpret_cast<uint32_t>(alloc) & 3) == 0) ? alloc : reinterpret_cast<uint8_t*>((reinterpret_cast<uint32_t>(alloc) + 4) & ~3);

	if(nuc_fread(base, remaining_file, 1, file) != 1)
	{
		puts("[Zehn] File read failed!");
		if(alloc != emu_debug_alloc_ptr)
			free(alloc);

		return 1;
	}

	nuc_fclose(file);

	// Fill rest with zeros (.bss and other NOBITS sections)
	std::fill(base + remaining_file, base + remaining_mem, 0);

	uint8_t *exec_data = base;

	// Iterate through each flag
	for(Zehn_flag &f : flags)
	{
		switch(f.type)
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
	for(Zehn_reloc &r : relocs)
	{
		if(exec_data + r.offset >= base + remaining_mem)
		{
			puts("[Zehn] Wrong reloc in Zehn file!");
			free(*mem_ptr);
			return 1;
		}

		uint32_t *place = reinterpret_cast<uint32_t*>(exec_data + r.offset);
		switch(r.type)
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
			printf("[Zehn] Unsupported reloc %d!\n", r.type);
			free(*mem_ptr);
			return 1;
		}
	}

	*entry = reinterpret_cast<int (*)(int,char*[])>(exec_data + header.entry_offset);

	return 0;
}
