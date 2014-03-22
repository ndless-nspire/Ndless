/****************************************************************************
 * Produces the patches to restore the OS variables to their original state
 * required to hot-reboot the OS.
 * 
 * The contents of this file are subject to the Mozilla Public
 * License Version 1.1 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 *
 * The Original Code is Ndless code.
 *
 * The Initial Developer of the Original Code is Excale.
 * Portions created by the Initial Developer are Copyright (C) 2013
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s): Olivier ARMAND <olivier.calc@gmail.com>
 ****************************************************************************/

#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>
#include <stdlib.h>

#define BASE (0x10000000)

int main(int argc, char* argv[]) {
	if(argc != 5) {
		puts("Usage: MakeHotRebootPtch <0xbase> <in_before_boot.bin> <in_after_boot.bin> <out_patches.h>\n"
		     "Input files can be either OS or internal ram images.");
		return 1;
	}
	
	char *base_parse_terminated_at;
	unsigned long base = strtoul(argv[1], &base_parse_terminated_at, 16);
	if (*base_parse_terminated_at != '\0') {
		puts("Base is not an hex number\n");
		return 1;
	}

	FILE *input_before = fopen(argv[2], "rb");
	if (!input_before) {
		printf("Open #1 failed.\n");
		return 1;
	}
	FILE *input_after = fopen(argv[3], "rb");
	if (!input_after) {
		printf("Open #2 failed.\n");
		return 1;
	}
	FILE *output = fopen(argv[4], "wt");
	if(!output)	{
		printf("Open #3 failed.\n");
		return 1;
	}
	
	uint32_t word1 = 0x0, word2 = 0x0;
    uint32_t startaddr = 0x0, seq_length = 0x0;
    uint32_t currtaddr = base;
    uint32_t patchword = 0;
	fputs("/* This file was initially generated with MakeHotRebootPtch */\n", output);
	for (; 1; currtaddr += 4) {
		int end_of_file = 0;
		if (fread(&word1, 4, 1, input_before) != 1 || fread(&word2, 4, 1, input_after) != 1)
			end_of_file = 1;
		// end of sequence
		if ( (seq_length > 0)
			 && ( end_of_file || (word1 != patchword) ) ) { // end of file or different diff
			// flush
            if (seq_length == 1) {
				fprintf(output, "PATCH_SETW(0x%08"PRIX32", 0x%08"PRIX32");\n", startaddr, patchword);
			} else {
                fprintf(output, "PATCH_SETZ(0x%08"PRIX32", 0x%08"PRIX32", 0x%08"PRIX32");\n", startaddr, currtaddr, patchword);
            }
			seq_length = 0;
		}
		// end of file
		if (end_of_file) break;
		// no diff
		if (word1 == word2) continue;
		// new sequence
		if (!seq_length)
			startaddr = currtaddr;
		// longer sequence
		seq_length++;
		patchword = word1;        
	}
	
	fclose(input_before);
	fclose(input_after);
	fclose(output);
	return 0;
}
