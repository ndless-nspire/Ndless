#include <stdio.h>
#include <errno.h>
#include <stdlib.h>

int main(int argc, char **argv)
{
	//Text IO
	puts("Hello World!");
	printf("This is 0.5 as a float: %f\n", 0.5f);
	fputs("This is an error message!\n", stderr);
	
	//Dynamic memory management
	char *a = malloc(10);
	printf("10 bytes allocated at 0x%x\n", (int) a);
	free(a);
	
	//Arguments
	if(argc != 1)
	{
		puts("I don't know my name :-(");
		return 1;
	}

	//File IO
	printf("I'm now going to fopen %s...\n", argv[0]);
	FILE *myself = fopen(argv[0], "rb");
	if(!myself)
	{
		printf("Failed! errno: %d\n", errno);
		return 1;
	}
	
	char sig[5];
	sig[4] = 0;
	int read = fread(sig, 1, 4, myself);
	printf("I read %d chars: %s\n", read, sig);
	fclose(myself);
	
	puts("Seek back...");
	if(!fseek(myself, SEEK_CUR, 0))
	{
		printf("Couldn't seek! errno: %d\n", errno);
		return 1;
	}
	
	read = fread(sig, 1, 5, myself);
	printf("I read %d chars: %s\n", read, sig);
	
	puts("Bye!");
	
	return 0;
}