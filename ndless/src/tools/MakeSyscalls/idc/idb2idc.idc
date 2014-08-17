// IDA script for idb2idc.sh
#define UNLOADED_FILE   1
#include <idc.idc>

static main(void)
{
	auto fp;
	fp = fopen("temp.idc", "wb");
	GenerateFile(OFILE_IDC, fp, 0, 0x15000000, 0);
	fclose(fp);
	Exit(0);
}
