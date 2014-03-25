#include <string.h>
#include "os-win32.h"
#include "emu.h"

/* Copy of translation table in memory (hack to approximate effect of having a TLB) */
static u32 mmu_translation_table[0x1000];

/* Translate a virtual address to a physical address */
u32 mmu_translate(u32 addr, bool writing, fault_proc *fault) {
	u32 page_size;
	if (!(arm.control & 1))
		return addr;

	u32 *table = mmu_translation_table;
	u32 entry = table[addr >> 20];
	u32 domain = entry >> 5 & 0x0F;
	u32 status = domain << 4;
	u32 ap;

	switch (entry & 3) {
		default: /* Invalid */
			if (fault) fault(addr, status + 0x5); /* Section translation fault */
			return 0xFFFFFFFF;
		case 1: /* Course page table (one entry per 4kB) */
			table = phys_mem_ptr(entry & 0xFFFFFC00, 0x400);
			if (!table) {
				if (fault) error("Bad page table pointer");
				return 0xFFFFFFFF;
			}
			entry = table[addr >> 12 & 0xFF];
			break;
		case 2: /* Section (1MB) */
			page_size = 0x100000;
			ap = entry >> 6;
			goto section;
		case 3: /* Fine page table (one entry per 1kB) */
			table = phys_mem_ptr(entry & 0xFFFFF000, 0x1000);
			if (!table) {
				if (fault) error("Bad page table pointer");
				return 0xFFFFFFFF;
			}
			entry = table[addr >> 10 & 0x3FF];
			break;
	}

	status += 2;
	switch (entry & 3) {
		default: /* Invalid */
			if (fault) fault(addr, status + 0x5); /* Page translation fault */
			return 0xFFFFFFFF;
		case 1: /* Large page (64kB) */
			page_size = 0x10000;
			ap = entry >> (addr >> 13 & 6);
			break;
		case 2: /* Small page (4kB) */
			page_size = 0x1000;
			ap = entry >> (addr >> 9 & 6);
			break;
		case 3: /* Tiny page (1kB) */
			page_size = 0x400;
			ap = entry;
			break;
	}
section:;

	u32 domain_access = arm.domain_access_control >> (domain << 1) & 3;
	if (domain_access != 3) {
		if (!(domain_access & 1)) {
			/* 0 (No access) or 2 (Reserved)
			 * Testing shows they both raise domain fault */
			if (fault) fault(addr, status + 0x9); /* Domain fault */
			return 0xFFFFFFFF;
		}
		/* 1 (Client) - check access permission bits */
		switch (ap >> 4 & 3) {
			case 0: /* Controlled by S/R bits */
				switch (arm.control >> 8 & 3) {
					case 0: /* No access */
					case 3: /* Reserved - testing shows this behaves like 0 */
					perm_fault:
						if (fault) fault(addr, status + 0xD); /* Permission fault */
						return 0xFFFFFFFF;
					case 1: /* System - read-only for privileged, no access for user */
						if (USER_MODE() || writing)
							goto perm_fault;
						break;
					case 2: /* ROM - read-only */
						if (writing)
							goto perm_fault;
						break;
				}
				break;
			case 1: /* Read/write for privileged, no access for user */
				if (USER_MODE())
					goto perm_fault;
				break;
			case 2: /* Read/write for privileged, read-only for user */
				if (writing && USER_MODE())
					goto perm_fault;
				break;
			case 3: /* Read/write */
				break;
		}
	}

	return (entry & -page_size) | (addr & (page_size - 1));
}

ac_entry *addr_cache;

// Keep a list of valid entries so we can invalidate everything quickly
#define AC_VALID_MAX 256
static u32 ac_valid_index;
static u32 ac_valid_list[AC_VALID_MAX];

static void addr_cache_invalidate(int i) {
	AC_SET_ENTRY_INVALID(addr_cache[i], i >> 1 << 10)
}

/* Since only a small fraction of the virtual address space, and therefore
 * only a small fraction of the pages making up addr_cache, will be in use
 * at a time, we can keep only a few pages committed and thereby reduce 
 * the memory used by a lot. */
#define AC_COMMIT_MAX 128
#define PAGE_SIZE 4096
u8 ac_commit_map[AC_NUM_ENTRIES * sizeof(ac_entry) / PAGE_SIZE];
ac_entry *ac_commit_list[AC_COMMIT_MAX];
u32 ac_commit_index;

bool addr_cache_pagefault(void *addr) {
	ac_entry *page = (ac_entry *)((u32)addr & -PAGE_SIZE);
	u32 offset = page - addr_cache;
	if (offset >= AC_NUM_ENTRIES)
		return false;
	ac_entry *oldpage = ac_commit_list[ac_commit_index];
	if (oldpage) {
		//printf("Freeing %p, ", oldpage);
		os_sparse_decommit(oldpage, PAGE_SIZE);
		ac_commit_map[offset / (PAGE_SIZE / sizeof(ac_entry))] = 0;
	}
	//printf("Committing %p\n", page);
	if (!os_sparse_commit(page, PAGE_SIZE))
		return false;
	ac_commit_map[offset / (PAGE_SIZE / sizeof(ac_entry))] = 1;

	u32 i;
	for (i = 0; i < (PAGE_SIZE / sizeof(ac_entry)); i++)
		addr_cache_invalidate(offset + i);

	ac_commit_list[ac_commit_index] = page;
	ac_commit_index = (ac_commit_index + 1) % AC_COMMIT_MAX;
	return true;
}

void *addr_cache_miss(u32 virt, bool writing, fault_proc *fault) {
	ac_entry entry;
	u32 phys = mmu_translate(virt, writing, fault);
	u8 *ptr = phys_mem_ptr(phys, 1);
	if (ptr && !(writing && (RAM_FLAGS((size_t)ptr & ~3) & RF_READ_ONLY))) {
		AC_SET_ENTRY_PTR(entry, virt, ptr)
		//printf("addr_cache_miss VA=%08x ptr=%p entry=%p\n", virt, ptr, entry);
	} else {
		AC_SET_ENTRY_PHYS(entry, virt, phys)
		//printf("addr_cache_miss VA=%08x PA=%08x entry=%p\n", virt, phys, entry);
	}
	u32 oldoffset = ac_valid_list[ac_valid_index];
	u32 offset = (virt >> 10) * 2 + writing;
	if (ac_commit_map[oldoffset / (PAGE_SIZE / sizeof(ac_entry))])
		addr_cache_invalidate(oldoffset);
	addr_cache[offset] = entry;
	ac_valid_list[ac_valid_index] = offset;
	ac_valid_index = (ac_valid_index + 1) % AC_VALID_MAX;
	return ptr;
}

void addr_cache_flush() {
	u32 i;

	if (arm.control & 1) {
		u32 *table = phys_mem_ptr(arm.translation_table_base, 0x4000);
		if (!table)
			error("Bad translation table base register: %x", arm.translation_table_base);
		memcpy(mmu_translation_table, table, 0x4000);
	}

	for (i = 0; i < AC_VALID_MAX; i++) {
		u32 offset = ac_valid_list[i];
		if (ac_commit_map[offset / (PAGE_SIZE / sizeof(ac_entry))])
			addr_cache_invalidate(offset);
	}
}

#if 0
void *mmu_save_state(size_t *size) {
	(void)size;
	return NULL;
}

void mmu_reload_state(void *state) {
	(void)state;
}
#endif
