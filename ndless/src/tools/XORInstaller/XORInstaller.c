#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdlib.h>

/* This program searches input for an usused byte and XORs input with this key,
   So that there aren't any 0s left and writes the result to output.
   A 4byte header with format 
   (0x100 + xor_key) | ((0x100 + size) << 16)
   is put on top. This file is used by installer-3.9, stage0.S unescapes it. */

int main(int argc, char **argv)
{
	if(argc != 3)
	{
		fprintf(stderr, "Usage: %s Input Output\n", argv[0]);
		return 1;
	}

	int count[256];
	memset(count, 0, sizeof(count));
	count[0] = 1;

	FILE *f = fopen(argv[1], "rb");
	if(!f)
	{
		fprintf(stderr, "Open failed.\n");
		return 1;
	}

	fseek(f, 0, SEEK_END);
	int size = ftell(f);
	printf("Size: 0x%x\n", size);
	fseek(f, 0, SEEK_SET);

	uint8_t *buf = malloc(size);

	fread(buf, size, 1, f);
	fclose(f);

	for(int i = 0; i < size; ++i)
		count[buf[i]]++;

	uint16_t xor_key = 0;
	for(int i = 0; i < 256; ++i)
	{
		if(count[i] == 0)
		{
			xor_key = i;
			printf("XOR key: 0x%x\n", i);
			break;
		}
	}

	if(xor_key == 0)
	{
		fprintf(stderr, "No XOR key found!\n");
		free(buf);
		return 1;
	}

	for(int i = 0; i < size; ++i)
		buf[i] = buf[i] ^ xor_key;

	//0x100 so there is no 0 in here
	uint32_t header = (0x100 + xor_key ) | ((0x100 + size) << 16);

	f = fopen(argv[2], "wb");
	fwrite(&header, sizeof(header), 1, f);
	fwrite(buf, 1, size, f);
	fclose(f); 

	free(buf);

	return 0;
}
