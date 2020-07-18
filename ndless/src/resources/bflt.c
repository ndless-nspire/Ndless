/* Loads bFLT binaries
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/.
 *
 * Original author: Daniel Tang <dt.tangr@gmail.com>
 * Original source code: https://github.com/tangrs/ndless-bflt-loader
 *
 */

#include <os.h>
#include "ndless.h"
#include "flat.h"
#include "bflt.h"

#if VERBOSE_LEVEL > 2
#define info(f, args...) printf("bFLT: "f"\n", ##args)
#else
#define info(f, args...) (void)0
#endif

#if VERBOSE_LEVEL > 1
#define error_return(x) return (printf("bFLT: %s\n",x), -1)
#define error_goto_error(x) do { printf("bFLT: %s\n",x); goto error; } while(0)
#else
#define error_return(x) return -1
#define error_goto_error(x) goto error
#endif

#if VERBOSE_LEVEL > 0
#define error_user_return(x, args...) do { \
        char err_buffer[128]; \
        sprintf(err_buffer,x,##args); \
        show_msgbox("bFLT loader",err_buffer); \
        error_return(err_buffer); \
    } while (0)
#define error_user_goto_error(x, args...) do { \
        char err_buffer[128]; \
        sprintf(err_buffer,x,##args); \
        show_msgbox("bFLT loader",err_buffer); \
        error_goto_error(err_buffer); \
    } while (0)
#else
#define error_user_return(x, args...) return -1
#define error_user_goto_error(x, args...) goto error
#endif

static inline void endian_fix32(uint32_t * tofix, size_t count) {
	/* bFLT is always big endian */
	/* we are little endian, do a byteswap */
	size_t i;
	for (i=0; i < count; i++)
	{
		uint32_t big = tofix[i];
		tofix[i] = ((big & 0xFF) << 24) | ((big & 0xFF00) << 8) | ((big & 0xFF0000) >> 8) | ((big & 0xFF000000) >> 24);
	}
}

static int read_header(FILE* fp, struct flat_hdr * header) {
    size_t bytes_read = nuc_fread(header, 1, sizeof(struct flat_hdr), fp);
    endian_fix32(&header->rev, ( &header->build_date - &header->rev ) + 1);

    if (bytes_read == sizeof(struct flat_hdr)) {
        return 0;
    }else{
        error_return("Error reading header");
    }
}

static int check_header(struct flat_hdr * header) {
    if (memcmp(header->magic, "bFLT", 4) != 0) error_return("Magic number does not match");
    if (header->rev != FLAT_VERSION) error_return("Version number does not match");

    /* check for unsupported flags */
    if (header->flags & (FLAT_FLAG_GZIP | FLAT_FLAG_GZDATA)) error_user_return("Unsupported flags detected - GZip'd data is not supported");

    return 0;
}

static int copy_segments(FILE* fp, struct flat_hdr * header, void * mem, size_t max_size) {
    /* each segment follows on one after the other */
    /* [   .text   ][   .data   ][   .bss   ]         */
    /* ^entry       ^data_start  ^data_end  ^bss_end  */
    /* that means we can copy them all at once */
    nuc_fseek(fp, header->entry, SEEK_SET);

    size_t size_required = header->bss_end - header->entry;
    size_t size_to_copy = header->data_end - header->entry;
    if (size_required > max_size) error_return("Segment buffer not large enough");

    /* zero out memory for bss */
    memset( (char*)mem + size_to_copy, 0, size_required - size_to_copy );

    if (nuc_fread(mem, 1, size_to_copy, fp) == size_to_copy) {
        return 0;
    }else{
        error_return("Could not read all segments");
    }
}

static inline void* calc_reloc(uint32_t offset, void *base) {
    /* the library id is located in high byte of offset entry */
    int id = (offset >> 24) & 0xff;
    offset &= 0x00ffffff;

    /* fix up offset */
    if (id != 0)
	{
		puts("bFLT: No support for bFLT shared libraries.");
		return (void*) -1;
	}

    return (void*)((uint32_t)base + offset);

}

static int process_relocs(FILE *fp, struct flat_hdr * header, void * base) {
    if (!header->reloc_count) { info("No relocation needed"); return 0; }
    nuc_fseek(fp, header->reloc_start, SEEK_SET);
    size_t size_to_copy = sizeof(uint32_t) * header->reloc_count;
    uint32_t * offset_list = malloc(size_to_copy);
    if (!offset_list) error_return("Failed to allocate temporary memory in process_relocs");

    size_t size_read = nuc_fread(offset_list, sizeof(uint32_t), header->reloc_count, fp);
    if (size_read < size_to_copy/sizeof(uint32_t)) {
        free(offset_list);
        error_return("Failed to read relocs");
    }

    endian_fix32(offset_list, header->reloc_count);

    size_t i;
    for (i=0; i<header->reloc_count; i++) {
        uint32_t fixme = *(uint32_t*)((uint32_t)base + offset_list[i]);

        void* relocd_addr = calc_reloc(fixme, base);
        if (relocd_addr == (void*)-1) {
            free(offset_list);
            error_return("Unable to calculate relocation address");
        }

        *(uint32_t*)((uint32_t)base + offset_list[i]) = (uint32_t)relocd_addr;
    }
    free(offset_list);
    return 0;
}

static int process_got(struct flat_hdr * header, void * base) {
    uint32_t *got = (uint32_t*)((uint32_t)base + header->data_start - header->entry);

    for (; *got != 0xffffffff; got++) {
        void* relocd_addr = calc_reloc(*got, base);
        if (relocd_addr == (void*)-1) {
            error_return("Unable to calculate got address");
        }
        *got = (uint32_t)relocd_addr;
    }
    return 0;
}

int bflt_load(FILE* fp, void **mem_ptr, int (**entry_address_ptr)(int,char*[])) {
    void * mem = NULL;
    struct flat_hdr header;

    info("Begin loading");

    if (!fp) error_goto_error("Recieved bad file pointer");
    if (read_header(fp, &header) != 0) error_goto_error("Could not parse header");
    if (check_header(&header) != 0) error_goto_error("Bad header");

    size_t binary_size = header.bss_end - header.entry;
    info("Attempting to alloc %u bytes",binary_size);

    if(emu_debug_alloc_ptr)
    {
        if(emu_debug_alloc_size() < binary_size)
        {
            puts("bFLT: emu_debug_alloc_size too small!");
            mem = malloc(binary_size);
        }
        else
            mem = emu_debug_alloc_ptr;
    }
    else
        mem = malloc(binary_size);

    if (!mem) error_goto_error("Failed to alloc binary memory");

    if (copy_segments(fp, &header, mem, binary_size) != 0) error_goto_error("Failed to copy segments");
    if (process_relocs(fp, &header, mem) != 0) error_goto_error("Failed to relocate");

    /* only attempt to process GOT if the flags tell us a GOT exists AND
       if the Ndless startup file is not already doing so */
    if (header.flags & FLAT_FLAG_GOTPIC && strcmp(mem, PRGMSIG) != 0) {
        if (process_got(&header, mem) != 0) error_goto_error("Failed to process got");
    }else{
        info("No need to process got - skipping");
    }

    *mem_ptr = mem;

    if (memcmp(mem, "PRG\0", 4) == 0) {
        info("Detected as ndless program packaged in a bFLT file");
        *entry_address_ptr = (int (*)(int,char*[]))((char*)mem + 4);
    }else{
        info("Detected as ordinary bFLT executable");
        *entry_address_ptr = (int (*)(int,char*[]))mem;
    }

    info("Successfully loaded bFLT executable to memory");
    return 0;
    error:
    if (mem) free(mem);
    *mem_ptr = NULL;
    *entry_address_ptr = NULL;
    error_return("Caught error - exiting");
}
