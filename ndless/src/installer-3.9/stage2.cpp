#include <syscall-list.h>
#include <syscall-addrs.h>
#include <syscall.h>
#include <nucleus.h>

extern "C" void ut_read_os_version_index();
extern "C" int ut_os_version_index;

#define DEREF(x) *reinterpret_cast<unsigned int*>(x)

#define RES_PATH_REL "./ndless/ndless_resources.tns"

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
		DEREF(0x1122D6E4) = 0x11767E38;
		break;
	default: //WTF
		return 0;
	}

	/* We can't use chdir "trick" here, as something gets overwritten during the install
	 * So, just build the full path with the current virtual root */
	char res_path[100];
	syscall_local<e_sprintf, int>(res_path, "%s%s", syscall_local<e_get_documents_dir, const char*>(), RES_PATH_REL);

	NUC_FILE *res_fp = syscall_local<e_fopen, NUC_FILE*>(res_path, "rb");
	char *res_argv = nullptr;
	const int x = 0;

	if (!res_fp)
	{
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
	syscall_local<e_disp_str, void>("Ndless installed!", &x, 0);
	return 0;
}
