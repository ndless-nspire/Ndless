#define NAND_PAGE_SIZE		(is_cx?0x800:0x200)
#define MODEL_OFFSET		0x804
#define PART_TABLE_OFFSET	0x818
#define PART_TABLE_ID		"\x91\x5F\x9E\x4C"
#define PART_TABLE_SIZE		4
#define DIAGS_OFFSET_OFFSET	0x82c
#define BOOT2_OFFSET_OFFSET	0x830
#define BOOTD_OFFSET_OFFSET	0x834
#define FILES_OFFSET_OFFSET	0x838

#define MANUF_PAGE_OFFSET	0x000
#define BOOT2_PAGE_OFFSET	0x020
#define BOOTD_PAGE_OFFSET	0xA80
#define DIAGS_PAGE_OFFSET 	0xB00
#define FILES_PAGE_OFFSET	0x1000

#define MANUF_PAGES_NUM		(BOOT2_PAGE_OFFSET-MANUF_PAGE_OFFSET)
#define BOOT2_PAGES_NUM		(BOOTD_PAGE_OFFSET-BOOT2_PAGE_OFFSET)
#define BOOTD_PAGES_NUM		(DIAGS_PAGE_OFFSET-BOOTD_PAGE_OFFSET)
#define DIAGS_PAGES_NUM		(FILES_PAGE_OFFSET-DIAGS_PAGE_OFFSET)

static const unsigned read_nand_31_addrs[] = {0x10071F5C, 0x10071EC4, 0x10071658, 0X100715E8, 0x1006E0AC, 0x1006E03C};
#define read_nand_31 SYSCALL_CUSTOM(read_nand_31_addrs, void,  void* dest, int size, int offset, int, int percent_max, void *progress_cb)

// backward compatible read_nand
void bc_read_nand(void* dest, int size, int offset, int unknown, int percent_max, void *progress_cb) {
	if (nl_ndless_rev() < 989) // Ndless 3.1
		read_nand_31(dest, size, offset, unknown, percent_max, progress_cb);
	else
		read_nand(dest, size, offset, unknown, percent_max, progress_cb);
}