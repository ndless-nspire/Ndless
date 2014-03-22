/****************************************************************************
 * Escapes the installer binary file forbidden half-words and generates an
 * escape table.
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
 * The Initial Developer of the Original Code is Olivier ARMAND
 * <olivier.calc@gmail.com>.
 * Portions created by the Initial Developer are Copyright (C) 2013
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s): Excale
 ****************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdint.h>

#define MIN(a,b) ({typeof(a) __a = (a); typeof(b) __b = (b); (__a < __b) ? __a : __b;})

void error(const char* msg) {
	fprintf(stderr, "Error: %s.\n", msg);
	exit(1);	
}

unsigned file_size(FILE *f) {
  int pos, end;
  pos = ftell(f);
  fseek (f, 0, SEEK_END);
  end = ftell(f);
  fseek (f, pos, SEEK_SET);
  return end;
}

int main(int argc, const char* argv[]) {
	if (argc != 3) {
		puts("Usage: EscapeInst <in_installer.bin> <out_installer.bin>\n"
			 "Escape forbidden half-words (0000 and 0009).\n"
			 "The escape table is added at the beginning.\n");
		return 0;
	}
	FILE *finst = fopen(argv[1], "rb");
	if (!finst) error("can't open input file");
	FILE *fout = fopen(argv[2], "wb");
	if (!fout) error("can't open output file");
	unsigned inst_size = file_size(finst);
    if (inst_size > 0xFFFC) { error("installer too long"); }
	char *inbuf = malloc(inst_size);
	if (fread(inbuf, 1, inst_size, finst) != inst_size) error("can't read installer file");
	
	// build the escape table at the beginning of the installer
	// format: 
	// 2 bytes: size of the installer
	// 2 bytes: number of entries in the table
	// 2 bytes*: offset from the beginning of the installer
	//        FFFF if 0000 is escaped.
	//        EEEE if 0009 is escaped.
	
	// write the size of the installer
	//if (   fputc((inst_size+3) & 0x00FC, fout) == EOF
	//		|| fputc(((inst_size+3) & 0xFF00) >> 8, fout) == EOF)
	if (   fputc((inst_size+3) & 0x00FC, fout) == EOF
			|| fputc(((inst_size+3) & 0xFF00) >> 8, fout) == EOF)
			error("can't write installer size to installer file");
	// space for the table size - will be written afterwards
	if (   fputc(0, fout) == EOF
	    || fputc(0, fout) == EOF)
		error("can't write nul escape table size to installer file");
	uint16_t *p16 = (uint16_t*)inbuf;
	uint16_t escape_table_entries = 0;
	while (p16 < (uint16_t*)((char*)inbuf + inst_size)) {
		if (*p16 == 0x0000)
			*p16 = 0xFFFF;
		else if (*p16 == 0x0009)
			*p16 = 0xEEEE;
		else {
			p16++;
			continue;
		}
		// write the offset
		if (   fputc(((char*)p16 - (char*)inbuf) & 0x00FF, fout) == EOF
			|| fputc((((char*)p16 - (char*)inbuf) & 0xFF00) >> 8, fout) == EOF)
			error("can't write the escape table to installer file");
		escape_table_entries++;
		p16++;
	}
    if (escape_table_entries & 1) { //dummy entry so the table size is a multiple of 4
        if (   fputc(0xFC, fout) == EOF
			|| fputc(0xFF, fout) == EOF)
			error("can't write the escape table to installer file");
        escape_table_entries++;
    }

	// append the escaped installer
	if (fwrite(inbuf, 1, inst_size, fout) != inst_size)
		error("can't append escaped installer to output file");
	while (inst_size & 0b11) {
        if (fwrite("\xFF\xFF\xFF", 1, inst_size & 0b11, fout) != inst_size)
            error("can't append escaped installer to output file");
	}
    
	// write the table size
	fseek(fout, 2, SEEK_SET);
	if (   fputc(escape_table_entries & 0x00FF, fout) == EOF
	    || fputc((escape_table_entries & 0xFF00) >> 8, fout) == EOF)
		error("can't write escape table size to installer file");
	
	free(inbuf);
	fclose(finst);
	fclose(fout);
	return 0;
}
