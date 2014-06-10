#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <dirent.h>

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
	
	puts("Seek back...");
	if(fseek(myself, SEEK_SET, 0) == -1)
		printf("Couldn't seek! errno: %d\n", errno);
	
	read = fread(sig, 1, 4, myself);
	printf("I read %d chars: %s\n", read, sig);
	
	fclose(myself);

	puts("Now I try to open '.':");
	DIR *dir = opendir(".");
	struct dirent *dirent;
	if(!dir)
		puts("Failed to open '.'!");
	else
	{
		puts("Entries in '.':");
		while((dirent = readdir(dir)))
			puts(dirent->d_name);

		closedir(dir);
	}
	
	puts("Bye!");

	return 0;
}
