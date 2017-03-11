#include <syscall-list.h>
#include <syscall-addrs.h>
#include <syscall.h>
#include <nucleus.h>

extern "C" void ut_read_os_version_index();
extern "C" int ut_os_version_index;

#define RES_PATH_REL "./ndless/ndless_resources.tns"

int main()
{
	ut_read_os_version_index();

	//Unregister exploit
        *reinterpret_cast<unsigned int*>(ut_os_version_index == 10 ? 0x109C6AD8 : 0x10A0AEAC) = ut_os_version_index == 10 ? 0x1000DBF8 : 0x1000DBB8;

	syscall_local<e_NU_Set_Current_Dir, void>(syscall_local<e_get_documents_dir, const char*>());

	NUC_FILE *res_fp = syscall_local<e_fopen, NUC_FILE*>(RES_PATH_REL, "rb");
	char *res_argv = nullptr;
	const int x = 0;

        if (!res_fp)
	{
		syscall_local<e_disp_str, void>("ndless_resources not found.", &x, 0);
		return 0;
	}

	struct nuc_stat res_stat;
        syscall_local<e_stat, int>(RES_PATH_REL, &res_stat);
        char *core = syscall_local<e_malloc, char*>(res_stat.st_size);
        syscall_local<e_fread, int>(core, res_stat.st_size, 1, res_fp);
        syscall_local<e_fclose, int>(res_fp);

        asm volatile(	"0: mrc p15, 0, r15, c7, c10, 3 @ test and clean DCache \n"
			" bne 0b \n"
			" mov r0, #0 \n"
			" mcr p15, 0, r0, c7, c7, 0 @ invalidate ICache and DCache \n" ::: "r0");

        ((int (*)(int argc, void* argv))(core + sizeof("PRG")))(1, &res_argv);
	syscall_local<e_disp_str, void>("Ndless installed!", &x, 0);
	return 0;
}
