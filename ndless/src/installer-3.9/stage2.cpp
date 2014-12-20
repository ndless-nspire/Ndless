#include <syscall-list.h>
#include <syscall-addrs.h>
#include <syscall.h>

extern "C" void ut_read_os_version_index();
extern "C" int ut_os_version_index;

#define DEREF(x) *reinterpret_cast<unsigned int*>(x)

int main()
{
	ut_read_os_version_index();

	//Unregister exploit
	switch(ut_os_version_index)
	{
	case 10: //nothing
		DEREF(0x10F7B5B4) = 0x1147A86C;
		DEREF(0x10EBBD14) = 0x112C1590;
		break;
	case 11: //CAS
		DEREF(0x10F4F5AC) = 0x114424B4;
		DEREF(0x10E8FD0C) = 0x112891D8;
		break;
	case 12: //CX
		DEREF(0x111CD6F4) = 0x11707E48;
		break;
	case 13: //CXCAS
		DEREF(0x1122D6F4) = 0x11767E48;
		break;
	case 14: //nothing 3.9.1
	case 15: //CAS 3.9.1
		return 0;
	case 16: //CX 3.9.1
		DEREF(0x111CD6E4) = 0x11707E38; 
		break;
	case 17: //CXCAS 3.9.1
	default: //WTF
		return 0;
	}

	unsigned int nand_page_size;
	unsigned int bootdata_start;
	unsigned int bootdata_end;

	if(ut_os_version_index == 12 || ut_os_version_index == 13 || ut_os_version_index == 16 || ut_os_version_index == 17) //CX => Has partition table
	{
		char manufflashdata[0x838 + 4];
		syscall_local<e_read_nand, void>(manufflashdata, 0x838 + 4, 0, 0, 0, nullptr); // Read manuf data

		if(syscall_local<e_memcmp, int>(manufflashdata + 0x818, "\x91\x5F\x9E\x4C", 4) != 0) // Not a partition table?
		{
			const int x = 0;
			syscall_local<e_disp_str, void>("Partition table not found!", &x, 0);
			return 0;
		}

		nand_page_size = 0x800;
		bootdata_start = *((long int*)(manufflashdata + 0x834));
		bootdata_end = *((long int*)(manufflashdata + 0x82c));
	}
	else
	{
		nand_page_size = 0x200;
		bootdata_start = 0x0A80 * nand_page_size;
		bootdata_end = 0x0AFF * nand_page_size;
	}

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
