#include <stdio.h>
#include <errno.h>
#include <stdlib.h>

int main(int argc, char **argv)
{
	puts("Hello World!");
	printf("This is 0.5 as a float: %f\n", 0.5f);
	char *a = malloc(10);
	printf("10 bytes allocated at 0x%x\n", (int) a);
	free(a);
	if(argc != 1)
	{
		puts("I don't know my name :-(");
		return 1;
	}

	printf("I'm now going to fopen %s...\n", argv[0]);
	FILE *myself = fopen(argv[0], "rb");
	if(!myself)
	{
		printf("Failed! errno: %d\n", errno);
		return 1;
	}
	
	char sig[5];
	sig[4] = 0;
	int read = fread(sig, 1, 5, myself);
	printf("I read %d chars: %s\n", read, sig);
	fclose(myself);
	
	puts("Bye!");
	
	return 0;
}