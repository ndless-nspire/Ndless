#include <syscall-list.h>
#include <syscall-addrs.h>
#include <syscall.h>

extern "C" void ut_read_os_version_index();
extern "C" int ut_os_version_index;

int main()
{
	ut_read_os_version_index();

	char manufflashdata[0x838 + 4];
	syscall_local<e_read_nand, void>(manufflashdata, 0x838 + 4, 0, 0, 0, nullptr); // Read manuf data
	
	if(syscall_local<e_memcmp, int>(manufflashdata + 0x818, "\x91\x5F\x9E\x4C", 4) == 1) // Not a partition table?
	{
		const int x = 0;
		syscall_local<e_disp_str, void>("Partition table not found!", &x, 0);
		return 0;
	}

	const unsigned int nand_page_size = 0x800;
	unsigned int bootdata_start = *((long int*)(manufflashdata + 0x834));
	unsigned int bootdata_end = *((long int*)(manufflashdata + 0x82c));
	bool found = false;

	for(unsigned int bootdata_current = bootdata_start; bootdata_current < bootdata_end; bootdata_current += nand_page_size)
	{
		char bootdata[nand_page_size];
		syscall_local<e_read_nand, void>(bootdata, nand_page_size, bootdata_start, 0, 0, nullptr);

		if(bootdata[0] == 0xAA && bootdata[1] == 0xC6 && bootdata[2] == 0x8C && bootdata[3] == 0x92) // Found signature
		{
			// Set minimum OS version to 0.0.0.0
			bootdata[4] = bootdata[5] = bootdata[6] = bootdata[7] = 0;

			syscall_local<e_write_nand, void>(bootdata, nand_page_size, bootdata_current);

			found = true;
		}
	}

	const int x = 0;
	syscall_local<e_disp_str, void>(found ? "Downgrade protection disabled." : "Bootdata not found!", &x, 0);
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
