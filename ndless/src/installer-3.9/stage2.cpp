#include <nucleus.h>
#include <syscall-list.h>
#include <syscall-addrs.h>
#include <syscall.h>

extern "C" void ut_read_os_version_index();
extern "C" int ut_os_version_index;

int main()
{
	ut_read_os_version_index();

	// Click/TouchPad models (no NAND partition table)
	int nand_page_size = 0x200;
	int offset = 0x0A80 * nand_page_size; // Boot Data NAND offset
	int endoffset= 0x0AFF * nand_page_size; // Diags NAND offset
	char* manufflashdata[0x838 + 4]; // buffer to store the manuf data up to the NAND partition table
	syscall_local<e_read_nand, void>(manufflashdata, 0x838 + 4, 0, 0, 0, nullptr);
	
	// other models with a NAND partition table (both CX and CM)
	if(!syscall_local<e_memcmp, int>(manufflashdata + 0x818, "\x91\x5F\x9E\x4C", 4)) // NAND partition table ID
	{
		nand_page_size=0x800;
		offset=*((long int*)(manufflashdata+0x834));
		endoffset=*((long int*)(manufflashdata+0x82c));
	}
	syscall_local<e_nand_erase_range, void>(offset, endoffset);

	const int x = 0;
	syscall_local<e_disp_str, void>("NAND successfully erased.", &x, 0);
	return 0;

/*	const char *res_path = "/documents/ndless/ndless_resources_3.9.tns";

	NUC_FILE *res_fp = syscall_local<e_fopen, NUC_FILE*>(res_path, "rb");
	char *res_argv = nullptr;

        if (!res_fp)
	{
		const int x = 0;
		syscall_local<e_disp_str, void>("ndless_resources not found.", &x, 0);
		return 0;
	}

	struct nuc_stat res_stat;
        syscall_local<e_stat, int>(res_path, &res_stat);
        char *core = syscall_local<e_malloc, char*>(res_stat.st_size);
        syscall_local<e_fread, int>(core, res_stat.st_size, 1, res_fp);
        syscall_local<e_fclose, int>(res_fp);

        asm volatile(	"0: mrc p15, 0, r15, c7, c10, 3 @ test and clean DCache \n"
			" bne 0b \n"
			" mov r0, #0 \n"
			" mcr p15, 0, r0, c7, c7, 0 @ invalidate ICache and DCache \n" ::: "r0");

        ((int (*)(int argc, void* argv))(core + sizeof("PRG")))(1, &res_argv);
	return 0;*/
}
