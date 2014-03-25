#include <os.h>

int main(void) {
	FILE *f = fopen("/documents/ndless/refreshed.tns", "w+");
	fclose(f);
	refresh_osscr();
	return 0;
}
