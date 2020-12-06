#include <algorithm>
#include <cstdio>
#include <cstdint>
#include <cstdarg>

#include <zlib.h>
#include <libndls.h>
#include <syscall-decls.h>
#include <zehn.h>

#include "ndless.h"
#include "ndless_version.h"
#include "zehn_loader.h"

// Lighter alternative to std::vector
template <typename T> class Storage
{
public:
	Storage(const size_t count) : m_count(count) { m_data = reinterpret_cast<T*>(malloc(sizeof(T) * m_count)); }
	Storage(const Storage<T> &s) = delete;
	~Storage() { free(m_data); }
	Storage<T> &operator=(const Storage<T> &s) = delete;

	T* begin() { return m_data; }
	T* end() { return m_data + m_count; }

	size_t size() { return m_count; }
	T* data() { return m_data; }

	bool alloc_failed() { return m_count > 0 && m_data == nullptr; }

private:
	const size_t m_count;
	T* m_data;
};

void msgbox(const char *title, const char *fmt, ...)
{
	char content[1024];

	va_list args;
	va_start(args, fmt);
	vsnprintf(content, sizeof(content), fmt, args);

	show_msgbox(title, content);

	va_end(args);
}

// Validates the string a Zehn_flag points to
bool zehn_check_string(const uint8_t *extra_data, const Zehn_flag flag, unsigned int max_length, const char **string)
{
	*string = reinterpret_cast<const char*>(extra_data) + flag.data;
	const char *ptr = *string;
        while(*ptr)
        {
                if(max_length == 0)
                	return false;

        	++ptr;
		--max_length;
	}

	return true;
}

static uint32_t ru32(void *ptr)
{
        if((reinterpret_cast<uintptr_t>(ptr) & 0b11) == 0)
            return *reinterpret_cast<uint32_t*>(ptr);

	uint32_t ret;
	memcpy(&ret, ptr, sizeof(ret));
	return ret;
}

static void wu32(void *ptr, uint32_t val)
{
        if((reinterpret_cast<uintptr_t>(ptr) & 0b11) == 0)
            *reinterpret_cast<uint32_t*>(ptr) = val;
        else
	    memcpy(ptr, &val, sizeof(val));
}

extern "C" int zehn_load(NUC_FILE *file, void **mem_ptr, int (**entry)(int,char*[]), bool *supports_hww)
{
	Zehn_header header;

	// The Zehn file may not begin at the file start
	size_t file_start = nuc_ftell(file);

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

	if(relocs.alloc_failed() || flags.alloc_failed() || extra_data.alloc_failed())
	{
		puts("[Zehn] Allocation of metadata failed!");
		return 1;
	}

	if(nuc_fread(reinterpret_cast<void*>(relocs.data()), sizeof(Zehn_reloc), header.reloc_count, file) != header.reloc_count
		|| nuc_fread(reinterpret_cast<void*>(flags.data()), sizeof(Zehn_flag), header.flag_count, file) != header.flag_count
		|| nuc_fread(reinterpret_cast<void*>(extra_data.data()), 1, header.extra_size, file) != header.extra_size)
	{
		puts("[Zehn] File read failed!");
		return 1;
	}

	size_t remaining_mem = header.alloc_size - nuc_ftell(file) + file_start, remaining_file = header.file_size - nuc_ftell(file) + file_start;

	if(emu_debug_alloc_ptr)
	{
		if(emu_debug_alloc_size() < remaining_mem)
		{
			puts("[Zehn] emu_debug_alloc_size too small!");
			*mem_ptr = malloc(remaining_mem);
		}
		else
			*mem_ptr = emu_debug_alloc_ptr;
	}
	else
		*mem_ptr = malloc(remaining_mem);

	uint8_t *base = reinterpret_cast<uint8_t*>(*mem_ptr);
	if(!base)
	{
		puts("[Zehn] Memory allocation failed!");
		return 1;
	}

	if(relocs.size() > 0 && relocs.data()[0].type == Zehn_reloc_type::FILE_COMPRESSED)
	{
		if(relocs.data()[0].offset != static_cast<int>(Zehn_compress_type::ZLIB))
		{
			puts("[Zehn] Compression format not supported!");
			return 1;
		}

		Storage<uint8_t> compressed(remaining_file);
		if(nuc_fread(compressed.data(), remaining_file, 1, file) != 1)
		{
			puts("[Zehn] File read failed!");
			return 1;
		}

		uLongf dest_len = remaining_mem;
		if(uncompress(base, &dest_len, compressed.data(), remaining_file) != Z_OK)
		{
			puts("[Zehn] Decompression failed!");
			return 1;
		}

		std::fill(base + dest_len, base + remaining_mem, 0);
	}
	else
	{
		if(nuc_fread(base, remaining_file, 1, file) != 1)
		{
			puts("[Zehn] File read failed!");
			return 1;
		}
	
		// Fill rest with zeros (.bss and other NOBITS sections)
		std::fill(base + remaining_file, base + remaining_mem, 0);
	}

	const char *application_name = "(unknown)", *application_author = "(unknown)", *application_notice = "(no notice)";
	unsigned int application_version = 1, ndless_version_min = 0, ndless_version_max = UINT_MAX,
		ndless_revision_min = 0, ndless_revision_max = UINT_MAX;

	// Iterate through each flag
	for(Zehn_flag &f : flags)
	{
		const char *ptr;
		switch(f.type)
		{
		case Zehn_flag_type::EXECUTABLE_NAME:
			if(!zehn_check_string(extra_data.data(), f, 255, &application_name))
			{
				puts("[Zehn] Invalid application name!");
				return 1;
			}

			break;
		case Zehn_flag_type::EXECUTABLE_NOTICE:
			if(zehn_check_string(extra_data.data(), f, 1024, &ptr))
				application_notice = ptr;

			break;
		case Zehn_flag_type::EXECUTABLE_AUTHOR:
			if(zehn_check_string(extra_data.data(), f, 128, &ptr))
				application_author = ptr;

			break;
		case Zehn_flag_type::EXECUTABLE_VERSION:
			application_version = f.data;
			break;
		case Zehn_flag_type::NDLESS_VERSION_MIN:
			ndless_version_min = f.data;
			break;
		case Zehn_flag_type::NDLESS_REVISION_MIN:
			ndless_revision_min = f.data;
			break;
		case Zehn_flag_type::NDLESS_VERSION_MAX:
			ndless_version_max = f.data;
			break;
		case Zehn_flag_type::NDLESS_REVISION_MAX:
			ndless_revision_max = f.data;
			break;
		case Zehn_flag_type::RUNS_ON_COLOR:
			if(f.data == false && has_colors)
			{
				msgbox("Error", "The application %s doesn't support CX and CM calculators!", application_name);
				return 2;
			}
			break;
		case Zehn_flag_type::RUNS_ON_CLICKPAD:
			if(f.data == false && !is_touchpad)
			{
				msgbox("Error", "The application %s doesn't support clickpads!", application_name);
				return 2;
			}
			break;
		case Zehn_flag_type::RUNS_ON_TOUCHPAD:
			if(f.data == false && is_touchpad)
			{
				msgbox("Error", "The application %s doesn't support touchpads!", application_name);
				return 2;
			}
			break;
		case Zehn_flag_type::RUNS_ON_32MB:
			if(f.data == false && (!has_colors || is_cm))
			{
				msgbox("Error", "The application %s requires more than 32MB of RAM!", application_name);
				return 2;
			}
			break;
                case Zehn_flag_type::RUNS_ON_HWW:
                        *supports_hww = f.data;
			break;
		default:
			break;
		}
	}

	// Show some information about the executable
	if(isKeyPressed(KEY_NSPIRE_CAT))
	{
		msgbox("Information about the executable", "Name: %s Version: %u\nAuthor: %s\nNotice: %s", application_name, application_version, application_author, application_notice);
		return 2;
	}

	if(NDLESS_VERSION < ndless_version_min || (NDLESS_VERSION == ndless_version_min && NDLESS_REVISION < ndless_revision_min))
	{
		msgbox("Error", "The application %s requires at least ndless %d.%d.%d!", application_name, ndless_version_min / 10, ndless_version_min % 10, ndless_revision_min);
		return 2;
	}

	if(NDLESS_VERSION > ndless_version_max || (NDLESS_VERSION == ndless_version_max && NDLESS_REVISION > ndless_revision_max))
	{
		if(ndless_revision_max != UINT_MAX)
			msgbox("Error", "The application %s requires ndless %d.%d.%d or older!", application_name, ndless_version_max / 10, ndless_version_max % 10, ndless_revision_max);
		else
			msgbox("Error", "The application %s requires ndless %d.%d or older!", application_name, ndless_version_max / 10, ndless_version_max % 10);

		return 2;
	}

	// Iterate through the reloc table
	for(Zehn_reloc &r : relocs)
	{
		if(r.offset >= remaining_mem)
		{
			puts("[Zehn] Wrong reloc in Zehn file!");
			return 1;
		}

		// No alignment guaranteed!
		uint32_t *place = reinterpret_cast<uint32_t*>(base + r.offset);
		switch(r.type)
		{
		//Handled above
		case Zehn_reloc_type::FILE_COMPRESSED:
                        break;
                case Zehn_reloc_type::UNALIGNED_RELOC:
                        if(r.offset != 0)
                        {
                            printf("[Zehn] Unexpected UNALIGNED_RELOC value %u!\n", r.offset);
                            return 1;
                        }

			break;
		case Zehn_reloc_type::ADD_BASE:
			wu32(place, ru32(place) + reinterpret_cast<uint32_t>(base));
			break;
		case Zehn_reloc_type::ADD_BASE_GOT:
		{
			uint32_t u32;
			while((u32 = ru32(place)) != 0xFFFFFFFF)
				wu32(place++, u32 + reinterpret_cast<uint32_t>(base));

			break;
		}
		case Zehn_reloc_type::SET_ZERO:
			wu32(place, 0);
			break;
		default:
			printf("[Zehn] Unsupported reloc %d!\n", static_cast<int>(r.type));
			return 1;
		}
	}

	*entry = reinterpret_cast<int (*)(int,char*[])>(base + header.entry_offset);

	return 0;
}
